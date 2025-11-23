use parking_lot::RwLock;
use roaring::RoaringTreemap as RB64;
use smallvec::SmallVec;
use std::collections::HashMap;

use crate::db::elias_fano::EliasFano;
use common::UID;

pub type FriendId = u64;

#[derive(thiserror::Error, Debug)]
pub enum RelationError {
    #[error("invalid user id")]
    InvalidUID,
    #[error("retry")]
    Retry,
    #[error("internal: {0}")]
    Internal(&'static str),
}

/// 单用户好友表：Base(Elias–Fano) + Δ 缓冲（新增/删除）
/// 读路径：ΔDel 覆盖 -> ΔAdd 覆盖 -> Base
#[derive(Debug)]
pub struct FriendListEf {
    // ===== 好友集合 =====
    /// 压缩主存（仅在合并时重建）；保证内部升序
    pub base: RwLock<EliasFano>,
    /// 待新增（小而快，不保证有序）
    pub delta_add: RwLock<SmallVec<[FriendId; 32]>>,
    /// 待删除（小而快，不保证有序）
    pub delta_del: RwLock<SmallVec<[FriendId; 8]>>,

    // ===== 别名：并行三层结构（无享元） =====
    /// 稳定面：随 base 对齐
    pub nickname_base: RwLock<HashMap<FriendId, String>>,
    /// ΔAdd：新增/更新别名
    pub nickname_add: RwLock<HashMap<FriendId, String>>,
    /// ΔDel：清除别名标记（小集合）
    pub nickname_del: RwLock<SmallVec<[FriendId; 8]>>,
}

impl Default for FriendListEf {
    #[inline]
    fn default() -> Self {
        Self::new()
    }
}

impl FriendListEf {
    #[inline]
    pub fn new() -> Self {
        Self {
            base: RwLock::new(EliasFano::from_sorted(&[])),
            delta_add: RwLock::new(SmallVec::new()),
            delta_del: RwLock::new(SmallVec::new()),
            nickname_base: RwLock::new(HashMap::new()),
            nickname_add: RwLock::new(HashMap::new()),
            nickname_del: RwLock::new(SmallVec::new()),
        }
    }

    // ====================== 私有工具函数 ======================

    /// 小集合移除一个元素（线性扫描即可）
    #[inline]
    fn smallvec_remove_one(v: &mut SmallVec<[FriendId; 8]>, x: FriendId) -> bool {
        if let Some(i) = v.iter().position(|&t| t == x) {
            v.remove(i);
            true
        } else {
            false
        }
    }

    /// 小集合是否包含（线性）
    #[inline]
    fn smallvec_contains(v: &SmallVec<[FriendId; 8]>, x: FriendId) -> bool {
        v.iter().any(|&t| t == x)
    }

    /// 清理别名的增量标记（在 remove 路径中复用）
    #[inline]
    fn clear_nickname_deltas_for(&self, uid: FriendId) {
        self.nickname_add.write().remove(&uid);
        // retain 的闭包参数是 &T（&u64），这里用 != 保留非目标
        self.nickname_del.write().retain(|&mut x| x != uid);
    }

    // ====================== 别名 API（无享元） ======================

    /// 设置/更新别名；传 None 表示清除别名
    pub fn set_nickname<S: Into<String>>(
        &self,
        other: UID,
        nickname: Option<S>,
    ) -> Result<(), RelationError> {
        let u = other as FriendId;

        if let Some(a) = nickname {
            // 先去掉“删除”标记，再写入/覆盖 ΔAdd
            {
                let mut del = self.nickname_del.write();
                Self::smallvec_remove_one(&mut del, u);
            }
            self.nickname_add.write().insert(u, a.into());
        } else {
            // 标记删除别名，并从 ΔAdd 清除
            self.nickname_add.write().remove(&u);
            self.nickname_del.write().push(u);
        }
        Ok(())
    }

    /// 获取别名（ΔDel -> ΔAdd -> Base），返回克隆的 String 给上层使用
    pub fn get_nickname(&self, other: UID) -> Result<Option<String>, RelationError> {
        let u = other as FriendId;

        // 这里尽量减少锁分段；小集合 + 哈希查找都很快
        {
            let del = self.nickname_del.read();
            if Self::smallvec_contains(&del, u) {
                return Ok(None);
            }
        }
        if let Some(a) = self.nickname_add.read().get(&u) {
            return Ok(Some(a.clone()));
        }
        Ok(self.nickname_base.read().get(&u).cloned())
    }

    // ====================== 关系 API ======================

