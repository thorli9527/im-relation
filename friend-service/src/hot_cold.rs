//! hot_cold.rs
//!
//! 基于 HotShardStore 的好友列表热/冷门面（对齐新 FriendRepo）。
//!
//! 特性：
//! - 多分片热存（DashMap + moka 热键，值为 Vec<UserId>）。
//! - 读放热：命中即重置 TTI。
//! - 写穿：add/remove/overwrite/delete 直接调用 FriendRepo，成功后回写热存。
//! - 驱逐策略：尽力将分片中的用户完整列表 upsert 到 DB（幂等）。
//! - 在线热刷新：refresh(plan) / refresh_by_autotune(...)。
//!
//! 依赖：
//! - crate::hot_shard_store::{HotShardStore, PersistFn}
//! - crate::autotune::{AutoTuneConfig, CacheAutoTune, auto_tune_cache}
//! - crate::store::mysql::FriendRepo
//! - common::UserId

use std::sync::{Arc, RwLock};

use anyhow::{Context, Result};
use common::UserId;
use tokio::runtime::Handle;

use crate::autotune::{auto_tune_cache, AutoTuneConfig, CacheAutoTune};
use crate::hot_shard_store::{HotShardStore, PersistFn};
use crate::store::mysql::FriendRepo;

#[inline]
fn shard_index(uid: UserId, shards: usize) -> usize {
    (uid as usize) % shards
}

/// 热/冷好友门面（存储层通过 FriendRepo 抽象）
///
/// 写策略：
/// - add/remove：先写 DB（FriendRepo），成功后更新热存；
/// - overwrite：clear_all + upsert_bulk，再回写热存；
/// - delete_user：clear_all 并失效热存。
pub struct HotColdFriendFacade<R: FriendRepo> {
    storage: Arc<R>,
    rt: Handle,
    plan: RwLock<CacheAutoTune>,
    stores: RwLock<Vec<Arc<HotShardStore<UserId, Vec<UserId>>>>>,
}

impl<R: FriendRepo> HotColdFriendFacade<R> {
    /// 构建门面：根据 plan 创建分片，并挂载驱逐持久化回调（upsert_bulk）。
    pub fn new(storage: Arc<R>, plan: CacheAutoTune, rt: Handle) -> Self {
        let stores = Self::build_shards::<R>(&storage, &plan, &rt);
        Self {
            storage,
            rt,
            plan: RwLock::new(plan),
            stores: RwLock::new(stores),
        }
    }

    /// 读取好友列表（命中内存则读放热；未命中则分页冷加载并回写）。
    pub async fn get_friends(&self, uid: UserId) -> Result<Vec<UserId>> {
        if let Some(v) = self.store(uid).get(&uid) {
            return Ok(v);
        }
        let from_db = self.load_all_from_repo(uid).await?;
        self.store(uid).insert(uid, from_db.clone());
        Ok(from_db)
    }

    /// 覆盖写（整个列表替换：clear_all + upsert_bulk）。
    pub async fn overwrite_friends(&self, uid: UserId, mut friends: Vec<UserId>) -> Result<()> {
        friends.sort_unstable();
        friends.dedup();

        // 1) 清空 DB
        self.storage
            .clear_all(uid)
            .await
            .with_context(|| format!("overwrite_friends: clear_all failed, uid={uid}"))?;

        // 2) 批量 UPSERT
        if !friends.is_empty() {
            let payload: Vec<(UserId, Option<&str>)> =
                friends.iter().copied().map(|f| (f, None)).collect();

            self.storage
                .upsert_bulk(uid, &payload)
                .await
                .with_context(|| format!("overwrite_friends: upsert_bulk failed, uid={uid}"))?;
        }

        // 3) 回写热存
        self.store(uid).insert(uid, friends);
        Ok(())
    }

    /// 添加好友（若已存在则忽略别名变化，这里 alias=None）。
    pub async fn add_friend(&self, uid: UserId, fid: UserId) -> Result<()> {
        let _outcome = self
            .storage
            .add_friend(uid, fid, None)
            .await
            .with_context(|| format!("add_friend: repo.add_friend failed, uid={uid}, fid={fid}"))?;

        // 更新热存（Inserted/Unchanged/Updated 都确保缓存包含该 fid）
        let mut list = if let Some(v) = self.store(uid).get(&uid) {
            v
        } else {
            self.load_all_from_repo(uid).await?
        };

        if !list.contains(&fid) {
            list.push(fid);
            list.sort_unstable();
        }
        // 即使 Unchanged，也刷新热度
        self.store(uid).insert(uid, list);
        Ok(())
    }

