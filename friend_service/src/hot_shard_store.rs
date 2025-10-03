//! hot_shard_store.rs
//! - 分段并发的 TTI 热键缓存（moka::sync::SegmentedCache<K, ()>）
//! - DashMap<K, V> 作为主存
//! - 驱逐监听器：可选 persist(uid, value).await → 然后从主存移除
//! - 兼容原先的 HotShardStore::new(...)，并提供 Builder 方式
//!
//! 可选优化：启用 `fxhash` 特性以更快的哈希：
//!   Cargo.toml:
//!     [features]
//!     fxhash = ["fxhash"]
//!
//!   启动：
//!     cargo run --features fxhash

use std::{future::Future, hash::Hash, pin::Pin, sync::Arc, time::Duration};

use dashmap::DashMap;
use moka::notification::RemovalCause;
use moka::sync::{Cache, SegmentedCache};
use tokio::runtime::Handle;

#[cfg(feature = "fxhash")]
use fxhash::FxHasher;
// ---------- 可选 hasher: fxhash ----------
#[cfg(feature = "fxhash")]
use std::hash::BuildHasherDefault;

/// 统一内部 Map 类型：默认 DashMap<K, V>；启用 fxhash 特性后使用 FxHasher。
#[cfg(feature = "fxhash")]
type InnerMap<K, V> = DashMap<K, V, BuildHasherDefault<FxHasher>>;
#[cfg(not(feature = "fxhash"))]
type InnerMap<K, V> = DashMap<K, V>;

/// 持久化回调签名：给定 (key, value) 执行异步持久化。
pub type PersistFn<K, V> =
    Arc<dyn Fn(K, V) -> Pin<Box<dyn Future<Output = ()> + Send + 'static>> + Send + Sync + 'static>;

/// 热分片存储：DashMap 作为主存；moka 分段缓存仅存放“热键”的存在性（值用 `()`）。
pub struct HotShardStore<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static,
    V: Clone + Send + Sync + 'static,
{
    map: Arc<InnerMap<K, V>>,
    hot: SegmentedCache<K, ()>,
    rt: Handle,
    persist: Option<PersistFn<K, V>>,
}

impl<K, V> HotShardStore<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static,
    V: Clone + Send + Sync + 'static,
{
    /// 兼容旧版的构造：直接传入容量/TTI/segments/运行时/回调。
    /// - `hot_capacity`: 热键缓存条目上限（moka 的 max_capacity）
    /// - `tti`: 热键的 Time-To-Idle
    /// - `segments`: 分段数量（提升并发，建议 16~64）
    pub fn new(
        hot_capacity: u64,
        tti: Duration,
        segments: usize,
        rt: Handle,
        persist: Option<PersistFn<K, V>>,
    ) -> Self {
        Self::builder(rt)
            .hot_capacity(hot_capacity)
            .tti(tti)
            .segments(segments)
            .persist_opt(persist)
            .build()
    }

    /// Builder 入口（链式配置）。
    pub fn builder(rt: Handle) -> Builder<K, V> {
        Builder::new(rt)
    }

    /// 写入主存，并将 key 标记为“热”。
    #[inline]
    pub fn insert(&self, key: K, value: V) {
        self.map.insert(key.clone(), value);
        self.hot.insert(key, ());
    }

    /// 仅写入主存（不标记热）。用于冷数据导入或预写。
    #[inline]
    pub fn insert_cold(&self, key: K, value: V) {
        self.map.insert(key, value);
    }

    /// 获取：若存在则返回克隆的值，并将其标记为“热”（重置 TTI）。
    #[inline]
    pub fn get(&self, key: &K) -> Option<V> {
        let v = self.map.get(key).map(|e| e.value().clone());
        if v.is_some() {
            self.hot.insert(key.clone(), ()); // 读放热
        }
        v
    }

    /// 如果在主存中存在则移除；同时从热键缓存中删除其“热”标记。
    #[inline]
    pub fn remove(&self, key: &K) -> Option<V> {
        self.hot.invalidate(key); // 不触发驱逐监听
        self.map.remove(key).map(|(_, v)| v)
    }

    /// 主存中是否包含该 key（不变更热度）
    #[inline]
    pub fn contains_key(&self, key: &K) -> bool {
        self.map.contains_key(key)
    }

    /// 当前主存大小（条目数）
    #[inline]
    pub fn len(&self) -> usize {
        self.map.len()
    }

    /// 手动清空：优先清空热键缓存，再清空主存（避免批量驱逐触发大量持久化）
    pub fn clear(&self) {
        self.hot.invalidate_all();
        self.map.clear();
    }

    /// 暴露内部引用（只读）
    #[inline]
    pub fn inner_map(&self) -> &Arc<InnerMap<K, V>> {
        &self.map
    }

    /// 暴露热键缓存（只读）
    #[inline]
    pub fn hot_cache(&self) -> &SegmentedCache<K, ()> {
        &self.hot
    }

    // ---------- 内部构造逻辑 ----------
    fn build_with(cfg: BuilderConfig<K, V>) -> Self {
        // 监听器捕获
        let map_for_listener = Arc::clone(&cfg.map);
        let persist_for_listener = cfg.persist.clone();
        let rt_for_listener = cfg.rt.clone();

        let hot: SegmentedCache<K, ()> = Cache::builder()
            .max_capacity(cfg.hot_capacity)
            .time_to_idle(cfg.tti)
            .segments(cfg.segments)
            .eviction_listener(move |k_arc: Arc<K>, _unit: (), _cause: RemovalCause| {
                // 被驱逐的“热键” → 先持久化（若配置），再从主存移除
                let key = (*k_arc).clone();
                if let Some(persist_cb) = persist_for_listener.clone() {
                    let m = Arc::clone(&map_for_listener);
                    let rt2 = rt_for_listener.clone();
                    rt2.spawn(async move {
                        if let Some(entry) = m.get(&key) {
                            let v = entry.value().clone();
                            (persist_cb)(key.clone(), v).await;
                        }
                        m.remove(&key);
                    });
                } else {
                    map_for_listener.remove(&key);
                }
            })
            .build();

        Self {
            map: cfg.map,
            hot,
            rt: cfg.rt,
            persist: cfg.persist,
        }
    }
}

