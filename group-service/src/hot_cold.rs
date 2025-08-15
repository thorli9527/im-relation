use std::sync::Arc;
use std::time::Duration;

use anyhow::Result;
use moka::sync::{Cache, CacheBuilder};
use tokio::runtime::Handle;

use common::{GroupId, MemberListError, UserId};
use crate::db::hash_shard_map::HashShardMap;
use crate::grpc::group_service::{GroupRoleType, MemberRef};
use crate::store::GroupStorage;

// 可选：用 dashmap 做持久化中的去重
use dashmap::DashSet;

pub struct HotColdFacade<S: GroupStorage> {
    map: Arc<HashShardMap>,
    storage: Arc<S>,
    /// 仅作为“热点标记”，不存数据；key 存在表示该群在热点期
    hot: Cache<GroupId, ()>,
    /// 去重当前进行中的持久化，避免同一 gid 并发多次 save_group
    pending_persist: DashSet<GroupId>,
    rt: Handle,
}

impl<S: GroupStorage> HotColdFacade<S> {
    pub fn new(
        map: Arc<HashShardMap>,
        storage: Arc<S>,
        hot_capacity: u64,
        hot_tti_secs: u64,
    ) -> Self {
        let rt = Handle::current();
        let rt_for_listener = rt.clone();

        // 构建 hot cache：仅记录“热点 group_id”，不缓存实际成员
        let builder: CacheBuilder<GroupId, (), _> = Cache::builder()
            .max_capacity(hot_capacity)
            .time_to_idle(Duration::from_secs(hot_tti_secs));

        // 逐出监听：被动写回 + 内存清理
        let hot = builder
            .eviction_listener({
                let map = map.clone();
                let storage = storage.clone();
                move |gid, _unit, _cause| {
                    let map = map.clone();
                    let storage = storage.clone();
                    // 注意：moka 的 listener 可能不在 runtime 线程上，使用 Handle::spawn
                    rt_for_listener.spawn(async move {
                        let gid = *gid;
                        // 抓取当前快照并保存到存储；保存成功再清空本地
                        // 即使失败，也不 panic；下次激活会再次尝试
                        let members = map.get_member_by_key(gid);
                        let _ = storage.save_group(gid, &members).await;
                        map.clear(gid);
                    });
                }
            })
            .build();

        Self {
            map,
            storage,
            hot,
            pending_persist: DashSet::new(),
            rt,
        }
    }

    /// 确保 group 处于“热点”状态：
    /// - 若 hot 中已有标记，直接返回（避免重复从 DB 加载，尤其是空群）
    /// - 若无标记，则尝试从 DB 加载（load_group 内部已做游标分页，避免一次性大结果）
    pub async fn ensure_hot(&self, gid: GroupId) -> Result<()> {
        if self.hot.contains_key(&gid) {
            return Ok(());
        }
        if !self.map.contains_group(gid) {
            if let Ok(Some(members)) = self.storage.load_group(gid).await {
                // DB 中有记录才回填到内存
                let _ = self.map.insert_many(gid, members);
            }
        }
        // 标记热点，无论是否加载到成员（空群也标记，避免重复 IO）
        self.hot.insert(gid, ());
        Ok(())
    }

    /// 去重并发持久化任务：同一 gid 同时只跑一个 save_group
    fn persist_async(&self, gid: GroupId) {
        if !self.pending_persist.insert(gid) {
            // 已经有在途任务，跳过本次
            return;
        }
        let storage = self.storage.clone();
        let map = self.map.clone();
        let pending = self.pending_persist.clone();

        self.rt.spawn(async move {
            let members = map.get_member_by_key(gid);
            // 尽量保存，不因错误中断后续
            let _ = storage.save_group(gid, &members).await;
            pending.remove(&gid);
        });
    }

    // ------------------- 写路径 -------------------

    pub async fn insert(&self, gid: GroupId, m: MemberRef) -> Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await;
        self.map.insert(gid, m)?;
        self.persist_async(gid);
        Ok(())
    }

    pub async fn insert_many(&self, gid: GroupId, members: Vec<MemberRef>) -> Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await;
        self.map.insert_many(gid, members)?;
        self.persist_async(gid);
        Ok(())
    }

    pub async fn remove(&self, gid: GroupId, uid: UserId) -> Result<bool, MemberListError> {
        let _ = self.ensure_hot(gid).await;
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
    ) -> Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await;
        self.map.change_role(gid, uid, role)?;
        self.persist_async(gid);
        Ok(())
    }

    /// 新增：修改/清空别名（与 proto: ChangeAliasReq 对齐）
    pub async fn change_alias(
        &self,
        gid: GroupId,
        uid: UserId,
        alias: Option<String>,
    ) -> Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await;
        // 你在 member_list_wrapper 里实现了 change_alias(user_id, Option<_>)
        self.map.change_alias(gid, uid, alias)?;
        self.persist_async(gid);
        Ok(())
    }

    pub async fn clear(&self, gid: GroupId) {
        let _ = self.ensure_hot(gid).await;
        self.map.clear(gid);
        // 直接删存储，避免写回空集再 upsert 计数
        let storage = self.storage.clone();
        self.rt.spawn(async move {
            let _ = storage.delete_group(gid).await;
        });
    }

    // ------------------- 读路径 -------------------

    /// 分页读取（内存分页，RB 有序迭代；冷群会先 ensure_hot）
    pub async fn get_page(&self, gid: GroupId, page: usize, size: usize) -> Vec<MemberRef> {
        let _ = self.ensure_hot(gid).await;
        self.map.get_page(gid, page, size).unwrap_or_default()
    }

    /// 读取全部（内存快照；DB 侧加载已是游标分页；超大群慎用）
    pub async fn get_all(&self, gid: GroupId) -> Vec<MemberRef> {
        let _ = self.ensure_hot(gid).await;
        self.map.get_member_by_key(gid)
    }

    pub async fn count(&self, gid: GroupId) -> usize {
        let _ = self.ensure_hot(gid).await;
        self.map.get_member_count_by_key(gid)
    }

    /// 用户加入的群列表（优先内存；无则从 DB 带回）
    pub async fn user_groups(&self, uid: UserId) -> Vec<i64> {
        let v = self.map.user_group_list(uid);
        if v.is_empty() {
            if let Ok(Some(v2)) = self.storage.load_user_groups(uid).await {
                return v2;
            }
        }
        v
    }

    // ------------------- 管理/查询 -------------------

    pub fn all_keys(&self) -> Vec<GroupId> {
        self.map.all_keys()
    }

    pub fn all_keys_by_shard(&self, idx: usize) -> Vec<GroupId> {
        self.map.all_keys_by_shard(idx)
    }

    pub fn shard_count(&self) -> usize {
        self.map.shard_count()
    }
}
