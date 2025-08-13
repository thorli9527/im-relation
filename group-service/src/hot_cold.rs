use std::sync::Arc;
use std::time::Duration;
use tokio::runtime::Handle;
use anyhow::Result;
use moka::sync::{Cache, CacheBuilder};
use common::{GroupId, MemberListError, UserId};
use crate::db::hash_shard_map::HashShardMap;
use crate::grpc::group_service::{MemberRef, GroupRoleType};
use crate::store::GroupStorage;

pub struct HotColdFacade<S: GroupStorage> {
    map: Arc<HashShardMap>,
    storage: Arc<S>,
    hot: Cache<GroupId, ()>,
    rt: Handle,
}

impl<S: GroupStorage> HotColdFacade<S> {
    pub fn new(map: Arc<HashShardMap>, storage: Arc<S>, hot_capacity: u64, hot_tti_secs: u64) -> Self {
        let rt = Handle::current();
        let rt_for_listener = rt.clone();
        let builder: CacheBuilder<GroupId, (),_> = Cache::builder()
            .max_capacity(hot_capacity)
            .time_to_idle(Duration::from_secs(hot_tti_secs));
        let hot = builder.eviction_listener({
            let map = map.clone();
            let storage = storage.clone();
            move |gid, _unit, _cause| {
                let map = map.clone();
                let storage = storage.clone();
                rt_for_listener.spawn(async move {
                    let gid=*gid.clone();
                    let members = map.get_member_by_key(gid);
                    let _ = storage.save_group(gid, &members).await;
                    map.clear(gid);
                });
            }
        }).build();

        Self { map, storage, hot, rt }
    }

    pub async fn ensure_hot(&self, gid: GroupId) -> Result<()> {
        if self.map.contains_group(gid) && self.hot.contains_key(&gid) {
            return Ok(());
        }
        if let Ok(Some(members)) = self.storage.load_group(gid).await {
            let _ = self.map.insert_many(gid, members);
        }
        self.hot.insert(gid, ());
        Ok(())
    }

    fn persist_async(&self, gid: GroupId) {
        let storage = self.storage.clone();
        let map = self.map.clone();
        self.rt.spawn(async move {
            let members = map.get_member_by_key(gid);
            let _ = storage.save_group(gid, &members).await;
        });
    }

    // writes
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
        if removed { self.persist_async(gid); }
        Ok(removed)
    }
    pub async fn change_role(&self, gid: GroupId, uid: UserId, role: GroupRoleType) -> Result<(), MemberListError> {
        let _ = self.ensure_hot(gid).await;
        self.map.change_role(gid, uid, role)?;
        self.persist_async(gid);
        Ok(())
    }
    pub async fn clear(&self, gid: GroupId) {
        let _ = self.ensure_hot(gid).await;
        self.map.clear(gid);
        let storage = self.storage.clone();
        self.rt.spawn(async move { let _ = storage.delete_group(gid).await; });
    }

    // reads
    pub async fn get_page(&self, gid: GroupId, page: usize, size: usize) -> Vec<MemberRef> {
        let _ = self.ensure_hot(gid).await;
        self.map.get_page(gid, page, size).unwrap_or_default()
    }
    pub async fn get_all(&self, gid: GroupId) -> Vec<MemberRef> {
        let _ = self.ensure_hot(gid).await;
        self.map.get_member_by_key(gid)
    }
    pub async fn count(&self, gid: GroupId) -> usize {
        let _ = self.ensure_hot(gid).await;
        self.map.get_member_count_by_key(gid)
    }
    pub async fn user_groups(&self, uid: UserId) -> Vec<i64> {
        let v = self.map.user_group_list(uid);
        if v.is_empty() {
            if let Ok(Some(v2)) = self.storage.load_user_groups(uid).await { return v2; }
        }
        v
    }

    pub fn all_keys(&self) -> Vec<GroupId> { self.map.all_keys() }
    pub fn all_keys_by_shard(&self, idx: usize) -> Vec<GroupId> { self.map.all_keys_by_shard(idx) }
    pub fn shard_count(&self) -> usize { self.map.shard_count() }
}
