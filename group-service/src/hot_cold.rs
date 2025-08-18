//! hot_cold.rs
//! ------------------------------------------------------------------
//! 热/冷一体：成员热层 + 冷存持久化的门面。
//! - ensure_hot：L1 热标记 + 单飞从冷存加载（仅成员集）
//! - 写路径：insert/insert_many/remove/change_role/change_alias -> 去抖合并落库
//! - 热度逐出：仅在持久化成功后清空内存（失败保留，下次再尝试）
//!
//! 依赖：HashShardMap(成员容器)、GroupStorage(冷存接口)、env_logger + log 宏

use std::sync::Arc;
use std::time::Duration;

use anyhow::Result;
use dashmap::{DashMap, DashSet};
use log::{debug, error, info};
use moka::sync::{Cache, CacheBuilder};
use tokio::{runtime::Handle, time::sleep};

use common::{GroupId, MemberListError, UserId};
use crate::member::shard_map::HashShardMap;
use crate::grpc::group_service::{GroupRoleType, MemberRef};
use crate::store::GroupStorage;

/// 运行参数
#[derive(Clone, Debug)]
pub struct HotColdConfig {
    pub hot_capacity: u64,         // 热点标记最大条数
    pub hot_tti: Duration,         // 热点标记 TTI
    pub persist_debounce: Duration // 写入去抖时间窗
}

impl Default for HotColdConfig {
    fn default() -> Self {
        Self {
            hot_capacity: 50_000,
            hot_tti: Duration::from_secs(600),
            persist_debounce: Duration::from_millis(200),
        }
    }
}

/// 热/冷门面
#[derive(Clone)]
pub struct HotColdFacade<S: GroupStorage> {
    map: Arc<HashShardMap>,
    storage: Arc<S>,

    /// 热点群标记（仅 key，无值）
    hot: Cache<GroupId, ()>,

    /// 同一 gid 在途持久化去重
    pending_persist: DashSet<GroupId>,

    /// 单飞：同一 gid 并发只加载一次
    loading: DashMap<GroupId, Arc<tokio::sync::Mutex<()>>>,

    /// 写入去抖时间窗
    persist_debounce: Duration,

    /// 运行时句柄（用于在 listener 中 spawn）
    rt: Handle,
}

impl<S: GroupStorage> HotColdFacade<S> {
    /// 旧签名：快速构造（保留兼容）
    pub fn new(map: Arc<HashShardMap>, storage: Arc<S>, hot_capacity: u64, hot_tti_secs: u64) -> Self {
        Self::with_config(
            map,
            storage,
            HotColdConfig {
                hot_capacity,
                hot_tti: Duration::from_secs(hot_tti_secs),
                ..Default::default()
            },
        )
    }

    /// 推荐：使用配置构造
    pub fn with_config(map: Arc<HashShardMap>, storage: Arc<S>, cfg: HotColdConfig) -> Self {
        let rt = Handle::current();
        let rt_for_listener = rt.clone();

        // 热点标记，仅 key
        let hot_builder: CacheBuilder<GroupId, (), _> = Cache::builder()
            .max_capacity(cfg.hot_capacity)
            .time_to_idle(cfg.hot_tti);

        // 逐出监听：持久化成功 -> 清本地；失败 -> 保留待下次
        let hot = hot_builder
            .eviction_listener({
                let map = map.clone();
                let storage = storage.clone();
                move |gid, _unit, cause| {
                    let map = map.clone();
                    let storage = storage.clone();
                    let gid = *gid;
                    rt_for_listener.spawn(async move {
                        debug!("hot-evict gid={gid}, cause={:?}", cause);
                        let members = map.get_member_by_key(gid);
                        match storage.save_group(gid, &members).await {
                            Ok(_) => {
                                map.clear(gid);
                                debug!("hot-evict persisted & cleared gid={gid}");
                            }
                            Err(e) => {
                                error!("hot-evict persist failed gid={gid}: {e}");
                            }
                        }
                    });
                }
            })
            .build();

        Self {
            map,
            storage,
            hot,
            pending_persist: DashSet::new(),
            loading: DashMap::new(),
            persist_debounce: cfg.persist_debounce,
            rt,
        }
    }

    /// 标记热点（刷新 TTI）
    pub fn touch(&self, gid: GroupId) {
        self.hot.insert(gid, ());
    }

    /// 是否热点
    pub fn is_hot(&self, gid: GroupId) -> bool {
        self.hot.contains_key(&gid)
    }

    /// 预热一批群（忽略错误，尽力加载）
    pub async fn warmup(&self, gids: &[GroupId]) {
        for &gid in gids {
            let _ = self.ensure_hot(gid).await;
        }
    }

    /// 确保群处于“热点”状态（单飞冷加载）
    pub async fn ensure_hot(&self, gid: GroupId) -> Result<()> {
        if self.hot.contains_key(&gid) {
            return Ok(());
        }
        if self.map.contains_group(gid) {
            self.hot.insert(gid, ());
            return Ok(());
        }

        // 单飞锁
        let lock = self
            .loading
            .entry(gid)
            .or_insert_with(|| Arc::new(tokio::sync::Mutex::new(())))
            .clone();
        let _g = lock.lock().await;

        // 二次检查
        if self.hot.contains_key(&gid) || self.map.contains_group(gid) {
            self.hot.insert(gid, ());
            return Ok(());
        }

        // 冷加载（建议 storage 内部游标/分页）
        match self.storage.load_group(gid).await {
            Ok(Some(members)) => {
                let n = members.len();
                let _ = self.map.insert_many(gid, members);
                self.hot.insert(gid, ());
                info!("ensure_hot loaded gid={gid}, members={n}");
            }
            Ok(None) => {
                // 空群也标记，避免重复 IO
                self.hot.insert(gid, ());
                debug!("ensure_hot empty gid={gid}");
            }
            Err(e) => {
                error!("ensure_hot load failed gid={gid}: {e}");
                return Err(e);
            }
        }

        // 可选移除锁项
        self.loading.remove(&gid);
        Ok(())
    }

