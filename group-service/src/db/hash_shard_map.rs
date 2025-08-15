use std::ops::Deref;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;

use ahash::RandomState;
use dashmap::DashMap;
use moka::sync::{Cache, CacheBuilder};
use smallvec::SmallVec;

use crate::db::member_list_wrapper::MemberListWrapper;
use crate::grpc::group_service::{GroupRoleType, MemberRef};
use common::{GroupId, MemberListError, UserId};

/// 单个分片
#[derive(Debug)]
struct Shard {
    inner: DashMap<GroupId, Arc<MemberListWrapper>, RandomState>,
}
impl Default for Shard {
    fn default() -> Self {
        Self { inner: DashMap::with_hasher(RandomState::new()) }
    }
}

/// 分片管理的群成员映射
#[derive(Debug)]
pub struct HashShardMap {
    shards: Arc<Vec<Shard>>,
    shard_mask: usize,
    pub per_group_shard: usize,

    /// user_id -> groups
    user_to_groups: DashMap<UserId, SmallVec<[GroupId; 8]>, RandomState>,

    /// 分页缓存（零拷贝命中）：key=(gid,page,size,ver) -> Arc<[MemberRef]>
    page_cache: Cache<(GroupId, usize, usize, u64), Arc<[MemberRef]>>,

    /// 群版本号（写后 bump，使旧页逻辑失效）
    group_ver: DashMap<GroupId, AtomicU64, RandomState>,
}

impl HashShardMap {
    /// 构造函数
    /// - `shard_count` 向上取 2 的幂，便于与运算
    /// - `per_group_shard` 预留字段
    pub fn new(shard_count: usize, per_group_shard: usize) -> Self {
        let n = shard_count.max(1).next_power_of_two();
        let shards = (0..n).map(|_| Shard::default()).collect();

        // 分页缓存：按“条数”计权；容量 10 万条成员（可自行调整）。
        // 如需时间淘汰，可加 .time_to_idle(Duration::from_secs(300))
        let page_cache: Cache<(GroupId, usize, usize, u64), Arc<[MemberRef]>> =
            CacheBuilder::new(100_000 /* max_weight */)
                .weigher(|_k, v: &Arc<[MemberRef]>| v.len() as u32)
                .build();

        Self {
            shards: Arc::new(shards),
            shard_mask: n - 1,
            per_group_shard,
            user_to_groups: DashMap::with_hasher(RandomState::new()),
            page_cache,
            group_ver: DashMap::with_hasher(RandomState::new()),
        }
    }

    #[inline]
    fn shard_idx(&self, gid: GroupId) -> usize { (gid as usize) & self.shard_mask }

    /// 分片总数
    #[inline]
    pub fn shard_count(&self) -> usize { self.shard_mask + 1 }

    /// group 是否存在
    #[inline]
    pub fn contains_group(&self, gid: GroupId) -> bool {
        self.shards[self.shard_idx(gid)].inner.contains_key(&gid)
    }

