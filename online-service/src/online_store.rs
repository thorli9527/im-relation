// online-service/src/online_store.rs
//
// 目标：高并发、低锁竞争、API 清晰
// -----------------------------------------------------------------------------
// - 数据结构：按分片（shard）存 Roaring 位图（RoaringTreemap<u64>），并维护原子计数。
// - 写路径：单写/批量写均尽量减少写锁持有时间；批量写按分片聚合后“一片一次写锁”。
// - 读路径：单查/批量查一次分片一次读锁，保持输入顺序返回；提供快照接口避免长时间持锁。
// - 修复：不返回引用临时对象的读锁（E0515）；若需要无锁使用，提供 snapshot（克隆）。
//
// 小贴士：shard_count 建议用 2 的幂（如 64/128/256），可用位与寻址更快。

use common::UserId;
use parking_lot::{RwLock, RwLockReadGuard, RwLockUpgradableReadGuard};
use roaring::RoaringTreemap as RB64;
use std::sync::{
    atomic::{AtomicU64, Ordering},
    Arc,
};

#[derive(Debug, Default)]
struct OnlineShard {
    // 在线用户集合；用 Roaring 避免大稀疏集合的内存浪费
    map: RwLock<RB64>,
    // 计数器：写入/删除时做增减，len() O(1)
    count: AtomicU64,
}

#[derive(Debug)]
pub struct OnlineStore {
    shards: Arc<Box<[OnlineShard]>>,
    mask: usize,
    is_pow2: bool,
}

impl OnlineStore {
    /// 构造；shard_count 建议为 2 的幂（否则内部自动用 mod）
    pub fn new(shard_count: usize) -> Self {
        let n = shard_count.max(1);
        let is_pow2 = n.is_power_of_two();
        let mask = if is_pow2 { n - 1 } else { 0 };
        let shards = (0..n)
            .map(|_| OnlineShard::default())
            .collect::<Vec<_>>()
            .into_boxed_slice();
        Self { shards: Arc::new(shards), mask, is_pow2 }
    }

    #[inline]
    pub fn shard_count(&self) -> usize {
        self.shards.len()
    }

    #[inline]
    fn shard_idx_of(&self, uid: UserId) -> usize {
        let u = uid as u64 as usize;
        if self.is_pow2 { u & self.mask } else { u % self.shards.len() }
    }

    // ---------------- 写路径 ----------------

    /// 单个设置在线/离线（无变化时全程不上写锁）
    pub fn set_online(&self, uid: UserId, online: bool) {
        let idx = self.shard_idx_of(uid);
        let shard = &self.shards[idx];
        let u = uid as u64;

        // 先可升级读，只有状态变化才升级为写
        let g = shard.map.upgradable_read();
        let cur = g.contains(u);
        if online == cur {
            return; // 状态未变，避免写锁
        }

        let mut w = RwLockUpgradableReadGuard::upgrade(g);
        if online {
            if w.insert(u) {
                shard.count.fetch_add(1, Ordering::Relaxed);
            }
        } else if w.remove(u) {
            shard.count.fetch_sub(1, Ordering::Relaxed);
        }
    }

    #[inline]
    pub fn insert(&self, uid: UserId) { self.set_online(uid, true); }

    #[inline]
    pub fn remove(&self, uid: UserId) { self.set_online(uid, false); }

    /// 批量设置在线/离线：按分片聚合后，一片一次写锁
    pub fn set_online_many<I>(&self, items: I)
    where
        I: IntoIterator<Item = (UserId, bool)>,
    {
        // 1) 按 shard 聚合
        let mut buckets: Vec<Vec<(UserId, bool)>> =
            (0..self.shards.len()).map(|_| Vec::new()).collect();
        for (uid, on) in items {
            buckets[self.shard_idx_of(uid)].push((uid, on));
        }

        // 2) 每片一次写锁
        for (i, batch) in buckets.into_iter().enumerate() {
            if batch.is_empty() {
                continue;
            }
            let shard = &self.shards[i];
            let mut w = shard.map.write();
            let mut delta: i64 = 0;
            for (uid, on) in batch {
                let u = uid as u64;
                if on {
                    if w.insert(u) {
                        delta += 1;
                    }
                } else if w.remove(u) {
                    delta -= 1;
                }
            }
            if delta > 0 {
                shard.count.fetch_add(delta as u64, Ordering::Relaxed);
            } else if delta < 0 {
                shard.count.fetch_sub((-delta) as u64, Ordering::Relaxed);
            }
        }
    }

    #[inline]
    pub fn insert_many<I>(&self, ids: I)
    where
        I: IntoIterator<Item = UserId>,
    {
        self.set_online_many(ids.into_iter().map(|u| (u, true)));
    }

