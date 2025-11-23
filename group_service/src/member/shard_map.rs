use std::ops::Deref;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;

use ahash::RandomState;
use dashmap::DashMap;
use moka::sync::{Cache, CacheBuilder};
use smallvec::SmallVec;

use crate::member::list_wrapper::MemberListWrapper;
use common::infra::grpc::grpc_group::group_service::{GroupRoleType, MemberRef};
use common::{GroupId, MemberListError, UID};

/// 单个分片：gid -> 成员包装器
#[derive(Debug)]
struct Shard {
    inner: DashMap<GroupId, Arc<MemberListWrapper>, RandomState>,
}
impl Default for Shard {
    fn default() -> Self {
        Self {
            inner: DashMap::with_hasher(RandomState::new()),
        }
    }
}

/// 分片管理的群成员映射（线程安全，读写并发友好）
/// - shards：按 gid 做 2^n 分片，降低竞争
/// - user_to_groups：用户 -> 加入的群列表（用于快速反查）
/// - group_ver：群版本号（每次写后 bump；分页缓存 key 中携带 ver）
/// - page_cache：分页结果缓存（key = (gid, page, size, ver) -> Arc<[MemberRef]>）
///   * 命中零拷贝；miss 时仅在插入时分配一次 Arc<[T]>
#[derive(Debug)]
pub struct ShardMap {
    shards: Arc<Vec<Shard>>,
    shard_mask: usize,
    per_group_shard: usize,

    user_to_groups: DashMap<UID, SmallVec<[GroupId; 8]>, RandomState>,

    page_cache: Cache<(GroupId, usize, usize, u64), Arc<[MemberRef]>>,

    group_ver: DashMap<GroupId, AtomicU64, RandomState>,

    /// 分页大小的下限（避免 0）
    min_page_size: usize,
    /// 分页大小的上限（防止超大页造成内存尖刺）
    max_page_size: usize,
}

impl ShardMap {
    /// 构造函数
    /// - `shard_count` 向上取 2 的幂，便于与运算
    /// - `per_group_shard` 预留（未来可用于超大群的内部再分片）
    /// - `page_cache_capacity` 以“成员条数”计权（weigher 返回切片长度）
    /// - `page_cache_tti` 可选，设置分页缓存的 idle 过期
    pub fn new(
        shard_count: usize,
        per_group_shard: usize,
        page_cache_capacity: u32,
        page_cache_tti: Option<Duration>,
    ) -> Self {
        let n = shard_count.max(1).next_power_of_two();
        let shards = (0..n).map(|_| Shard::default()).collect();

        // 分页缓存：按“条数”计权；容量 = page_cache_capacity 条成员
        let mut builder: CacheBuilder<(GroupId, usize, usize, u64), Arc<[MemberRef]>, _> =
            Cache::builder().weigher(|_k, v: &Arc<[MemberRef]>| v.len() as u32);
        builder = builder.max_capacity(page_cache_capacity as u64);
        if let Some(tti) = page_cache_tti {
            builder = builder.time_to_idle(tti);
        }
        let page_cache = builder.build();

        Self {
            shards: Arc::new(shards),
            shard_mask: n - 1,
            per_group_shard,
            user_to_groups: DashMap::with_hasher(RandomState::new()),
            page_cache,
            group_ver: DashMap::with_hasher(RandomState::new()),
            min_page_size: 1,
            max_page_size: 10_000, // 可按需调大/动态配置
        }
    }

    #[inline]
    fn shard_idx(&self, gid: GroupId) -> usize {
        (gid as usize) & self.shard_mask
    }

    /// 分片总数
    #[inline]
    pub fn shard_count(&self) -> usize {
        self.shard_mask + 1
    }

    /// group 是否存在
    #[inline]
    pub fn contains_group(&self, gid: GroupId) -> bool {
        self.shards[self.shard_idx(gid)].inner.contains_key(&gid)
    }

