//! hot_cold.rs
//!
//! 基于 HotShardStore 的好友列表热/冷门面（兼容 FriendStorage: load/save/delete）。
//!
//! 特性：
//! - 多分片热存（DashMap + moka 热键，值为 Vec<UserId>）。
//! - 读放热：命中即重置 TTI。
//! - 驱逐策略：先持久化到 FriendStorage::save_friends，再从主存移除。
//! - 在线热刷新：refresh(plan) / refresh_by_autotune(...)。
//! - 统一写穿：add/remove/overwrite/delete 最终都走 save_friends or delete_friends。
//!
//! 依赖：
//! - crate::hot_shard_store::{HotShardStore, PersistFn}
//! - crate::autotune::{CacheAutoTune, auto_tune_cache}
//! - crate::store::mysql::FriendStorage
//! - common::UserId

use std::sync::{Arc, RwLock};

use anyhow::{Context, Result};
use common::UserId;
use tokio::runtime::Handle;

use crate::autotune::{auto_tune_cache, CacheAutoTune};
use crate::hot_shard_store::{HotShardStore, PersistFn};
use crate::store::mysql::FriendStorage;

#[inline]
fn shard_index(uid: UserId, shards: usize) -> usize {
    (uid as usize) % shards
}

/// 热/冷好友门面（存储层通过 FriendStorage 抽象）
///
/// 写策略：
/// - add/remove/overwrite：更新内存副本 → 调用 save_friends → 回写热存；
/// - delete_user：调用 delete_friends → 从热存移除。
pub struct HotColdFriendFacade<S: FriendStorage> {
    storage: Arc<S>,
    rt: Handle,
    plan: RwLock<CacheAutoTune>,
    stores: RwLock<Vec<Arc<HotShardStore<UserId, Vec<UserId>>>>>,
}

impl<S: FriendStorage> HotColdFriendFacade<S> {
    /// 构建门面：根据 plan 创建分片，并挂载驱逐持久化回调。
    pub fn new(storage: Arc<S>, plan: CacheAutoTune, rt: Handle) -> Self {
        let stores = Self::build_shards::<S>(&storage, &plan, &rt);
        Self {
            storage,
            rt,
            plan: RwLock::new(plan),
            stores: RwLock::new(stores),
        }
    }

    /// 读取好友列表（命中内存则读放热；未命中则冷加载并回写）。
    pub async fn get_friends(&self, uid: UserId) -> Result<Vec<UserId>> {
        if let Some(v) = self.store(uid).get(&uid) {
            return Ok(v);
        }
        let from_db = self
            .storage
            .load_friends(uid)
            .await
            .with_context(|| format!("get_friends: load_friends failed, uid={uid}"))?
            .unwrap_or_default();
        self.store(uid).insert(uid, from_db.clone());
        Ok(from_db)
    }

    /// 覆盖写（整个列表替换）。
    pub async fn overwrite_friends(&self, uid: UserId, friends: Vec<UserId>) -> Result<()> {
        self.storage
            .save_friends(uid, &friends)
            .await
            .with_context(|| format!("overwrite_friends: save_friends failed, uid={uid}"))?;
        self.store(uid).insert(uid, friends);
        Ok(())
    }

    /// 添加好友（若已存在则忽略）。
    pub async fn add_friend(&self, uid: UserId, fid: UserId) -> Result<()> {
        // 取现有列表（内存→DB）
        let mut list = if let Some(v) = self.store(uid).get(&uid) {
            v
        } else {
            self.storage
                .load_friends(uid)
                .await
                .with_context(|| format!("add_friend: load_friends failed, uid={uid}"))?
                .unwrap_or_default()
        };
        // 去重追加
        if !list.contains(&fid) {
            list.push(fid);
            list.sort_unstable();
        }
        // 写穿
        self.storage
            .save_friends(uid, &list)
            .await
            .with_context(|| format!("add_friend: save_friends failed, uid={uid}"))?;
        self.store(uid).insert(uid, list);
        Ok(())
    }

