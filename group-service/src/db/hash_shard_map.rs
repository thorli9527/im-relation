//! hash_shard_map.rs — 重新整理版
//! - Snowflake: GroupId/UserId = i64（非负）
//! - 分片容器：DashMap<GroupId, Arc<MemberListWrapper>>
//! - 反向索引：user_id -> groups（SmallVec，省内存）
//! - 集成好友关系：MemberRelation（与本结构使用相同分片数）
//! - 提供分段扫描 API：all_keys_by_shard()

use std::sync::Arc;

use dashmap::DashMap;
use smallvec::SmallVec;
use common::{GroupId, MemberListError, UserId};
use crate::db::member_list_wrapper::MemberListWrapper;
use crate::grpc::group_service::{GroupRoleType, MemberRef};

/// 统一组 ID（Snowflake）

/// 单分片
#[derive(Debug, Default)]
struct Shard {
    inner: DashMap<GroupId, Arc<MemberListWrapper>>,
}

/// group -> MemberListWrapper + 反向索引 + 好友关系
#[derive(Debug, Clone)]
pub struct HashShardMap {
    shards: Arc<Vec<Shard>>,
    pub per_group_shard: usize,
    user_to_groups: DashMap<UserId, SmallVec<[GroupId; 8]>>,
}

impl HashShardMap {
    /// `shard_count` 建议与 CPU 核数倍数一致（32/64/128）
    pub fn new(shard_count: usize, per_group_shard: usize) -> Self {
        let shards = (0..shard_count.max(1)).map(|_| Shard::default()).collect();
        Self {
            shards: Arc::new(shards),
            per_group_shard,
            user_to_groups: DashMap::new(),
        }
    }

    #[inline]
    fn shard_idx(&self, group_id: GroupId) -> usize {
        (group_id as u64 % self.shards.len() as u64) as usize
    }

    /// O(1) 获取/创建群容器
    fn get_or_create_wrapper(&self, group_id: GroupId) -> Arc<MemberListWrapper> {
        let shard = &self.shards[self.shard_idx(group_id)];
        if let Some(w) = shard.inner.get(&group_id) {
            return w.clone();
        }
        shard
            .inner
            .entry(group_id)
            .or_insert_with(|| Arc::new(MemberListWrapper::new_simple()))
            .clone()
    }

    #[inline]
    fn push_group_unique(list: &mut SmallVec<[GroupId; 8]>, gid: GroupId) {
        if !list.iter().any(|&g| g == gid) {
            list.push(gid);
        }
    }

    // =============== 群成员相关 API ===============

    /// 插入单个成员（并更新反向索引）
    pub fn insert(&self, group_id: GroupId, member: MemberRef) -> Result<(), MemberListError> {
        let wrapper = self.get_or_create_wrapper(group_id);
        wrapper.add(member.clone())?;

        let mut entry = self.user_to_groups.entry(member.id).or_insert_with(SmallVec::new);
        Self::push_group_unique(&mut entry, group_id);
        Ok(())
    }

    /// 批量插入（并更新反向索引）
    pub fn insert_many(&self, group_id: GroupId, members: Vec<MemberRef>) -> Result<(), MemberListError> {
        let wrapper = self.get_or_create_wrapper(group_id);
        wrapper.add_many(members.clone())?;
        for m in members {
            let mut v = self.user_to_groups.entry(m.id).or_insert_with(SmallVec::new);
            Self::push_group_unique(&mut v, group_id);
        }
        Ok(())
    }

    /// 分页读取
    pub fn get_page(&self, group_id: GroupId, page: usize, page_size: usize) -> Option<Vec<MemberRef>> {
        let shard = &self.shards[self.shard_idx(group_id)];
        shard.inner.get(&group_id).map(|w| w.get_page(page, page_size))
    }



    /// 删除成员（并维护反向索引）
    pub fn remove(&self, group_id: GroupId, user_id: UserId) -> Result<bool, MemberListError> {
        let shard = &self.shards[self.shard_idx(group_id)];
        if let Some(wrapper) = shard.inner.get(&group_id) {
            let removed = wrapper.remove(user_id)?;
            if removed {
                if let Some(mut v) = self.user_to_groups.get_mut(&user_id) {
                    if let Some(pos) = v.iter().position(|&g| g == group_id) { v.remove(pos); }
                    if v.is_empty() { drop(v); self.user_to_groups.remove(&user_id); }
                }
            }
            Ok(removed)
        } else {
            Ok(false)
        }
    }



    /// 改变角色
    pub fn change_role(&self, group_id: GroupId, user_id: UserId, role: GroupRoleType) -> Result<(), MemberListError> {
        let shard = &self.shards[self.shard_idx(group_id)];
        if let Some(wrapper) = shard.inner.get(&group_id) {
            wrapper.change_role(user_id, role)?;
        }
        Ok(())
    }

    /// 清空群（含反向索引清理）
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
    }

    /// 用户所在群列表
    pub fn user_group_list(&self, user_id: UserId) -> Vec<GroupId> {
        self.user_to_groups
            .get(&user_id)
            .map(|v| v.iter().copied().collect())
            .unwrap_or_default()
    }

    /// 所有群 key（一次性）
    pub fn all_keys(&self) -> Vec<GroupId> {
        let cap: usize = self.shards.iter().map(|s| s.inner.len()).sum();
        let mut keys = Vec::with_capacity(cap);
        for shard in self.shards.iter() {
            for entry in shard.inner.iter() {
                keys.push(*entry.key());
            }
        }
        keys.sort_unstable();
        keys
    }

    /// 按分片获取 key（便于分段扫描）
    pub fn all_keys_by_shard(&self, shard_idx: usize) -> Vec<GroupId> {
        if shard_idx >= self.shards.len() { return Vec::new(); }
        let mut v = Vec::with_capacity(self.shards[shard_idx].inner.len());
        for e in self.shards[shard_idx].inner.iter() { v.push(*e.key()); }
        v.sort_unstable();
        v
    }

    /// 群成员（全量）
    pub fn get_member_by_key(&self, group_id: GroupId) -> Vec<MemberRef> {
        let shard = &self.shards[self.shard_idx(group_id)];
        shard.inner.get(&group_id).map(|w| w.get_all()).unwrap_or_default()
    }

    /// 群成员数量
    pub fn get_member_count_by_key(&self, group_id: GroupId) -> usize {
        let shard = &self.shards[self.shard_idx(group_id)];
        shard.inner.get(&group_id).map(|w| w.len()).unwrap_or(0)
    }

    /// 分片总数
    #[inline] pub fn shard_count(&self) -> usize { self.shards.len() }


}