    /// 移除好友（不存在则忽略）。
    pub async fn remove_friend(&self, uid: UserId, fid: UserId) -> Result<()> {
        let removed = self
            .storage
            .remove_friend(uid, fid)
            .await
            .with_context(|| format!("remove_friend: repo.remove_friend failed, uid={uid}, fid={fid}"))?;

        // 更新热存（无论是否删除成功，都确保缓存存在并刷新热度）
        let mut list = if let Some(v) = self.store(uid).get(&uid) {
            v
        } else {
            self.load_all_from_repo(uid).await?
        };

        let old_len = list.len();
        list.retain(|x| *x != fid);
        if list.len() != old_len || !removed {
            // 刷新热度或落入不变情形
            self.store(uid).insert(uid, list);
        }
        Ok(())
    }

    /// 删除用户：清空其全部好友关系，并从热存移除。
    pub async fn delete_user(&self, uid: UserId) -> Result<()> {
        self.storage
            .clear_all(uid)
            .await
            .with_context(|| format!("delete_user: clear_all failed, uid={uid}"))?;
        self.invalidate_user(uid);
        Ok(())
    }

    /// 将用户标热（如果当前在热存）。
    pub fn warm_user(&self, uid: UserId) {
        let st = self.store(uid);
        if let Some(v) = st.get(&uid) {
            st.insert(uid, v);
        }
    }

    /// 失效用户：从热存移除（不触发驱逐回调）。
    pub fn invalidate_user(&self, uid: UserId) {
        let st = self.store(uid);
        let _ = st.remove(&uid);
    }

    /// 清空全部分片（只清热，不触发驱逐持久化）。
    pub fn clear_all(&self) {
        let stores = self.stores.read().expect("stores RwLock poisoned");
        for st in stores.iter() {
            st.clear();
        }
    }

    // ====== 热刷新 ======

    /// 以新 plan 热刷新（预建→迁移→原子切换→异步清理）。
    pub fn refresh(&self, new_plan: CacheAutoTune) {
        let new_stores = Self::build_shards::<R>(&self.storage, &new_plan, &self.rt);

        let old_snapshot = {
            let guard = self.stores.read().expect("stores RwLock poisoned");
            guard.clone()
        };

        // 尽力迁移（不会阻塞写）
        for old in &old_snapshot {
            for entry in old.inner_map().iter() {
                let uid = *entry.key();
                let list = entry.value().clone();
                let idx = shard_index(uid, new_stores.len());
                new_stores[idx].insert(uid, list);
            }
        }

        // 原子切换
        let old_to_clear = {
            let mut plan_w = self.plan.write().expect("plan RwLock poisoned");
            *plan_w = new_plan;
            let mut stores_w = self.stores.write().expect("stores RwLock poisoned");
            std::mem::replace(&mut *stores_w, new_stores)
        };

        // 异步清理
        let rt = self.rt.clone();
        rt.spawn(async move {
            for st in old_to_clear {
                st.clear();
            }
        });
    }

    /// 在线自动估算后刷新（沿用当前分片数，**方案 A：构造 AutoTuneConfig**）。
    #[allow(clippy::too_many_arguments)]
    pub fn refresh_by_autotune(
        &self,
        avg_key_bytes: usize,
        avg_value_bytes: usize,
        reserve_ratio: f64,
        max_use_ratio: f64,
        overhead_factor: f64,
        hot_ratio: f64,
        default_tti: std::time::Duration,
    ) {
        let current_shards = self.shards();

        // 基于默认值构造 cfg，然后覆盖调用方传入的关键字段
        let mut cfg = AutoTuneConfig::default();
        cfg.shards = current_shards;
        cfg.avg_key_bytes = avg_key_bytes;
        cfg.avg_value_bytes = avg_value_bytes;
        cfg.reserve_ratio = reserve_ratio;
        cfg.max_use_ratio = max_use_ratio;
        cfg.overhead_factor = overhead_factor;
        cfg.hot_ratio = hot_ratio;
        cfg.default_tti = default_tti;
        // 其余字段（split_main_ratio/split_hot_ratio、segments_*、min_hot_per_shard、mem_reader）
        // 使用默认值即可；需要的话，外层也可以再暴露这些参数进行覆盖。

        let new_plan = auto_tune_cache(&cfg);
        self.refresh(new_plan);
    }

