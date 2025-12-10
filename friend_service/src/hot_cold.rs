//! hot_cold.rs
//!
//! 基于 HotShardStore 的好友列表热/冷门面（对齐新 FriendRepo）。
//!
//! 特性：
//! - 多分片热存（DashMap + moka 热键，值为 Vec<UID>）。
//! - 读放热：命中即重置 TTI。
//! - 写穿：add/remove/overwrite/delete 直接调用 FriendRepo，成功后回写热存。
//! - 驱逐策略：尽力将分片中的用户完整列表 upsert 到 DB（幂等）。
//! - 在线热刷新：refresh(plan) / refresh_by_autotune(...)。
//!
//! 依赖：
//! - crate::hot_shard_store::{HotShardStore, PersistFn}
//! - crate::autotune::{AutoTuneConfig, CacheAutoTune, auto_tune_cache}
//! - crate::store::mysql::FriendRepo
//! - common::UID

use std::sync::{Arc, RwLock};

use anyhow::{Context, Result};
use common::UID;
use tokio::runtime::Handle;

use crate::autotune::{auto_tune_cache, AutoTuneConfig, CacheAutoTune};
use crate::hot_shard_store::HotShardStore;
use crate::store::mysql::{FriendEntry, FriendRepo};

#[inline]
fn shard_index(uid: UID, shards: usize) -> usize {
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
    stores: RwLock<Vec<Arc<HotShardStore<UID, Vec<FriendEntry>>>>>,
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
    pub async fn get_friends(&self, uid: UID) -> Result<Vec<UID>> {
        if let Some(v) = self.store(uid).get(&uid) {
            return Ok(v.iter().map(|e| e.friend_id).collect());
        }
        let from_db = self.load_all_from_repo(uid).await?;
        self.store(uid).insert(uid, from_db.clone());
        Ok(from_db.iter().map(|e| e.friend_id).collect())
    }

    /// 覆盖写（整个列表替换：clear_all + upsert_bulk）。
    pub async fn overwrite_friends(&self, uid: UID, mut friends: Vec<UID>) -> Result<()> {
        friends.sort_unstable();
        friends.dedup();

        // 1) 清空 DB
        self.storage
            .clear_all(uid)
            .await
            .with_context(|| format!("overwrite_friends: clear_all failed, uid={uid}"))?;

        // 2) 批量 UPSERT
        if !friends.is_empty() {
            let payload: Vec<(UID, Option<&str>)> =
                friends.iter().copied().map(|f| (f, None)).collect();

            self.storage
                .upsert_bulk(uid, &payload)
                .await
                .with_context(|| format!("overwrite_friends: upsert_bulk failed, uid={uid}"))?;
        }

        // 3) 回写热存（详细信息未知，先占位）
        let entries: Vec<FriendEntry> = friends
            .into_iter()
            .map(|fid| FriendEntry {
                friend_id: fid,
                nickname: None,
                apply_source: 0,
                remark: None,
                blacklisted: false,
                created_at: 0,
                updated_at: 0,
            })
            .collect();
        self.store(uid).insert(uid, entries);
        Ok(())
    }

    /// 双向添加好友（带昵称，原子性由底层存储保证）。
    pub async fn add_friend_both(
        &self,
        a: UID,
        b: UID,
        nickname_for_a: Option<&str>,
        nickname_for_b: Option<&str>,
        remark_for_a: Option<&str>,
        remark_for_b: Option<&str>,
        apply_source: i32,
    ) -> Result<()> {
        self.storage
            .add_friend_both(
                a,
                b,
                nickname_for_a,
                nickname_for_b,
                remark_for_a,
                remark_for_b,
                apply_source,
            )
            .await
            .with_context(|| {
                format!("add_friend_both: repo.add_friend_both failed a={a}, b={b}")
            })?;

        // 更新两侧热存
        for (uid, fid, nick, remark) in [
            (a, b, nickname_for_a, remark_for_a),
            (b, a, nickname_for_b, remark_for_b),
        ] {
            let mut list = if let Some(v) = self.store(uid).get(&uid) {
                v
            } else {
                self.load_all_from_repo(uid).await?
            };
            if let Some(entry) = list.iter_mut().find(|e| e.friend_id == fid) {
                if let Some(n) = nick {
                    entry.nickname = Some(n.to_string());
                }
                if let Some(r) = remark {
                    entry.remark = Some(r.to_string());
                }
                entry.apply_source = apply_source;
            } else {
                list.push(FriendEntry {
                    friend_id: fid,
                    nickname: nick.map(|s| s.to_string()),
                    apply_source,
                    remark: remark.map(|s| s.to_string()),
                    blacklisted: false,
                    created_at: 0,
                    updated_at: 0,
                });
                list.sort_unstable_by_key(|e| e.friend_id);
            }
            self.store(uid).insert(uid, list);
        }
        Ok(())
    }

    /// 移除好友（不存在则忽略）。
    pub async fn remove_friend(&self, uid: UID, fid: UID) -> Result<()> {
        let removed = self
            .storage
            .remove_friend(uid, fid)
            .await
            .with_context(|| {
                format!("remove_friend: repo.remove_friend failed, uid={uid}, fid={fid}")
            })?;

        // 更新热存（无论是否删除成功，都确保缓存存在并刷新热度）
        let mut list = if let Some(v) = self.store(uid).get(&uid) {
            v
        } else {
            self.load_all_from_repo(uid).await?
        };

        let old_len = list.len();
        list.retain(|x| x.friend_id != fid);
        if list.len() != old_len || !removed {
            // 刷新热度或落入不变情形
            self.store(uid).insert(uid, list);
        }
        Ok(())
    }

    /// 删除用户：清空其全部好友关系，并从热存移除。
    pub async fn delete_user(&self, uid: UID) -> Result<()> {
        self.storage
            .clear_all(uid)
            .await
            .with_context(|| format!("delete_user: clear_all failed, uid={uid}"))?;
        self.invalidate_user(uid);
        Ok(())
    }

    /// 将用户标热（如果当前在热存）。
    pub fn warm_user(&self, uid: UID) {
        let st = self.store(uid);
        if let Some(v) = st.get(&uid) {
            st.insert(uid, v);
        }
    }

    /// 失效用户：从热存移除（不触发驱逐回调）。
    pub fn invalidate_user(&self, uid: UID) {
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
        uid: UID,
    ) -> anyhow::Result<Vec<crate::store::mysql::FriendEntry>> {
        if let Some(v) = self.store(uid).get(&uid) {
            return Ok(v);
        }
        let mut out = Vec::new();
        let mut cursor: Option<UID> = None;
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
        self.store(uid).insert(uid, out.clone());
        Ok(out)
    }

    /// 更新好友昵称（None = 清除）；不影响热存（热存仅存 id）
    pub async fn update_friend_nickname(
        &self,
        uid: UID,
        fid: UID,
        nickname: Option<&str>,
    ) -> anyhow::Result<bool> {
        self.storage.set_nickname(uid, fid, nickname).await
    }

    /// 更新好友 remark
    pub async fn update_friend_remark(
        &self,
        uid: UID,
        fid: UID,
        remark: Option<&str>,
    ) -> anyhow::Result<bool> {
        self.storage.set_remark(uid, fid, remark).await
    }

    /// 拉黑/解黑好友
    pub async fn update_friend_blacklist(
        &self,
        uid: UID,
        fid: UID,
        blocked: bool,
    ) -> anyhow::Result<bool> {
        self.storage.set_blacklist(uid, fid, blocked).await
    }

    /// 读取分页好友详情（含别名等信息），按 friend_id 升序游标翻页。
    pub async fn page_friends_detailed(
        &self,
        uid: UID,
        cursor: Option<UID>,
        limit: u32,
    ) -> anyhow::Result<(Vec<FriendEntry>, Option<UID>)> {
        self.storage.page_friends(uid, cursor, limit).await
    }

    // ====== 内部工具 ======

    /// 冷加载（分页拉全量，含昵称/备注/来源）
    async fn load_all_from_repo(&self, uid: UID) -> Result<Vec<FriendEntry>> {
        let mut out = Vec::new();
        let mut cursor: Option<UID> = None;
        loop {
            let (items, next) = self
                .storage
                .page_friends(uid, cursor, 2048)
                .await
                .with_context(|| format!("load_all_from_repo: page_friends failed, uid={uid}"))?;
            if items.is_empty() {
                break;
            }
            out.extend(items);
            if let Some(c) = next {
                cursor = Some(c);
            } else {
                break;
            }
        }
        Ok(out)
    }

    /// 按 plan 构建分片（关闭驱逐持久化，避免额外 upsert）。
    fn build_shards<T: FriendRepo>(
        _storage: &Arc<T>,
        plan: &CacheAutoTune,
        rt: &Handle,
    ) -> Vec<Arc<HotShardStore<UID, Vec<FriendEntry>>>> {
        let mut shards = Vec::with_capacity(plan.shards);
        for _ in 0..plan.shards {
            shards.push(Arc::new(HotShardStore::new(
                plan.per_shard_hot_capacity,
                plan.tti,
                plan.per_shard_segments,
                rt.clone(),
                None,
            )));
        }
        shards
    }

    /// 按 uid 获取所在分片引用。
    #[inline]
    fn store(&self, uid: UID) -> Arc<HotShardStore<UID, Vec<FriendEntry>>> {
        let stores = self.stores.read().expect("stores RwLock poisoned");
        let i = shard_index(uid, stores.len());
        stores[i].clone()
    }
}