    /// 去抖持久化：同一 gid 合并窗口内的多次写为一次
    fn persist_async(&self, gid: GroupId) {
        if !self.pending_persist.insert(gid) {
            // 已有在途任务，本次合并
            return;
        }
        let storage = self.storage.clone();
        let map = self.map.clone();
        let pending = self.pending_persist.clone();
        let delay = self.persist_debounce;

        self.rt.spawn(async move {
            sleep(delay).await;
            let snapshot = map.get_member_by_key(gid);
            match storage.save_group(gid, &snapshot).await {
                Ok(_) => debug!("persist ok gid={gid}, members={}", snapshot.len()),
                Err(e) => error!("persist failed gid={gid}: {e}"),
            }
            pending.remove(&gid);
        });
    }

    // ========================= 写路径 =========================

    pub async fn insert(&self, gid: GroupId, m: MemberRef) -> std::result::Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await.map_err(|e| MemberListError::Internal(e.to_string()))?;
        self.map.insert(gid, m)?;
        self.persist_async(gid);
        Ok(())
    }

    pub async fn insert_many(
        &self,
        gid: GroupId,
        members: Vec<MemberRef>,
    ) -> std::result::Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await.map_err(|e| MemberListError::Internal(e.to_string()))?;
        self.map.insert_many(gid, members)?;
        self.persist_async(gid);
        Ok(())
    }

    pub async fn remove(&self, gid: GroupId, uid: UserId) -> std::result::Result<bool, MemberListError> {
        let _ = self.ensure_hot(gid).await.map_err(|e| MemberListError::Internal(e.to_string()))?;
        let removed = self.map.remove(gid, uid)?;
        if removed {
            self.persist_async(gid);
        }
        Ok(removed)
    }

    pub async fn change_role(
        &self,
        gid: GroupId,
        uid: UserId,
        role: GroupRoleType,
    ) -> std::result::Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await.map_err(|e| MemberListError::Internal(e.to_string()))?;
        self.map.change_role(gid, uid, role)?;
        self.persist_async(gid);
        Ok(())
    }

    /// 修改/清空别名
    pub async fn change_alias(
        &self,
        gid: GroupId,
        uid: UserId,
        alias: Option<String>,
    ) -> std::result::Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await.map_err(|e| MemberListError::Internal(e.to_string()))?;
        self.map.change_alias(gid, uid, alias)?;
        self.persist_async(gid);
        Ok(())
    }

    /// 解散群：清热并异步清冷
    pub async fn clear(&self, gid: GroupId) {
        let _ = self.ensure_hot(gid).await;
        self.map.clear(gid);

        let storage = self.storage.clone();
        self.rt.spawn(async move {
            if let Err(e) = storage.delete_group(gid).await {
                error!("delete_group failed gid={gid}: {e}");
            } else {
                info!("delete_group ok gid={gid}");
            }
        });

        // 失效热点标记（避免再次触发逐出）
        self.hot.invalidate(&gid);
    }

    // ========================= 读路径 =========================

    /// 分页读取（内存分页；冷群先 ensure_hot）
    pub async fn get_page(&self, gid: GroupId, page: usize, size: usize) -> Vec<MemberRef> {
        let _ = self.ensure_hot(gid).await;
        self.map.get_page(gid, page, size).unwrap_or_default()
    }

    /// 全量读取（快照；大群慎用）
    pub async fn get_all(&self, gid: GroupId) -> Vec<MemberRef> {
        let _ = self.ensure_hot(gid).await;
        self.map.get_member_by_key(gid)
    }

    pub async fn count(&self, gid: GroupId) -> usize {
        let _ = self.ensure_hot(gid).await;
        self.map.get_member_count_by_key(gid)
    }

    /// 用户加入的群列表（优先内存，miss 冷读）
    pub async fn user_groups(&self, uid: UserId) -> Vec<i64> {
        let v = self.map.user_group_list(uid);
        if v.is_empty() {
            match self.storage.load_user_groups(uid).await {
                Ok(Some(v2)) => return v2,
                Ok(None) => {}
                Err(e) => error!("load_user_groups failed uid={uid}: {e}"),
            }
        }
        v
    }

    // ========================= 管理 =========================

    pub fn all_keys(&self) -> Vec<GroupId> { self.map.all_keys() }
    pub fn all_keys_by_shard(&self, idx: usize) -> Vec<GroupId> { self.map.all_keys_by_shard(idx) }
    pub fn shard_count(&self) -> usize { self.map.shard_count() }

    /// 立即刷盘所有热点群（优雅停机）
    pub async fn flush_all(&self) {
        let keys = self.all_keys();
        info!("flush_all start, groups={}", keys.len());
        for gid in keys {
            let members = self.map.get_member_by_key(gid);
            if let Err(e) = self.storage.save_group(gid, &members).await {
                error!("flush_all save failed gid={gid}: {e}");
            }
        }
        info!("flush_all done");
    }
}
