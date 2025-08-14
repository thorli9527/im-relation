use std::ops::Deref;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

use crate::db::member_list_wrapper::MemberListWrapper;
use crate::grpc::group_service::{GroupRoleType, MemberRef};
use ahash::RandomState;
use common::{GroupId, MemberListError, UserId};
use dashmap::DashMap;
use moka::sync::Cache;
use smallvec::SmallVec;

#[derive(Debug)]
struct Shard {
    inner: DashMap<GroupId, Arc<MemberListWrapper>, RandomState>,
}
impl Default for Shard {
    fn default() -> Self { Self { inner: DashMap::with_hasher(RandomState::new()) } }
}

#[derive(Debug)]
pub struct HashShardMap {
    shards: Arc<Vec<Shard>>,
    shard_mask: usize,
    pub per_group_shard: usize,
    user_to_groups: DashMap<UserId, SmallVec<GroupId, 8>, RandomState>,

    page_cache: Cache<(GroupId, usize, usize, u64), Arc<Vec<MemberRef>>>,
    group_ver: DashMap<GroupId, AtomicU64, RandomState>,
}

impl HashShardMap {
    pub fn new(shard_count: usize, per_group_shard: usize) -> Self {
        let n = shard_count.max(1).next_power_of_two();
        let shards = (0..n).map(|_| Shard::default()).collect();
        Self {
            shards: Arc::new(shards),
            shard_mask: n - 1,
            per_group_shard,
            user_to_groups: DashMap::with_hasher(RandomState::new()),
            page_cache: Cache::builder().max_capacity(100_000).build(),
            group_ver: DashMap::with_hasher(RandomState::new()),
        }
    }

    #[inline] fn shard_idx(&self, group_id: GroupId) -> usize { (group_id as usize) & self.shard_mask }
    #[inline] pub fn shard_count(&self) -> usize { self.shard_mask + 1 }

    #[inline]
    pub fn contains_group(&self, group_id: GroupId) -> bool {
        let shard = &self.shards[self.shard_idx(group_id)];
        shard.inner.contains_key(&group_id)
    }

    #[inline]
    fn get_or_create_wrapper(&self, group_id: GroupId) -> Arc<MemberListWrapper> {
        let shard = &self.shards[self.shard_idx(group_id)];
        if let Some(w) = shard.inner.get(&group_id) { return w.clone(); }
        shard.inner.entry(group_id)
            .or_insert_with(|| Arc::new(MemberListWrapper::new_simple()))
            .clone()
    }

    #[inline]
    fn push_group_unique(list: &mut SmallVec<GroupId ,8>, gid: GroupId) {
        if !list.iter().any(|&g| g == gid) { list.push(gid); }
    }

    #[inline]
    fn bump_ver(&self, gid: GroupId) {
        let entry = self.group_ver.entry(gid).or_insert_with(|| AtomicU64::new(0));
        entry.fetch_add(1, Ordering::Relaxed);
    }
    #[inline]
    fn current_ver(&self, gid: GroupId) -> u64 {
        self.group_ver.get(&gid).map(|v| v.load(Ordering::Relaxed)).unwrap_or(0)
    }

    pub fn insert(&self, group_id: GroupId, member: MemberRef) -> Result<(), MemberListError> {
        let wrapper = self.get_or_create_wrapper(group_id);
        wrapper.add(member.clone())?;
        let mut entry = self.user_to_groups.entry(member.id).or_insert_with(SmallVec::new);
        Self::push_group_unique(&mut entry, group_id);
        self.bump_ver(group_id);
        Ok(())
    }

    pub fn insert_many(&self, group_id: GroupId, members: Vec<MemberRef>) -> Result<(), MemberListError> {
        let wrapper = self.get_or_create_wrapper(group_id);
        wrapper.add_many_slice(&members)?;
        for m in members {
            let mut v = self.user_to_groups.entry(m.id).or_insert_with(SmallVec::new);
            Self::push_group_unique(&mut v, group_id);
        }
        self.bump_ver(group_id);
        Ok(())
    }

