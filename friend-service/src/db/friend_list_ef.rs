// src/db/member/friend_list_ef.rs

use parking_lot::RwLock;
use roaring::RoaringTreemap as RB64;
use smallvec::SmallVec;
use common::UserId;
use crate::db::elias_fano::EliasFano;

#[derive(thiserror::Error, Debug)]
pub enum RelationError {
    #[error("invalid user id")]
    InvalidUserId,
    #[error("retry")]
    Retry,
    #[error("internal: {0}")]
    Internal(&'static str),
}

/// 单用户好友表：Base(Elias–Fano) + Δ 缓冲（新增/删除）
/// 读路径：ΔDel 覆盖 -> ΔAdd 覆盖 -> Base
#[derive(Debug)]
pub struct FriendListEf {
    pub base: RwLock<EliasFano>,               // 压缩主存（仅在合并时重建）
    pub delta_add: RwLock<SmallVec<u64, 32>>, // 待新增（小而快）
    pub delta_del: RwLock<SmallVec<u64, 8>>,  // 待删除（小而快）
}

impl FriendListEf {
    #[inline]
    pub fn new() -> Self {
        Self {
            base: RwLock::new(EliasFano::from_sorted(&[])),
            delta_add: RwLock::new(SmallVec::new()),
            delta_del: RwLock::new(SmallVec::new()),
        }
    }

    #[inline]
    fn to_u64(id: UserId) -> Result<u64, RelationError> {
        Ok(id as u64)
    }

    /// 是否为好友（增量优先）
    pub fn contains(&self, other: UserId) -> Result<bool, RelationError> {
        let u = Self::to_u64(other)?;
        if self.delta_del.read().iter().any(|&x| x == u) { return Ok(false); }
        if self.delta_add.read().iter().any(|&x| x == u) { return Ok(true); }
        Ok(self.base.read().contains(u))
    }
    /// 直接用“已升序去重”的好友列表重建 Base（覆盖式），并清空增量区。
    ///
    /// # 约定
    /// - `sorted_unique` 必须是 **严格升序且无重复** 的 `u64` 列表。
    /// - 调用方负责保证数据正确性；本函数在 `debug` 下会做轻量断言，
    ///   `release` 构建将跳过校验以获得最佳性能。
    ///
    /// # 行为
    /// - 在 **锁外** 构建新的 `EliasFano`，然后一次性写入 `base`；
    /// - 清空 `delta_add` / `delta_del`，使得当前状态完全由 `base` 表达。
    pub fn set_base_from_sorted(&self, sorted_unique: &[u64]) {
        // 可选：仅在 debug 下进行单调性与去重断言，release 不做开销
        debug_assert!(
            sorted_unique
                .windows(2)
                .all(|w| w[0] < w[1]),
            "set_base_from_sorted: input must be strictly increasing and unique"
        );

        // 1) 在锁外构建新的 EF，避免长时间持有写锁
        let new_base = EliasFano::from_sorted(sorted_unique);

        // 2) 一次性替换 base
        {
            let mut base_guard = self.base.write();
            *base_guard = new_base;
        }

        // 3) 清空增量缓冲
        self.delta_add.write().clear();
        self.delta_del.write().clear();
    }
    /// 新增好友（写 ΔAdd；若之前被删除则移除删除标记；幂等）
    pub fn add(&self, other: UserId) -> Result<bool, RelationError> {
        let u = Self::to_u64(other)?;
        // 抵消潜在的删除标记
        {
            let mut del = self.delta_del.write();
            if let Some(i) = del.iter().position(|&x| x == u) { del.remove(i); }
        }
        // 已存在则幂等
        if self.contains(other)? { return Ok(false); }
        self.delta_add.write().push(u);
        Ok(true)
    }

    /// 删除好友（写 ΔDel；若尚在 ΔAdd 中则直接抵消；幂等）
    pub fn remove(&self, other: UserId) -> Result<bool, RelationError> {
        let u = Self::to_u64(other)?;
        {
            let mut add = self.delta_add.write();
            if let Some(i) = add.iter().position(|&x| x == u) {
                add.remove(i);
                return Ok(true);
            }
        }
        if self.contains(other)? {
            self.delta_del.write().push(u);
            return Ok(true);
        }
        Ok(false)
    }

    /// 取全部好友（合并视图），升序去重
    pub fn snapshot_all(&self) -> Vec<u64> {
        let base = self.base.read().to_vec();        // EF -> Vec<u64>（升序）
        let add  = self.delta_add.read().clone();    // 小向量，拷一份
        let del  = self.delta_del.read().clone();

        // 合并 base 与 add（都升序）
        let mut out = Vec::with_capacity(base.len() + add.len());
        out.extend_from_slice(&base);

        let mut add_sorted = add.to_vec();
        add_sorted.sort_unstable();
        add_sorted.dedup();
        out.extend(add_sorted.into_iter());

        out.sort_unstable();
        out.dedup();

        if !del.is_empty() {
            // 小集合删除，线性/二分都可，这里用 binary_search
            for d in del.iter() {
                if let Ok(idx) = out.binary_search(d) {
                    out.remove(idx);
                }
            }
        }
        out
    }

    /// 分页（升序）
    pub fn get_page(&self, page: usize, page_size: usize) -> Vec<u64> {
        if page_size == 0 { return Vec::new(); }
        let all = self.snapshot_all();
        let start = page.saturating_mul(page_size);
        all.into_iter().skip(start).take(page_size).collect()
    }

    /// 与**全局在线**位图求交（遍历好友 + contains）
    pub fn online_with_global(&self, global_online: &RB64) -> Vec<u64> {
        let all = self.snapshot_all();
        let mut out = Vec::with_capacity(all.len().min(256));
        for uid in all {
            if global_online.contains(uid) { out.push(uid); }
        }
        out
    }

    /// 达阈值或定时触发：把 Δ 归并进 EF Base（重建一次）
    pub fn maybe_compact(&self, add_thresh: usize, del_thresh: usize) {
        let add_len = self.delta_add.read().len();
        let del_len = self.delta_del.read().len();
        if add_len < add_thresh && del_len < del_thresh { return; }

        // 合并后重建 EF
        let merged = self.snapshot_all();              // 升序去重
        let new_base = EliasFano::from_sorted(&merged);

        {
            let mut b = self.base.write();
            *b = new_base;
        }
        self.delta_add.write().clear();
        self.delta_del.write().clear();
    }

    // —— 轻量只读计数（给 MemberRelation 估算用）——
    #[inline] pub fn base_len(&self) -> usize { self.base.read().len() }
    #[inline] pub fn delta_add_len(&self) -> usize { self.delta_add.read().len() }
    #[inline] pub fn delta_del_len(&self) -> usize { self.delta_del.read().len() }
}
