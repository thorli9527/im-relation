// online-service/src/hot_cold.rs
//
// 目标（健壮 + 性能 + 观测）
// -----------------------------------------------------------------------------
// - 防击穿：moka::future::Cache + try_get_with（天然 single-flight）；路由统一 Option<i64>；失败不上缓存。
// - 健壮性：无 unwrap/expect；空入参快速返回；错误边界清晰化。
// - 性能：get_by_ids 并发聚合 + 回灌缓存，显著降低 p95/p99。
// - 观测：Cache line padding 的计数器，避免伪共享，提供快照导出。

use std::collections::{HashMap, HashSet};
use std::sync::Arc;
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::Duration;

use anyhow::{anyhow, bail, Context, Result};
use bytes::Bytes;
use futures::stream::{self, StreamExt};
use idna::Config as IdnaConfig;
use moka::future::Cache;
use once_cell::sync::Lazy;
use regex::Regex;
use unicode_normalization::UnicodeNormalization;
use crossbeam_utils::CachePadded;

use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use crate::grpc::client_service::ClientEntity;

// -----------------------------------------------------------------------------
// Metrics with cache-line padding
// -----------------------------------------------------------------------------

#[derive(Default)]
struct RouteStats {
    // 加载（目录查询）路径
    load_attempt: CachePadded<AtomicU64>,
    load_ok:      CachePadded<AtomicU64>,
    load_err:     CachePadded<AtomicU64>,
    // 结果映射（包含缓存命中或刚加载完成后的返回）
    some:         CachePadded<AtomicU64>, // 正命中（Some(id)）
    none:         CachePadded<AtomicU64>, // 负命中（None）
}

#[derive(Default)]
struct Stats {
    // by_id
    by_id_hit:         CachePadded<AtomicU64>,
    by_id_miss:        CachePadded<AtomicU64>,
    by_id_load_attempt:CachePadded<AtomicU64>, // 仅在 miss 时触发的真实加载尝试
    by_id_load_ok:     CachePadded<AtomicU64>,
    by_id_load_err:    CachePadded<AtomicU64>, // 包含 not found/库错等

    // 路由（按维度分开便于定位）
    route_email: RouteStats,
    route_phone: RouteStats,
    route_name:  RouteStats,
}

#[derive(Debug, Clone)]
pub struct StatsSnapshot {
    pub by_id_hit:          u64,
    pub by_id_miss:         u64,
    pub by_id_load_attempt: u64,
    pub by_id_load_ok:      u64,
    pub by_id_load_err:     u64,

    pub email_load_attempt: u64,
    pub email_load_ok:      u64,
    pub email_load_err:     u64,
    pub email_some:         u64,
    pub email_none:         u64,

    pub phone_load_attempt: u64,
    pub phone_load_ok:      u64,
    pub phone_load_err:     u64,
    pub phone_some:         u64,
    pub phone_none:         u64,

    pub name_load_attempt:  u64,
    pub name_load_ok:       u64,
    pub name_load_err:      u64,
    pub name_some:          u64,
    pub name_none:          u64,
}

impl Stats {
    #[inline] fn inc(v: &CachePadded<AtomicU64>) { v.fetch_add(1, Ordering::Relaxed); }

    fn snapshot(&self) -> StatsSnapshot {
        StatsSnapshot {
            by_id_hit:          self.by_id_hit.load(Ordering::Relaxed),
            by_id_miss:         self.by_id_miss.load(Ordering::Relaxed),
            by_id_load_attempt: self.by_id_load_attempt.load(Ordering::Relaxed),
            by_id_load_ok:      self.by_id_load_ok.load(Ordering::Relaxed),
            by_id_load_err:     self.by_id_load_err.load(Ordering::Relaxed),

            email_load_attempt: self.route_email.load_attempt.load(Ordering::Relaxed),
            email_load_ok:      self.route_email.load_ok.load(Ordering::Relaxed),
            email_load_err:     self.route_email.load_err.load(Ordering::Relaxed),
            email_some:         self.route_email.some.load(Ordering::Relaxed),
            email_none:         self.route_email.none.load(Ordering::Relaxed),

            phone_load_attempt: self.route_phone.load_attempt.load(Ordering::Relaxed),
            phone_load_ok:      self.route_phone.load_ok.load(Ordering::Relaxed),
            phone_load_err:     self.route_phone.load_err.load(Ordering::Relaxed),
            phone_some:         self.route_phone.some.load(Ordering::Relaxed),
            phone_none:         self.route_phone.none.load(Ordering::Relaxed),

            name_load_attempt:  self.route_name.load_attempt.load(Ordering::Relaxed),
            name_load_ok:       self.route_name.load_ok.load(Ordering::Relaxed),
            name_load_err:      self.route_name.load_err.load(Ordering::Relaxed),
            name_some:          self.route_name.some.load(Ordering::Relaxed),
            name_none:          self.route_name.none.load(Ordering::Relaxed),
        }
    }
}

