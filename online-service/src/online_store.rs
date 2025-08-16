// online-service/src/online_story.rs
use common::UserId;
use parking_lot::{RwLock, RwLockReadGuard, RwLockUpgradableReadGuard};
use roaring::RoaringTreemap as RB64;
use std::sync::{
    atomic::{AtomicU64, Ordering},
    Arc,
};

#[derive(Debug, Default)]
struct OnlineShard {
    map: RwLock<RB64>,
    count: AtomicU64,
}

#[derive(Debug)]
pub struct OnlineStore {
    shards: Arc<Box<[OnlineShard]>>,
    mask: usize,
    is_pow2: bool,
}

impl OnlineStore {
    /// shard_count 建议传 2 的幂（32/64/128/256...），便于位与寻址
    pub fn new(shard_count: usize) -> Self {
        let n = shard_count.max(1);
        let is_pow2 = n.is_power_of_two();
        let mask = if is_pow2 { n - 1 } else { 0 };
        let shards = (0..n).map(|_| OnlineShard::default()).collect::<Vec<_>>().into_boxed_slice();
        Self { shards: Arc::new(shards), mask, is_pow2 }
    }

    #[inline] pub fn shard_count(&self) -> usize { self.shards.len() }

    #[inline]
    fn shard_idx_of(&self, uid: UserId) -> usize {
        let u = uid as u64 as usize;
        if self.is_pow2 { u & self.mask } else { u % self.shards.len() }
    }

    /// 写快路径：先 upgradable read，只有确实发生变化时才升级为写锁
    pub fn set_online(&self, uid: UserId, online: bool) {
        let idx = self.shard_idx_of(uid);
        let shard = &self.shards[idx];
        let u = uid as u64;

        let g = shard.map.upgradable_read();
        let cur = g.contains(u);
        if online == cur { return; } // 无变化，完全无写锁

        let mut w = RwLockUpgradableReadGuard::upgrade(g);
        if online {
            if w.insert(u) { shard.count.fetch_add(1, Ordering::Relaxed); }
        } else {
            if w.remove(u) { shard.count.fetch_sub(1, Ordering::Relaxed); }
        }
    }

    #[inline] pub fn insert(&self, uid: UserId) { self.set_online(uid, true); }
    #[inline] pub fn remove(&self, uid: UserId) { self.set_online(uid, false); }

    /// 批量写：每分片一次写锁，极大降低锁竞争
    pub fn set_online_many<I>(&self, items: I)
    where I: IntoIterator<Item = (UserId, bool)> {
        let mut buckets: Vec<Vec<(UserId, bool)>> = (0..self.shards.len()).map(|_| Vec::new()).collect();
        for (uid, on) in items {
            buckets[self.shard_idx_of(uid)].push((uid, on));
        }
        for (i, batch) in buckets.into_iter().enumerate() {
            if batch.is_empty() { continue; }
            let shard = &self.shards[i];
            let mut w = shard.map.write();
            let mut delta: i64 = 0;
            for (uid, on) in batch {
                let u = uid as u64;
                if on {
                    if w.insert(u) { delta += 1; }
                } else {
                    if w.remove(u) { delta -= 1; }
                }
            }
            if delta > 0 {
                shard.count.fetch_add(delta as u64, Ordering::Relaxed);
            } else if delta < 0 {
                shard.count.fetch_sub((-delta) as u64, Ordering::Relaxed);
            }
        }
    }
    #[inline] pub fn insert_many<I>(&self, ids: I) where I: IntoIterator<Item=UserId> {
        self.set_online_many(ids.into_iter().map(|u| (u, true)));
    }
    #[inline] pub fn remove_many<I>(&self, ids: I) where I: IntoIterator<Item=UserId> {
        self.set_online_many(ids.into_iter().map(|u| (u, false)));
    }

    /// 单查（短读锁）
    pub fn contains(&self, uid: UserId) -> bool {
        let s = &self.shards[self.shard_idx_of(uid)];
        s.map.read().contains(uid as u64)
    }

    /// 批量查（输入顺序保持），一次分片一次读锁
    pub fn contains_many_ordered<I>(&self, ids: I) -> Vec<bool>
    where I: IntoIterator<Item = UserId> {
        let mut buckets: Vec<Vec<(usize, UserId)>> = (0..self.shards.len()).map(|_| Vec::new()).collect();
        let mut n = 0usize;
        for (i, uid) in ids.into_iter().enumerate() {
            buckets[self.shard_idx_of(uid)].push((i, uid));
            n = i + 1;
        }
        let mut out = vec![false; n];
        for (i, batch) in buckets.into_iter().enumerate() {
            if batch.is_empty() { continue; }
            let g = self.shards[i].map.read();
            for (pos, raw) in batch {
                out[pos] = g.contains(raw as u64);
            }
        }
        out
    }

    pub fn len(&self) -> u64 {
        self.shards.iter().map(|s| s.count.load(Ordering::Relaxed)).sum()
    }

    pub fn len_by_shard(&self, idx: usize) -> u64 {
        self.shards.get(idx).map(|s| s.count.load(Ordering::Relaxed)).unwrap_or(0)
    }

    pub fn shard_map(&self, idx: usize) -> Option<RwLockReadGuard<'_, RB64>> {
        self.shards.get(idx).map(|s| s.map.read())
    }

    pub fn stats(&self) -> OnlineStats {
        let mut per = Vec::with_capacity(self.shards.len());
        let mut max = (0usize, 0u64);
        for (i, s) in self.shards.iter().enumerate() {
            let v = s.count.load(Ordering::Relaxed);
            if v > max.1 { max = (i, v); }
            per.push(v);
        }
        OnlineStats { total: per.iter().copied().sum(), per_shard: per, max_shard: max }
    }
}

#[derive(Debug, Clone)]
pub struct OnlineStats {
    pub total: u64,
    pub per_shard: Vec<u64>,
    pub max_shard: (usize, u64),
}