    /// 当前计划（浅拷贝）。
    pub fn current_plan(&self) -> CacheAutoTune {
        self.plan.read().expect("plan RwLock poisoned").clone()
    }

    /// 当前分片数。
    #[inline]
    pub fn shards(&self) -> usize {
        self.stores.read().expect("stores RwLock poisoned").len()
    }

    // ====== 对 Detailed 接口的便捷支持 ======

    /// 拉全量“带别名”的好友列表（底库游标分页聚合）
    pub async fn get_friends_detailed(
        &self,
        uid: UserId,
    ) -> anyhow::Result<Vec<crate::store::mysql::FriendEntry>> {
        let mut out = Vec::new();
        let mut cursor: Option<UserId> = None;
        loop {
            let (batch, next) = self.storage.page_friends(uid, cursor, 2048).await?;
            if batch.is_empty() {
                break;
            }
            out.extend(batch);
            cursor = next;
            if cursor.is_none() {
                break;
            }
        }
        Ok(out)
    }

    /// 更新好友别名（None = 清除）；不影响热存（热存仅存 id）
    pub async fn update_friend_alias(
        &self,
        uid: UserId,
        fid: UserId,
        alias: Option<&str>,
    ) -> anyhow::Result<bool> {
        self.storage.set_alias(uid, fid, alias).await
    }

    // ====== 内部工具 ======

    /// 冷加载（分页拉全量，仅取 id）
    async fn load_all_from_repo(&self, uid: UserId) -> Result<Vec<UserId>> {
        let mut out = Vec::new();
        let mut cursor: Option<UserId> = None;
        loop {
            let (items, next) = self
                .storage
                .page_friends(uid, cursor, 2048)
                .await
                .with_context(|| format!("load_all_from_repo: page_friends failed, uid={uid}"))?;
            if items.is_empty() {
                break;
            }
            out.extend(items.into_iter().map(|e| e.friend_id));
            if let Some(c) = next {
                cursor = Some(c);
            } else {
                break;
            }
        }
        Ok(out)
    }

    /// 按 plan 构建分片，并挂持久化回调（驱逐时 upsert_bulk）。
    fn build_shards<T: FriendRepo>(
        storage: &Arc<T>,
        plan: &CacheAutoTune,
        rt: &Handle,
    ) -> Vec<Arc<HotShardStore<UserId, Vec<UserId>>>> {
        let persist: PersistFn<UserId, Vec<UserId>> = Arc::new({
            let storage = Arc::clone(storage);
            move |uid, friends| {
                let storage = Arc::clone(&storage);
                Box::pin(async move {
                    // 驱逐时尽力幂等落库（只写关系，不处理别名）
                    if friends.is_empty() {
                        // 空列表等价于 clear_all
                        let _ = storage.clear_all(uid).await;
                    } else {
                        let payload: Vec<(UserId, Option<&str>)> =
                            friends.iter().copied().map(|f| (f, None)).collect();
                        let _ = storage.upsert_bulk(uid, &payload).await;
                    }
                })
            }
        });

        let mut shards = Vec::with_capacity(plan.shards);
        for _ in 0..plan.shards {
            shards.push(Arc::new(HotShardStore::new(
                plan.per_shard_hot_capacity,
                plan.tti,
                plan.per_shard_segments,
                rt.clone(),
                Some(persist.clone()),
            )));
        }
        shards
    }

    /// 按 uid 获取所在分片引用。
    #[inline]
    fn store(&self, uid: UserId) -> Arc<HotShardStore<UserId, Vec<UserId>>> {
        let stores = self.stores.read().expect("stores RwLock poisoned");
        let i = shard_index(uid, stores.len());
        stores[i].clone()
    }
}
