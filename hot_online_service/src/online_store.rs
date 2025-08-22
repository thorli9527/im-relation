// hot_online_service/src/online_store.rs
//
// 目标：高并发、低锁竞争、零悬垂引用（修复 E0515）
// - 读多写少：RoaringTreemap + parking_lot::RwLock
// - 分片：建议用 2 的幂，位与寻址更快
// - 写路径：upgradable_read -> 仅变更时升级为写锁
// - 批量写：每分片一次写锁，显著降低锁竞争
// - 读路径：批量查询按分片并行聚合，保持输入顺序
//
// 注意：不返回 Guard；提供 with_shard_map 闭包访问，或返回快照（Vec<u64>）的接口。

use common::UserId;
use parking_lot::{RwLock, RwLockUpgradableReadGuard};
use roaring::RoaringTreemap as RB64;
use std::sync::{
    atomic::{AtomicU64, Ordering},
    Arc,
};

#[derive(Debug, Default)]
struct OnlineShard {
    /// 分片内在线用户集合（u64）
    map: RwLock<RB64>,
    /// 计数器（避免每次读锁统计）
    count: AtomicU64,
}

#[derive(Debug)]
pub struct OnlineStore {
    shards: Arc<Box<[OnlineShard]>>,
    mask: usize,
    is_pow2: bool,
}

impl OnlineStore {
    /// `shard_count` 建议为 2 的幂（32/64/128/…）
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

    /// 设置在线状态（写快路径：仅在状态改变时升级为写锁）
    pub fn set_online(&self, uid: UserId, online: bool) {
        let idx = self.shard_idx_of(uid);
        let shard = &self.shards[idx];
        let u = uid as u64;

        let g = shard.map.upgradable_read();
        let cur = g.contains(u);
        if online == cur {
            return; // 无变化，不触发写锁
        }

        let mut w = RwLockUpgradableReadGuard::upgrade(g);
        if online {
            if w.insert(u) {
                shard.count.fetch_add(1, Ordering::Relaxed);
            }
        } else {
            if w.remove(u) {
                shard.count.fetch_sub(1, Ordering::Relaxed);
            }
        }
    }

    #[inline]
    pub fn insert(&self, uid: UserId) {
        self.set_online(uid, true);
    }
    #[inline]
    pub fn remove(&self, uid: UserId) {
        self.set_online(uid, false);
    }

    /// 批量设置在线状态：每分片一次写锁
    pub fn set_online_many<I>(&self, items: I)
    where
        I: IntoIterator<Item = (UserId, bool)>,
    {
        let mut buckets: Vec<Vec<(UserId, bool)>> =
            (0..self.shards.len()).map(|_| Vec::new()).collect();

        for (uid, on) in items {
            buckets[self.shard_idx_of(uid)].push((uid, on));
        }

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

    /// 单查（短读锁）
    pub fn contains(&self, uid: UserId) -> bool {
        let s = &self.shards[self.shard_idx_of(uid)];
        s.map.read().contains(uid as u64)
    }

    /// 批量查（保持输入顺序）：按分片分桶，一次分片一次读锁
    pub fn contains_many_ordered<I>(&self, ids: I) -> Vec<bool>
    where
        I: IntoIterator<Item = UserId>,
    {
        let mut idx_vec: Vec<UserId> = Vec::new();
        for id in ids {
            idx_vec.push(id);
        }
        let n = idx_vec.len();
        let mut buckets: Vec<Vec<(usize, UserId)>> =
            (0..self.shards.len()).map(|_| Vec::new()).collect();

        for (pos, uid) in idx_vec.iter().copied().enumerate() {
            buckets[self.shard_idx_of(uid)].push((pos, uid));
        }

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

    /// 在线总数（分片累加）
    pub fn len(&self) -> u64 {
        self.shards
            .iter()
            .map(|s| s.count.load(Ordering::Relaxed))
            .sum()
    }

    /// 单分片在线数
    pub fn len_by_shard(&self, idx: usize) -> u64 {
        self.shards
            .get(idx)
            .map(|s| s.count.load(Ordering::Relaxed))
            .unwrap_or(0)
    }

    /// 以“闭包”的方式读取指定分片的数据（无 Guard 外泄，避免 E0515）
    /// 用法：
    ///   store.with_shard_map(0, |set| set.len());
    pub fn with_shard_map<F, R>(&self, idx: usize, f: F) -> Option<R>
    where
        F: FnOnce(&RB64) -> R,
    {
        self.shards.get(idx).map(|s| {
            let g = s.map.read();
            f(&*g)
        })
    }

    /// 返回指定分片的**快照**（拷贝一份 u64 向量）
    pub fn shard_snapshot(&self, idx: usize) -> Option<Vec<u64>> {
        let s = self.shards.get(idx)?;
        let g = s.map.read();
        Some(g.iter().collect())
    }

    /// 总览统计（总数 / 各分片 / 最大分片）
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
}

#[derive(Debug, Clone)]
pub struct OnlineStats {
    pub total: u64,
    pub per_shard: Vec<u64>,
    pub max_shard: (usize, u64),
}