    /// 获取或创建包装器
    #[inline]
    fn get_or_create_wrapper(&self, gid: GroupId) -> Arc<MemberListWrapper> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(w) = shard.inner.get(&gid) { return w.clone(); }
        shard.inner.entry(gid).or_insert_with(|| Arc::new(MemberListWrapper::new_simple())).clone()
    }

    #[inline]
    fn push_group_unique(list: &mut SmallVec<[GroupId; 8]>, gid: GroupId) {
        if !list.iter().any(|&g| g == gid) { list.push(gid); }
    }

    #[inline]
    fn bump_ver(&self, gid: GroupId) {
        let e = self.group_ver.entry(gid).or_insert_with(|| AtomicU64::new(0));
        e.fetch_add(1, Ordering::Relaxed);
    }

    #[inline]
    fn current_ver(&self, gid: GroupId) -> u64 {
        self.group_ver.get(&gid).map(|v| v.load(Ordering::Relaxed)).unwrap_or(0)
    }

    // ---------------- 写路径 ----------------

    pub fn insert(&self, gid: GroupId, member: MemberRef) -> Result<(), MemberListError> {
        let wrapper = self.get_or_create_wrapper(gid);
        wrapper.add(member.clone())?;
        let mut entry = self.user_to_groups.entry(member.id).or_insert_with(SmallVec::new);
        Self::push_group_unique(&mut entry, gid);
        self.bump_ver(gid);
        Ok(())
    }

    pub fn insert_many(&self, gid: GroupId, members: Vec<MemberRef>) -> Result<(), MemberListError> {
        let wrapper = self.get_or_create_wrapper(gid);
        wrapper.add_many_slice(&members)?;
        for m in members {
            let mut v = self.user_to_groups.entry(m.id).or_insert_with(SmallVec::new);
            Self::push_group_unique(&mut v, gid);
        }
        self.bump_ver(gid);
        Ok(())
    }

    pub fn remove(&self, gid: GroupId, uid: UserId) -> Result<bool, MemberListError> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            let removed = wrapper.remove(uid)?;
            if removed {
                if let Some(mut v) = self.user_to_groups.get_mut(&uid) {
                    if let Some(pos) = v.iter().position(|&g| g == gid) { v.remove(pos); }
                    if v.is_empty() { drop(v); self.user_to_groups.remove(&uid); }
                }
                self.bump_ver(gid);
            }
            Ok(removed)
        } else {
            Ok(false)
        }
    }

    pub fn change_role(&self, gid: GroupId, uid: UserId, role: GroupRoleType) -> Result<(), MemberListError> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            wrapper.change_role(uid, role)?;
            self.bump_ver(gid);
        }
        Ok(())
    }

    /// 新增：修改/清空别名
    pub fn change_alias(&self, gid: GroupId, uid: UserId, alias: Option<String>) -> Result<(), MemberListError> {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            wrapper.change_alias(uid, alias)?;
            self.bump_ver(gid);
        }
        Ok(())
    }

    /// 清空群成员，并维护反向索引
    pub fn clear(&self, gid: GroupId) {
        let shard = &self.shards[self.shard_idx(gid)];
        if let Some(wrapper) = shard.inner.get(&gid) {
            for m in wrapper.get_all() {
                if let Some(mut v) = self.user_to_groups.get_mut(&m.id) {
                    if let Some(pos) = v.iter().position(|&g| g == gid) { v.remove(pos); }
                    if v.is_empty() { drop(v); self.user_to_groups.remove(&m.id); }
                }
            }
        }
        shard.inner.remove(&gid);
        self.bump_ver(gid);
    }

    // ---------------- 读路径 ----------------

    /// 快路径：零拷贝命中缓存，返回 Arc<[MemberRef]>
    /// 调用者若需要 Vec 再 `to_vec()`，但建议尽量在内部用切片引用以减少拷贝。
    pub fn get_page_arc(
        &self,
        gid: GroupId,
        page: usize,
        page_size: usize,
    ) -> Option<Arc<[MemberRef]>> {
        if page_size == 0 { return Some(Arc::from([])); }

        let ver = self.current_ver(gid);
        let key = (gid, page, page_size, ver);

        if let Some(cached) = self.page_cache.get(&key) {
            return Some(cached.clone()); // O(1) 引用计数，零拷贝
        }

        // miss：计算一页
        let shard = &self.shards[self.shard_idx(gid)];
        let computed = shard.inner.get(&gid).map(|w| w.get_page(page, page_size));

        if let Some(v) = computed {
            // 仅在 miss 时做一次分配，缓存为切片 Arc
            let arc_slice: Arc<[MemberRef]> = Arc::from(v);
            // 注意：weigher 以 len 计权；这里不会重复复制
            self.page_cache.insert(key, arc_slice.clone());
            Some(arc_slice)
        } else {
            None
        }
    }

    /// 兼容旧接口：返回 Vec<MemberRef>（会从缓存的 Arc<[T]> 克隆元素）
    pub fn get_page(&self, gid: GroupId, page: usize, page_size: usize) -> Option<Vec<MemberRef>> {
        self.get_page_arc(gid, page, page_size).map(|arc_slice| arc_slice.deref().to_vec())
    }

    /// 某用户的所有群组
    pub fn user_group_list(&self, uid: UserId) -> Vec<GroupId> {
        self.user_to_groups.get(&uid).map(|v| v.iter().copied().collect()).unwrap_or_default()
    }

    /// 全部群组ID
    pub fn all_keys(&self) -> Vec<GroupId> {
        let cap: usize = self.shards.iter().map(|s| s.inner.len()).sum();
        let mut keys = Vec::with_capacity(cap);
        for shard in self.shards.iter() {
            for e in shard.inner.iter() { keys.push(*e.key()); }
        }
        keys.sort_unstable();
        keys
    }

    /// 指定分片的群组ID
    pub fn all_keys_by_shard(&self, idx: usize) -> Vec<GroupId> {
        if idx >= self.shards.len() { return Vec::new(); }
        let mut v = Vec::with_capacity(self.shards[idx].inner.len());
        for e in self.shards[idx].inner.iter() { v.push(*e.key()); }
        v.sort_unstable();
        v
    }

    /// 某群全部成员（快照）
    pub fn get_member_by_key(&self, gid: GroupId) -> Vec<MemberRef> {
        self.shards[self.shard_idx(gid)]
            .inner
            .get(&gid)
            .map(|w| w.get_all())
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

    /// （可选）设置分页缓存 TTI，便于回收冷页
    pub fn set_page_cache_tti(&self, seconds: u64) {
        // moka 的 builder 才能设 TTI；这里给个示例可在 new(...) 里直接设：
        // self.page_cache = CacheBuilder::new(...)
        //    .weigher(...)
        //    .time_to_idle(Duration::from_secs(seconds))
        //    .build();
        let _ = seconds; // 提示：如需切换 TTI，请在构造时设定
    }
}