    /// 是否为好友（增量优先）
    pub fn contains(&self, other: UID) -> Result<bool, RelationError> {
        let u = other as FriendId;

        // ΔDel 命中则直接否
        if Self::smallvec_contains(&self.delta_del.read(), u) {
            return Ok(false);
        }
        // ΔAdd 命中则直接是
        if self.delta_add.read().iter().any(|&t| t == u) {
            return Ok(true);
        }
        // 回落到基线
        Ok(self.base.read().contains(u))
    }

    /// 覆盖式重建 Base，并清空关系增量；同步剪枝 nickname_base
    pub fn set_base_from_sorted(&self, sorted_unique: &[FriendId]) {
        debug_assert!(
            sorted_unique.windows(2).all(|w| w[0] < w[1]),
            "set_base_from_sorted: input must be strictly increasing and unique"
        );

        // 1) 锁外构建新的 EF，避免长时间持有写锁
        let new_base = EliasFano::from_sorted(sorted_unique);

        // 2) 一次性替换 base
        *self.base.write() = new_base;

        // 3) 清空关系增量
        self.delta_add.write().clear();
        self.delta_del.write().clear();

        // 4) 剪枝别名基线：只保留仍在好友集合内的条目
        {
            let mut ab = self.nickname_base.write();
            // 避免在迭代中修改：先收集 key
            let keys: Vec<_> = ab.keys().cloned().collect();
            for k in keys {
                if sorted_unique.binary_search(&k).is_err() {
                    ab.remove(&k);
                }
            }
        }
        // 注意：别名 Δ 不清空；允许继续覆盖到新基线
    }

    /// 新增好友（写 ΔAdd；若之前被删除则移除删除标记；幂等）
    pub fn add(&self, other: UID) -> Result<bool, RelationError> {
        let u = other as FriendId;

        // 先从 ΔDel 抵消
        {
            let mut del = self.delta_del.write();
            Self::smallvec_remove_one(&mut del, u);
        }

        // 已存在则幂等返回 false
        if self.contains(other)? {
            return Ok(false);
        }

        self.delta_add.write().push(u);
        Ok(true)
    }

    /// 新增好友并可附带别名（仅在“确实新增”时写入别名，不影响已存在关系）
    pub fn add_with_nickname<S: Into<String>>(
        &self,
        other: UID,
        nickname: Option<S>,
    ) -> Result<bool, RelationError> {
        let added = self.add(other)?;
        if added {
            if let Some(a) = nickname {
                // 不需要传播错误（infallible）
                let _ = self.set_nickname(other, Some(a));
            }
        }
        Ok(added)
    }

    /// 删除好友（写 ΔDel；若尚在 ΔAdd 中则直接抵消；幂等）
    /// 同步清理别名的增量标记；Base 中的别名将于 compact 时被剪除
    pub fn remove(&self, other: UID) -> Result<bool, RelationError> {
        let u = other as FriendId;

        // 若还在 ΔAdd，直接抵消（不进入 ΔDel）
        {
            let mut add = self.delta_add.write();
            if let Some(i) = add.iter().position(|&x| x == u) {
                add.remove(i);
                self.clear_nickname_deltas_for(u);
                return Ok(true);
            }
        }

        // 不在当前视图就幂等 false
        if !self.contains(other)? {
            return Ok(false);
        }

        self.delta_del.write().push(u);
        self.clear_nickname_deltas_for(u);
        Ok(true)
    }

    /// 取全部好友（合并视图），升序去重
    pub fn snapshot_all(&self) -> Vec<FriendId> {
        // EF -> Vec（升序）
        let base = self.base.read().to_vec();

        // ΔAdd/ΔDel 都是小集合，复制后各自处理
        let mut add = self.delta_add.read().clone();
        let del = self.delta_del.read().clone();

        // 1) add 排序去重
        add.sort_unstable();
        add.dedup();

        // 2) 合并 base(升序) 与 add(升序)
        let mut out = Vec::with_capacity(base.len() + add.len());
        let (mut i, mut j) = (0usize, 0usize);
        while i < base.len() && j < add.len() {
            let (a, b) = (base[i], add[j]);
            if a < b {
                out.push(a);
                i += 1;
            } else if a > b {
                out.push(b);
                j += 1;
            } else {
                // 相同则保一份
                out.push(a);
                i += 1;
                j += 1;
            }
        }
        if i < base.len() {
            out.extend_from_slice(&base[i..]);
        }
        if j < add.len() {
            out.extend_from_slice(&add[j..]);
        }

        // 3) 应用删除（小集合线性扫）
        if !del.is_empty() {
            // del 很小，逐个二分删除也行；但 remove(idx) 是 O(n)，不过 n≈|out|
            // 若更关注极致性能，可收集“保留”集合再一次性重建 out。
            for d in del.iter() {
                if let Ok(idx) = out.binary_search(d) {
                    out.remove(idx);
                }
            }
        }
        out
    }