// ---------- Builder ----------

/// 内部配置体（避免在闭包里捕获 Builder 本体）。
struct BuilderConfig<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static,
    V: Clone + Send + Sync + 'static,
{
    map: Arc<InnerMap<K, V>>,
    hot_capacity: u64,
    tti: Duration,
    segments: usize,
    rt: Handle,
    persist: Option<PersistFn<K, V>>,
}

/// 链式构造器：默认值安全、可渐进配置。
pub struct Builder<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static,
    V: Clone + Send + Sync + 'static,
{
    map: Arc<InnerMap<K, V>>,
    hot_capacity: u64,
    tti: Duration,
    segments: usize,
    rt: Handle,
    persist: Option<PersistFn<K, V>>,
}

impl<K, V> Builder<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static,
    V: Clone + Send + Sync + 'static,
{
    /// 创建 Builder，提供 Tokio 运行时。
    pub fn new(rt: Handle) -> Self {
        Self {
            map: Arc::new(InnerMap::default()),
            hot_capacity: 10_000,         // 合理的默认值（可覆盖）
            tti: Duration::from_secs(60), // 默认 TTI
            segments: 32,                 // 默认分段（可按 CPU 调整）
            rt,
            persist: None,
        }
    }

    /// 指定热键缓存容量（moka 的 max_capacity，单位：条目）
    #[inline]
    pub fn hot_capacity(mut self, cap: u64) -> Self {
        self.hot_capacity = cap;
        self
    }

    /// 指定 TTI（空闲多久后驱逐）
    #[inline]
    pub fn tti(mut self, tti: Duration) -> Self {
        self.tti = tti;
        self
    }

    /// 指定分段数量（提升并发，建议 16~64）
    #[inline]
    pub fn segments(mut self, segments: usize) -> Self {
        self.segments = segments.max(1);
        self
    }

    /// 指定持久化回调
    #[inline]
    pub fn persist(mut self, persist: PersistFn<K, V>) -> Self {
        self.persist = Some(persist);
        self
    }

    /// 可选地设置持久化回调（Option 版本，便于复用现有值）
    #[inline]
    pub fn persist_opt(mut self, persist: Option<PersistFn<K, V>>) -> Self {
        self.persist = persist;
        self
    }

    /// 构建实例
    pub fn build(self) -> HotShardStore<K, V> {
        let cfg = BuilderConfig {
            map: self.map,
            hot_capacity: self.hot_capacity,
            tti: self.tti,
            segments: self.segments,
            rt: self.rt,
            persist: self.persist,
        };
        HotShardStore::build_with(cfg)
    }
}