    /// 获取或创建包装器
    #[inline]
    fn get_or_create_wrapper(&self, gid: GroupId) -> Arc<MemberListWrapper> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(w) = shard.inner.get(&gid) {
            return w.clone();
        }
        shard
            .inner
            .entry(gid)
            .or_insert_with(|| Arc::new(MemberListWrapper::new_simple()))
            .clone()
    }

    #[inline]
    fn push_group_unique(list: &mut SmallVec<[GroupId; 8]>, gid: GroupId) {
        if !list.iter().any(|&g| g == gid) {
            list.push(gid);
        }
    }

    #[inline]
    fn bump_ver(&self, gid: GroupId) {
        let e = self
            .group_ver
            .entry(gid)
            .or_insert_with(|| AtomicU64::new(0));
        e.fetch_add(1, Ordering::Relaxed);
        // 主动使该 gid 的旧页失效，释放缓存压力
        self.invalidate_gid_pages(gid);
    }

    #[inline]
    fn current_ver(&self, gid: GroupId) -> u64 {
        self.group_ver
            .get(&gid)
            .map(|v| v.load(Ordering::Relaxed))
            .unwrap_or(0)
    }

    /// 主动剔除某个 gid 的所有旧分页（减少过期页堆积）
    fn invalidate_gid_pages(&self, gid: GroupId) {
        // key: &(GroupId, usize, usize, u64), value: &Arc<[MemberRef]>
        let _ = self
            .page_cache
            .invalidate_entries_if(move |&(k_gid, _, _, _), _| k_gid == gid);
    }

    /// 维护反向索引（添加）
    #[inline]
    fn index_add(&self, uid: UID, gid: GroupId) {
        let mut entry = self.user_to_groups.entry(uid).or_insert_with(SmallVec::new);
        Self::push_group_unique(&mut entry, gid);
    }

    /// 维护反向索引（删除）
    #[inline]
    fn index_remove(&self, uid: UID, gid: GroupId) {
        if let Some(mut v) = self.user_to_groups.get_mut(&uid) {
            if let Some(pos) = v.iter().position(|&g| g == gid) {
                v.remove(pos);
            }
            if v.is_empty() {
                drop(v);
                self.user_to_groups.remove(&uid);
            }
        }
    }

    /// 规范化页大小
    #[inline]
    fn clamp_page_size(&self, size: usize) -> usize {
        size.clamp(self.min_page_size, self.max_page_size)
    }

    // ---------------- 写路径 ----------------

    pub fn insert(&self, gid: GroupId, member: MemberRef) -> Result<(), MemberListError> {
        let wrapper = self.get_or_create_wrapper(gid);
        wrapper.add(member.clone())?;
        self.index_add(member.id, gid);
        self.bump_ver(gid);
        Ok(())
    }

    pub fn insert_many(
        &self,
        gid: GroupId,
        members: Vec<MemberRef>,
    ) -> Result<(), MemberListError> {
        if members.is_empty() {
            return Ok(());
        }
        let wrapper = self.get_or_create_wrapper(gid);
        wrapper.add_many_slice(&members)?;
        for m in members {
            self.index_add(m.id, gid);
        }
        self.bump_ver(gid);
        Ok(())
    }

    pub fn remove(&self, gid: GroupId, uid: UID) -> Result<bool, MemberListError> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            let removed = wrapper.remove(uid)?;
            if removed {
                self.index_remove(uid, gid);
                self.bump_ver(gid);
            }
            Ok(removed)
        } else {
            Ok(false)
        }
    }

    pub fn change_role(
        &self,
        gid: GroupId,
        uid: UID,
        role: GroupRoleType,
    ) -> Result<(), MemberListError> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            wrapper.change_role(uid, role)?;
            self.bump_ver(gid);
        }
        Ok(())
    }

    /// 修改/清空昵称
    pub fn change_nickname(
        &self,
        gid: GroupId,
        uid: UID,
        nickname: Option<String>,
    ) -> Result<(), MemberListError> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            wrapper.change_nickname(uid, nickname)?;
            self.bump_ver(gid);
        }
        Ok(())
    }

    /// 清空群成员，并维护反向索引
    pub fn clear(&self, gid: GroupId) {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            for m in wrapper.get_all() {
                self.index_remove(m.id, gid);
            }
        }
        shard.inner.remove(&gid);
        self.bump_ver(gid);
    }

    // ---------------- 读路径 ----------------

    /// 零拷贝命中缓存，返回 Arc<[MemberRef]>；miss 时构建并缓存
    pub fn get_page_arc(
        &self,
        gid: GroupId,
        page: usize,
        page_size: usize,
    ) -> Option<Arc<[MemberRef]>> {
        let page_size = self.clamp_page_size(page_size);

        let ver = self.current_ver(gid);
        let key = (gid, page, page_size, ver);

        if let Some(cached) = self.page_cache.get(&key) {
            return Some(cached.clone()); // O(1) 引用计数，零拷贝
        }

        let shard = &self.shards[self.shard_idx(gid)];
        let computed = shard.inner.get(&gid).map(|w| w.get_page(page, page_size));
        if let Some(v) = computed {
            let arc_slice: Arc<[MemberRef]> = Arc::from(v);
            self.page_cache.insert(key, arc_slice.clone());
            Some(arc_slice)
        } else {
            None
        }
    }

    /// 兼容旧接口：返回 Vec<MemberRef>
    pub fn get_page(&self, gid: GroupId, page: usize, page_size: usize) -> Option<Vec<MemberRef>> {
        self.get_page_arc(gid, page, page_size)
            .map(|arc_slice| arc_slice.deref().to_vec())
    }

    /// 返回全量成员（零拷贝切片）
    pub fn get_all_arc(&self, gid: GroupId) -> Option<Arc<[MemberRef]>> {
        let shard = &self.shards[self.shard_idx(gid)];
        shard.inner.get(&gid).map(|w| Arc::from(w.get_all()))
    }

    /// 某用户的所有群组
    pub fn user_group_list(&self, uid: UID) -> Vec<GroupId> {
        self.user_to_groups
            .get(&uid)
            .map(|v| v.iter().copied().collect())
            .unwrap_or_default()
    }

    /// 全部群组ID
    pub fn all_keys(&self) -> Vec<GroupId> {
        let cap: usize = self.shards.iter().map(|s| s.inner.len()).sum();
        let mut keys = Vec::with_capacity(cap);
        for shard in self.shards.iter() {
            for e in shard.inner.iter() {
                keys.push(*e.key());
            }
        }
        keys.sort_unstable();
        keys
    }

    /// 指定分片的群组ID
    pub fn all_keys_by_shard(&self, idx: usize) -> Vec<GroupId> {
        if idx >= self.shards.len() {
            return Vec::new();
        }
        let mut v = Vec::with_capacity(self.shards[idx].inner.len());
        for e in self.shards[idx].inner.iter() {
            v.push(*e.key());
        }
        v.sort_unstable();
        v
    }

    /// 某群全部成员（Vec 快照）
    pub fn get_member_by_key(&self, gid: GroupId) -> Vec<MemberRef> {
        self.shards[self.shard_idx(gid)]
            .inner
            .get(&gid)
            .map(|w| w.get_all())
            .unwrap_or_default()
    }

    /// 群管理员列表（Owner + Admin）
    pub fn get_managers_by_key(&self, gid: GroupId) -> Vec<MemberRef> {
        self.shards[self.shard_idx(gid)]
            .inner
            .get(&gid)
            .map(|w| w.get_managers())
            .unwrap_or_default()
    }

    /// 某群成员总数
    pub fn get_member_count_by_key(&self, gid: GroupId) -> usize {
        self.shards[self.shard_idx(gid)]
            .inner
            .get(&gid)
            .map(|w| w.len())
            .unwrap_or(0)
    }

    // ---------------- 可选：运行时调优 ----------------

    /// 调整分页大小阈值（避免异常参数）
    pub fn set_page_size_bounds(&mut self, min_size: usize, max_size: usize) {
        self.min_page_size = min_size.max(1);
        self.max_page_size = max_size.max(self.min_page_size);
    }
}