    /// 移除好友（不存在则忽略）。
    pub async fn remove_friend(&self, uid: UserId, fid: UserId) -> Result<()> {
        let mut list = if let Some(v) = self.store(uid).get(&uid) {
            v
        } else {
            self.storage
                .load_friends(uid)
                .await
                .with_context(|| format!("remove_friend: load_friends failed, uid={uid}"))?
                .unwrap_or_default()
        };
        let old_len = list.len();
        list.retain(|x| *x != fid);
        // 若无变化，仍确保热数据存在（读放热）
        if list.len() == old_len {
            self.store(uid).insert(uid, list);
            return Ok(());
        }
        // 写穿
        self.storage
            .save_friends(uid, &list)
            .await
            .with_context(|| format!("remove_friend: save_friends failed, uid={uid}"))?;
        self.store(uid).insert(uid, list);
        Ok(())
    }

    /// 删除用户：删除其全部好友关系，并从热存移除。
    pub async fn delete_user(&self, uid: UserId) -> Result<()> {
        self.storage
            .delete_friends(uid)
            .await
            .with_context(|| format!("delete_user: delete_friends failed, uid={uid}"))?;
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

    /// 失效用户：从热存和主存移除（不触发驱逐持久化）。
    pub fn invalidate_user(&self, uid: UserId) {
        let st = self.store(uid);
        let _ = st.remove(&uid);
    }

    /// 清空全部分片（先清热再清主存，避免驱逐风暴）。
    pub fn clear_all(&self) {
        let stores = self.stores.read().expect("stores RwLock poisoned");
        for st in stores.iter() {
            st.clear();
        }
    }

    /// ====== 热刷新 ======

    /// 以新 plan 热刷新（预建→迁移→原子切换→异步清理）。
    pub fn refresh(&self, new_plan: CacheAutoTune) {
        // 1) 预建新分片
        let new_stores = Self::build_shards::<S>(&self.storage, &new_plan, &self.rt);

        // 2) 旧分片快照
        let old_snapshot = {
            let guard = self.stores.read().expect("stores RwLock poisoned");
            guard.clone()
        };

        // 2.1 迁移（尽力；期间并发写允许）
        for old in &old_snapshot {
            for entry in old.inner_map().iter() {
                let uid = entry.key().clone();
                let list = entry.value().clone();
                let idx = shard_index(uid, new_stores.len());
                new_stores[idx].insert(uid, list);
            }
        }

        // 3) 原子切换（短写锁）
        let old_to_clear = {
            let mut plan_w = self.plan.write().expect("plan RwLock poisoned");
            *plan_w = new_plan;
            let mut stores_w = self.stores.write().expect("stores RwLock poisoned");
            std::mem::replace(&mut *stores_w, new_stores)
        };

        // 4) 异步清理旧分片
        let rt = self.rt.clone();
        rt.spawn(async move {
            for st in old_to_clear {
                st.clear();
            }
        });
    }

    /// 在线自动估算后刷新（沿用当前分片数）。
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
        let new_plan = auto_tune_cache(
            current_shards,
            avg_key_bytes,
            avg_value_bytes,
            reserve_ratio,
            max_use_ratio,
            overhead_factor,
            hot_ratio,
            default_tti,
        );
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

    // ====== 内部工具 ======

    /// 按 plan 构建分片，并挂持久化回调（驱逐时调用 save_friends）。
    fn build_shards<T: FriendStorage>(
        storage: &Arc<T>,
        plan: &CacheAutoTune,
        rt: &Handle,
    ) -> Vec<Arc<HotShardStore<UserId, Vec<UserId>>>> {
        let persist: PersistFn<UserId, Vec<UserId>> = Arc::new({
            let storage = Arc::clone(storage);
            move |uid, friends| {
                let storage = Arc::clone(&storage);
                Box::pin(async move {
                    // 驱逐时尽力持久化；失败时可按需打日志/重试
                    let _ = storage.save_friends(uid, &friends).await;
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