    #[inline]
    pub fn remove_many<I>(&self, ids: I)
    where
        I: IntoIterator<Item = UserId>,
    {
        self.set_online_many(ids.into_iter().map(|u| (u, false)));
    }

    // ---------------- 读路径 ----------------

    /// 单查（读锁极短）
    pub fn contains(&self, uid: UserId) -> bool {
        let s = &self.shards[self.shard_idx_of(uid)];
        s.map.read().contains(uid as u64)
    }

    /// 批量查：结果保持输入顺序；内部一次分片一次读锁
    pub fn contains_many_ordered<I>(&self, ids: I) -> Vec<bool>
    where
        I: IntoIterator<Item = UserId>,
    {
        // 1) 按分片聚合（记录原始位置）
        let mut buckets: Vec<Vec<(usize, UserId)>> =
            (0..self.shards.len()).map(|_| Vec::new()).collect();
        let mut n = 0usize;
        for (pos, uid) in ids.into_iter().enumerate() {
            buckets[self.shard_idx_of(uid)].push((pos, uid));
            n = pos + 1;
        }

        // 2) 每片一次读锁，回填结果
        let mut out = vec![false; n];
        for (i, batch) in buckets.into_iter().enumerate() {
            if batch.is_empty() {
                continue;
            }
            let g = self.shards[i].map.read();
            for (pos, raw) in batch {
                out[pos] = g.contains(raw as u64);
            }
        }
        out
    }

    // ---------------- 快照与原子统计 ----------------

    /// 返回某个分片的 **只读锁**（谨慎长时间持有）
    /// 若仅做遍历/导出，建议优先使用 `snapshot()`，避免长时间持锁。
    pub fn shard_map_read(&self, idx: usize) -> Option<RwLockReadGuard<'_, RB64>> {
        self.shards.get(idx).map(|s| s.map.read())
    }

    /// 返回某个分片的 **快照**（克隆 Roaring；不持锁）
    pub fn snapshot(&self, idx: usize) -> Option<RB64> {
        let shard = self.shards.get(idx)?;
        let g = shard.map.read();
        Some(g.clone())
    }

    /// 在线总数（O(#shard) 原子读取）
    pub fn len(&self) -> u64 {
        self.shards
            .iter()
            .map(|s| s.count.load(Ordering::Relaxed))
            .sum()
    }

    /// 指定分片的在线数
    pub fn len_by_shard(&self, idx: usize) -> u64 {
        self.shards
            .get(idx)
            .map(|s| s.count.load(Ordering::Relaxed))
            .unwrap_or(0)
    }

    /// 汇总统计：总数、各分片数、最大分片信息
    pub fn stats(&self) -> OnlineStats {
        let mut per = Vec::with_capacity(self.shards.len());
        let mut max = (0usize, 0u64);
        for (i, s) in self.shards.iter().enumerate() {
            let v = s.count.load(Ordering::Relaxed);
            if v > max.1 {
                max = (i, v);
            }
            per.push(v);
        }
        OnlineStats {
            total: per.iter().copied().sum(),
            per_shard: per,
            max_shard: max,
        }
    }

    // ---------------- 服务侧“取热前续命”辅助 ----------------

    /// 若用户在线，返回 true（你可据此在取热前“续命”缓存）。
    /// 之所以不直接触及业务缓存，是为了让 OnlineStore 保持纯粹职责。
    #[inline]
    pub fn is_online(&self, uid: UserId) -> bool {
        self.contains(uid)
    }
}

#[derive(Debug, Clone)]
pub struct OnlineStats {
    pub total: u64,
    pub per_shard: Vec<u64>,
    pub max_shard: (usize, u64), // (shard_idx, size)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn basic_ops() {
        let s = OnlineStore::new(64);
        assert_eq!(s.len(), 0);

        s.insert(1);
        s.insert(2);
        s.insert(2); // 幂等
        assert!(s.contains(1));
        assert!(s.contains(2));
        assert!(!s.contains(3));
        assert_eq!(s.len(), 2);

        s.remove(1);
        assert!(!s.contains(1));
        assert_eq!(s.len(), 1);

        s.insert_many([10, 11, 12, 13]);
        assert_eq!(s.len(), 5);

        let v = s.contains_many_ordered([2, 3, 10, 11, 99]);
        assert_eq!(v, vec![true, false, true, true, false]);

        // 快照不持锁
        let idx = s.shard_idx_of(10);
        let snap = s.snapshot(idx).unwrap();
        assert!(snap.contains(10));
    }
}