    pub fn get_page(&self, group_id: GroupId, page: usize, page_size: usize) -> Option<Vec<MemberRef>> {
        let shard = &self.shards[self.shard_idx(group_id)];
        let ver = self.current_ver(group_id);
        let key = (group_id, page, page_size, ver);
        if let Some(cached) = self.page_cache.get(&key) {
            return Some(cached.deref().clone());
        }
        let computed = shard.inner.get(&group_id).map(|w| w.get_page(page, page_size));
        if let Some(ref v) = computed {
            self.page_cache.insert(key, Arc::new(v.clone()));
        }
        computed
    }

    pub fn remove(&self, group_id: GroupId, user_id: UserId) -> Result<bool, MemberListError> {
        let shard = &self.shards[self.shard_idx(group_id)];
        if let Some(wrapper) = shard.inner.get(&group_id) {
            let removed = wrapper.remove(user_id)?;
            if removed {
                if let Some(mut v) = self.user_to_groups.get_mut(&user_id) {
                    if let Some(pos) = v.iter().position(|&g| g == group_id) { v.remove(pos); }
                    if v.is_empty() { drop(v); self.user_to_groups.remove(&user_id); }
                }
                self.bump_ver(group_id);
            }
            Ok(removed)
        } else {
            Ok(false)
        }
    }

    pub fn change_role(&self, group_id: GroupId, user_id: UserId, role: GroupRoleType) -> Result<(), MemberListError> {
        let shard = &self.shards[self.shard_idx(group_id)];
        if let Some(wrapper) = shard.inner.get(&group_id) {
            wrapper.change_role(user_id, role)?;
            self.bump_ver(group_id);
        }
        Ok(())
    }

    pub fn clear(&self, group_id: GroupId) {
        let shard = &self.shards[self.shard_idx(group_id)];
        if let Some(wrapper) = shard.inner.get(&group_id) {
            for m in wrapper.get_all() {
                if let Some(mut v) = self.user_to_groups.get_mut(&m.id) {
                    if let Some(pos) = v.iter().position(|&g| g == group_id) { v.remove(pos); }
                    if v.is_empty() { drop(v); self.user_to_groups.remove(&m.id); }
                }
            }
        }
        shard.inner.remove(&group_id);
        self.bump_ver(group_id);
    }

    pub fn user_group_list(&self, user_id: UserId) -> Vec<GroupId> {
        self.user_to_groups.get(&user_id).map(|v| v.iter().copied().collect()).unwrap_or_default()
    }

    pub fn all_keys(&self) -> Vec<GroupId> {
        let cap: usize = self.shards.iter().map(|s| s.inner.len()).sum();
        let mut keys = Vec::with_capacity(cap);
        for shard in self.shards.iter() {
            for entry in shard.inner.iter() { keys.push(*entry.key()); }
        }
        keys.sort_unstable();
        keys
    }

    pub fn all_keys_by_shard(&self, shard_idx: usize) -> Vec<GroupId> {
        if shard_idx >= self.shards.len() { return Vec::new(); }
        let mut v = Vec::with_capacity(self.shards[shard_idx].inner.len());
        for e in self.shards[shard_idx].inner.iter() { v.push(*e.key()); }
        v.sort_unstable();
        v
    }

    pub fn get_member_by_key(&self, group_id: GroupId) -> Vec<MemberRef> {
        let shard = &self.shards[self.shard_idx(group_id)];
        shard.inner.get(&group_id).map(|w| w.get_all()).unwrap_or_default()
    }

    pub fn get_member_count_by_key(&self, group_id: GroupId) -> usize {
        let shard = &self.shards[self.shard_idx(group_id)];
        shard.inner.get(&group_id).map(|w| w.len()).unwrap_or(0)
    }
}