    /// 取全部（含别名）
    pub fn snapshot_all_detailed(&self) -> Vec<(FriendId, Option<String>)> {
        let all = self.snapshot_all();
        let del = self.nickname_del.read().clone();
        let add = self.nickname_add.read().clone();
        let base = self.nickname_base.read();

        let mut out = Vec::with_capacity(all.len());
        for uid in all {
            if del.iter().any(|&x| x == uid) {
                out.push((uid, None));
                continue;
            }
            if let Some(a) = add.get(&uid) {
                out.push((uid, Some(a.clone())));
                continue;
            }
            out.push((uid, base.get(&uid).cloned()));
        }
        out
    }

    /// 分页（升序）
    #[inline]
    pub fn get_page(&self, page: usize, page_size: usize) -> Vec<FriendId> {
        if page_size == 0 {
            return Vec::new();
        }
        let all = self.snapshot_all();
        let start = page.saturating_mul(page_size);
        all.into_iter().skip(start).take(page_size).collect()
    }

    /// 分页（含别名）
    #[inline]
    pub fn get_page_detailed(
        &self,
        page: usize,
        page_size: usize,
    ) -> Vec<(FriendId, Option<String>)> {
        if page_size == 0 {
            return Vec::new();
        }
        let all = self.snapshot_all_detailed();
        let start = page.saturating_mul(page_size);
        all.into_iter().skip(start).take(page_size).collect()
    }

    /// 与**全局在线**位图求交（遍历好友 + contains）
    #[inline]
    pub fn online_with_global(&self, global_online: &RB64) -> Vec<FriendId> {
        let all = self.snapshot_all();
        let mut out = Vec::with_capacity(all.len().min(256));
        for uid in all {
            if global_online.contains(uid) {
                out.push(uid);
            }
        }
        out
    }

    /// 达阈值或定时触发：把 Δ 归并进 EF Base（重建一次）
    /// 同步应用别名 Δ，并剪枝非好友的别名
    pub fn maybe_compact(&self, add_thresh: usize, del_thresh: usize) {
        let add_len = self.delta_add.read().len();
        let del_len = self.delta_del.read().len();
        if add_len < add_thresh && del_len < del_thresh {
            return;
        }

        // 1) 合并后重建 EF
        let merged = self.snapshot_all(); // 升序去重
        let new_base = EliasFano::from_sorted(&merged);
        *self.base.write() = new_base;

        // 2) 清空关系增量
        self.delta_add.write().clear();
        self.delta_del.write().clear();

        // 3) 应用别名增量到 Base，并清理非好友（严格顺序：删 -> 加 -> 剪枝）
        {
            let mut ab = self.nickname_base.write();
            let mut aa = self.nickname_add.write();
            let mut ad = self.nickname_del.write();

            // (a) 删除优先
            if !ad.is_empty() {
                for &uid in ad.iter() {
                    ab.remove(&uid);
                    aa.remove(&uid);
                }
                ad.clear();
            }

            // (b) 应用新增/更新（仅对仍为好友的 id）
            if !aa.is_empty() {
                // aa.drain() 避免克隆
                for (uid, nickname) in aa.drain() {
                    if merged.binary_search(&uid).is_ok() {
                        ab.insert(uid, nickname);
                    }
                }
            }

            // (c) 剪枝：Base 中残留但已不在好友集合的别名
            if !ab.is_empty() {
                let keys: Vec<_> = ab.keys().cloned().collect();
                for k in keys {
                    if merged.binary_search(&k).is_err() {
                        ab.remove(&k);
                    }
                }
            }
        }
    }

    // —— 轻量只读计数（给 MemberRelation 估算用）——
    #[inline]
    pub fn base_len(&self) -> usize {
        self.base.read().len()
    }
    #[inline]
    pub fn delta_add_len(&self) -> usize {
        self.delta_add.read().len()
    }
    #[inline]
    pub fn delta_del_len(&self) -> usize {
        self.delta_del.read().len()
    }
    #[inline]
    pub fn nickname_add_len(&self) -> usize {
        self.nickname_add.read().len()
    }
    #[inline]
    pub fn nickname_del_len(&self) -> usize {
        self.nickname_del.read().len()
    }
}