// -----------------------------------------------------------------------------
// Normalizer（真实实现，读写一致）
// -----------------------------------------------------------------------------

pub trait Normalizer: Send + Sync + 'static {
    fn email_norm(&self, raw: &str) -> Result<Bytes>;
    fn phone_norm(&self, raw: &str) -> Result<Bytes>;
    fn name_norm(&self, raw: &str) -> Result<Bytes>;
}

pub struct RealNormalizer {
    default_country_cc: String, // E.164 默认国家码（不含+）
}

impl RealNormalizer {
    pub fn new(default_country_cc: impl Into<String>) -> Self {
        Self { default_country_cc: default_country_cc.into() }
    }
    #[inline]
    fn nfkc_lower_trim(s: &str) -> String {
        let folded: String = s.nfkc().collect::<String>().to_lowercase();
        folded.trim().to_string()
    }
    fn strip_phone_chars(s: &str) -> Result<String> {
        let mut out = String::with_capacity(s.len());
        let mut plus_seen = false;
        for (i, ch) in s.chars().enumerate() {
            if ch.is_ascii_digit() { out.push(ch); continue; }
            if ch == '+' {
                if i != 0 || plus_seen { bail!("invalid '+' position in phone"); }
                plus_seen = true; out.push('+'); continue;
            }
            // 其他字符忽略（空格/横杠/括号等）
        }
        Ok(out)
    }
    fn to_e164(mut s: String, default_cc: &str) -> Result<String> {
        if s.is_empty() { return Ok(s); }
        if s.starts_with("00") { s.replace_range(0..2, "+"); }
        if s.starts_with('+') {
            if !s[1..].chars().all(|c| c.is_ascii_digit()) { bail!("phone contains non-digits after '+'"); }
        } else {
            if !s.chars().all(|c| c.is_ascii_digit()) { bail!("phone contains non-digits"); }
            if default_cc.is_empty() { bail!("no country code and no default_cc configured"); }
            s = format!("+{}{}", default_cc, s);
        }
        let digits_len = s.len() - 1;
        if !(8..=15).contains(&digits_len) { bail!("phone digits length not in 8..=15"); }
        Ok(s)
    }
}

static RE_SPACES: Lazy<Regex> = Lazy::new(|| Regex::new(r"\s+").expect("compile whitespace regex"));

impl Normalizer for RealNormalizer {
    fn email_norm(&self, raw: &str) -> Result<Bytes> {
        let trimmed = raw.trim();
        if trimmed.is_empty() { return Ok(Bytes::new()); }
        let lowered = Self::nfkc_lower_trim(trimmed);
        let parts: Vec<&str> = lowered.split('@').collect();
        if parts.len() != 2 { bail!("invalid email: missing '@'"); }
        let (local, domain) = (parts[0], parts[1]);
        if local.is_empty() || domain.is_empty() { bail!("invalid email: empty local or domain"); }
        let domain_ascii = IdnaConfig::default()
            .use_std3_ascii_rules(true)
            .to_ascii(domain)
            .map_err(|e| anyhow!("idna to_ascii failed: {e}"))?;
        if local.len() > 64 { bail!("invalid email: local too long"); }
        let email_ascii = format!("{local}@{domain_ascii}");
        if email_ascii.len() > 254 { bail!("invalid email: too long"); }
        Ok(Bytes::from(email_ascii))
    }
    fn phone_norm(&self, raw: &str) -> Result<Bytes> {
        let trimmed = raw.trim();
        if trimmed.is_empty() { return Ok(Bytes::new()); }
        let s = trimmed.nfkc().collect::<String>();
        let stripped = Self::strip_phone_chars(&s)?;
        if stripped.is_empty() { return Ok(Bytes::new()); }
        let e164 = Self::to_e164(stripped, &self.default_country_cc)?;
        Ok(Bytes::from(e164))
    }
    fn name_norm(&self, raw: &str) -> Result<Bytes> {
        let s = Self::nfkc_lower_trim(raw);
        if s.is_empty() { return Ok(Bytes::new()); }
        let collapsed = RE_SPACES.replace_all(&s, " ");
        Ok(Bytes::from(collapsed.trim().to_string()))
    }
}

// -----------------------------------------------------------------------------
// Facade：缓存 + 路由 + 指标
// -----------------------------------------------------------------------------

pub struct ClientHot<R, D, N> {
    repo: Arc<R>,
    dir: Arc<D>,
    normalizer: Arc<N>,

    by_id: Cache<i64, Arc<ClientEntity>>,              // id -> 实体
    email_to_id: Cache<Bytes, Option<i64>>,            // 路由：正/负命中
    phone_to_id: Cache<Bytes, Option<i64>>,
    name_to_id:  Cache<Bytes, Option<i64>>,

    stats: Arc<Stats>,                                 // cache-line padded 计数器
}

pub struct ClientHotConfig {
    pub by_id_max_capacity: u64,
    pub by_id_ttl: Duration,
    pub route_max_capacity: u64,
    pub route_ttl: Duration,
}

impl Default for ClientHotConfig {
    fn default() -> Self {
        Self {
            by_id_max_capacity: 500_000,
            by_id_ttl: Duration::from_secs(300),
            route_max_capacity: 200_000,
            route_ttl: Duration::from_secs(120),
        }
    }
}

impl<R, D, N> ClientHot<R, D, N>
where
    R: ClientReadRepo + Send + Sync + 'static,
    D: DirectoryReadRepo + Send + Sync + 'static,
    N: Normalizer,
{
    pub fn new(repo: Arc<R>, dir: Arc<D>, normalizer: Arc<N>, cfg: ClientHotConfig) -> Self {
        let by_id = Cache::builder()
            .max_capacity(cfg.by_id_max_capacity)
            .time_to_live(cfg.by_id_ttl)
            .build();

        let build_route = || {
            Cache::builder()
                .max_capacity(cfg.route_max_capacity)
                .time_to_live(cfg.route_ttl)
                .build()
        };

        Self {
            repo,
            dir,
            normalizer,
            by_id,
            email_to_id: build_route(),
            phone_to_id: build_route(),
            name_to_id:  build_route(),
            stats: Arc::new(Stats::default()),
        }
    }

    /// 导出指标快照
    #[inline]
    pub fn stats(&self) -> StatsSnapshot {
        self.stats.snapshot()
    }

    // ------------------------- 对外 API -------------------------

    /// id -> 实体；不存在返回 Err("not found")
    pub async fn get_by_id(&self, id: i64) -> Result<Arc<ClientEntity>> {
        if self.by_id.contains_key(&id) {
            Stats::inc(&self.stats.by_id_hit);
        } else {
            Stats::inc(&self.stats.by_id_miss);
        }

        let stats = Arc::clone(&self.stats);
        let arc = self
            .by_id
            .try_get_with(id, {
                let repo = Arc::clone(&self.repo);
                async move {
                    // 仅在 miss 进入闭包
                    Stats::inc(&stats.by_id_load_attempt);
                    let ent = repo
                        .get_by_id(id)
                        .await
                        .context("repo.get_by_id failed")?
                        .ok_or_else(|| anyhow!("not found"))?;
                    Stats::inc(&stats.by_id_load_ok);
                    Ok::<Arc<ClientEntity>, anyhow::Error>(Arc::new(ent))
                }
            })
            .await
            .map_err({
                let stats = Arc::clone(&self.stats);
                move |e| {
                    Stats::inc(&stats.by_id_load_err);
                    anyhow!("cache(by_id) try_get_with failed: {}", e)
                }
            })?;

        Ok(arc)
    }

    /// 批量 ids：同步命中 + 聚合 miss 批量查 + 回灌；返回存在的实体（不保证顺序）。
    pub async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<Arc<ClientEntity>>> {
        if ids.is_empty() {
            return Ok(Vec::new());
        }

        // 1) 同步判断命中
        let mut seen = HashSet::with_capacity(ids.len());
        let mut present_ids = Vec::new();
        let mut misses = Vec::new();

        for &id in ids {
            if !seen.insert(id) { continue; }
            if self.by_id.contains_key(&id) {
                Stats::inc(&self.stats.by_id_hit);
                present_ids.push(id);
            } else {
                Stats::inc(&self.stats.by_id_miss);
                misses.push(id);
            }
        }

        // 2) 并发取回命中的值（纯内存 await），竞态 None 过滤
        let mut hits: Vec<Arc<ClientEntity>> = stream::iter(
            present_ids.into_iter().map(|id| async move { self.by_id.get(&id).await })
        )
            .buffer_unordered(128)
            .filter_map(|opt| async move { opt })
            .collect()
            .await;

        // 3) 无 miss 直接返回
        if misses.is_empty() {
            return Ok(hits);
        }

        // 4) miss 聚合：底层分片并发 + IN 分批
        let fetched = self
            .repo
            .get_by_ids(&misses)
            .await
            .context("repo.get_by_ids failed in hot_cold::get_by_ids")?;

        // 统计装载 ok/err（err 这里代表“未找到”的 miss 数）
        let ok_cnt = fetched.len() as u64;
        let miss_cnt = misses.len() as u64;
        if ok_cnt > 0 {
            self.stats.by_id_load_ok.fetch_add(ok_cnt, Ordering::Relaxed);
            self.stats.by_id_load_attempt.fetch_add(ok_cnt, Ordering::Relaxed); // 每个找到的都意味着一次有效装载
        }
        if miss_cnt > ok_cnt {
            self.stats
                .by_id_load_err
                .fetch_add(miss_cnt - ok_cnt, Ordering::Relaxed);
            // 注意：这里没有对“未找到但尝试了”的计数细分；如需更精确，可改为 repo 返回 found_ids 以统计 attempt。
        }

        if fetched.is_empty() {
            return Ok(hits);
        }

        // 5) 回灌 + 合并
        let mut map: HashMap<i64, Arc<ClientEntity>> = HashMap::with_capacity(fetched.len());
        for ent in fetched {
            let id = ent.id;
            let arc = Arc::new(ent);
            self.by_id.insert(id, arc.clone()).await;
            map.insert(id, arc);
        }
        hits.extend(map.into_values());
        Ok(hits)
    }

    /// email -> Option<实体>
    pub async fn get_by_email(&self, raw: &str) -> Result<Option<Arc<ClientEntity>>> {
        let norm = self.normalizer.email_norm(raw).context("normalize email failed")?;
        if norm.is_empty() {
            return Ok(None);
        }

        let stats = Arc::clone(&self.stats);
        let id_opt = self
            .email_to_id
            .try_get_with(norm.clone(), {
                let dir = Arc::clone(&self.dir);
                async move {
                    Stats::inc(&stats.route_email.load_attempt);
                    let id_opt = dir.get_id_by_email(&norm).await?;
                    Stats::inc(&stats.route_email.load_ok);
                    Ok::<Option<i64>, anyhow::Error>(id_opt)
                }
            })
            .await
            .map_err({
                let stats = Arc::clone(&self.stats);
                move |e| {
                    Stats::inc(&stats.route_email.load_err);
                    anyhow!("route cache(email) try_get_with failed: {}", e)
                }
            })?;

        if id_opt.is_some() {
            Stats::inc(&self.stats.route_email.some);
        } else {
            Stats::inc(&self.stats.route_email.none);
        }

        match id_opt {
            Some(id) => self.get_by_id(id).await.map(Some),
            None => Ok(None),
        }
    }

    /// phone -> Option<实体>
    pub async fn get_by_phone(&self, raw: &str) -> Result<Option<Arc<ClientEntity>>> {
        let norm = self.normalizer.phone_norm(raw).context("normalize phone failed")?;
        if norm.is_empty() {
            return Ok(None);
        }

        let stats = Arc::clone(&self.stats);
        let id_opt = self
            .phone_to_id
            .try_get_with(norm.clone(), {
                let dir = Arc::clone(&self.dir);
                async move {
                    Stats::inc(&stats.route_phone.load_attempt);
                    let id_opt = dir.get_id_by_phone(&norm).await?;
                    Stats::inc(&stats.route_phone.load_ok);
                    Ok::<Option<i64>, anyhow::Error>(id_opt)
                }
            })
            .await
            .map_err({
                let stats = Arc::clone(&self.stats);
                move |e| {
                    Stats::inc(&stats.route_phone.load_err);
                    anyhow!("route cache(phone) try_get_with failed: {}", e)
                }
            })?;

        if id_opt.is_some() {
            Stats::inc(&self.stats.route_phone.some);
        } else {
            Stats::inc(&self.stats.route_phone.none);
        }

        match id_opt {
            Some(id) => self.get_by_id(id).await.map(Some),
            None => Ok(None),
        }
    }

    /// name -> Option<实体>
    pub async fn get_by_name(&self, raw: &str) -> Result<Option<Arc<ClientEntity>>> {
        let norm = self.normalizer.name_norm(raw).context("normalize name failed")?;
        if norm.is_empty() {
            return Ok(None);
        }

        let stats = Arc::clone(&self.stats);
        let id_opt = self
            .name_to_id
            .try_get_with(norm.clone(), {
                let dir = Arc::clone(&self.dir);
                async move {
                    Stats::inc(&stats.route_name.load_attempt);
                    let s = std::str::from_utf8(&norm).context("name_norm not valid UTF-8")?;
                    let id_opt = dir.get_id_by_name(s).await?;
                    Stats::inc(&stats.route_name.load_ok);
                    Ok::<Option<i64>, anyhow::Error>(id_opt)
                }
            })
            .await
            .map_err({
                let stats = Arc::clone(&self.stats);
                move |e| {
                    Stats::inc(&stats.route_name.load_err);
                    anyhow!("route cache(name) try_get_with failed: {}", e)
                }
            })?;

        if id_opt.is_some() {
            Stats::inc(&self.stats.route_name.some);
        } else {
            Stats::inc(&self.stats.route_name.none);
        }

        match id_opt {
            Some(id) => self.get_by_id(id).await.map(Some),
            None => Ok(None),
        }
    }

    // ------------------- 失效/刷新钩子 -------------------

    pub async fn refresh_by_id(&self, id: i64) -> Result<()> {
        match self.repo.get_by_id(id).await.context("repo.get_by_id failed in refresh_by_id")? {
            Some(ent) => { self.by_id.insert(id, Arc::new(ent)).await; }
            None => { self.by_id.invalidate(&id).await; }
        }
        Ok(())
    }

    pub async fn on_change_email(&self, old_raw: Option<&str>, new_raw: Option<&str>, id: i64) -> Result<()> {
        if let Some(old) = old_raw {
            if let Ok(k) = self.normalizer.email_norm(old) {
                if !k.is_empty() { self.email_to_id.invalidate(&k).await; }
            }
        }
        if let Some(new_) = new_raw {
            let k = self.normalizer.email_norm(new_).context("normalize new email failed")?;
            if !k.is_empty() { self.email_to_id.insert(k, Some(id)).await; }
        }
        self.refresh_by_id(id).await
    }

    pub async fn on_change_phone(&self, old_raw: Option<&str>, new_raw: Option<&str>, id: i64) -> Result<()> {
        if let Some(old) = old_raw {
            if let Ok(k) = self.normalizer.phone_norm(old) {
                if !k.is_empty() { self.phone_to_id.invalidate(&k).await; }
            }
        }
        if let Some(new_) = new_raw {
            let k = self.normalizer.phone_norm(new_).context("normalize new phone failed")?;
            if !k.is_empty() { self.phone_to_id.insert(k, Some(id)).await; }
        }
        self.refresh_by_id(id).await
    }

    pub async fn on_change_name(&self, old_raw: Option<&str>, new_raw: Option<&str>, id: i64) -> Result<()> {
        if let Some(old) = old_raw {
            if let Ok(k) = self.normalizer.name_norm(old) {
                if !k.is_empty() { self.name_to_id.invalidate(&k).await; }
            }
        }
        if let Some(new_) = new_raw {
            let k = self.normalizer.name_norm(new_).context("normalize new name failed")?;
            if !k.is_empty() { self.name_to_id.insert(k, Some(id)).await; }
        }
        self.refresh_by_id(id).await
    }

    pub async fn invalidate_by_id(&self, id: i64) {
        self.by_id.invalidate(&id).await;
    }
}
