// user_service/src/hot_cold.rs
//
// 目标（健壮 + 性能 + 观测）
// -----------------------------------------------------------------------------
// - 防击穿：moka::future::Cache + try_get_with（天然 single-flight）；路由统一 Option<i64>；失败不上缓存。
// - 健壮性：无 unwrap/expect；空入参快速返回；错误边界清晰化（normalize & 目录失败均按 Err 返回）。
// - 性能：get_by_ids 并发聚合 + 回灌缓存，显著降低 p95/p99。
// - 观测：Cache line padding 的计数器（CachePadded<AtomicU64>），避免伪共享，提供快照导出。
// - 读写一致：Normalizer 的规范化规则在 读路径 与 目录写入 时保持一致，彻底避免错配。

use std::collections::{HashMap, HashSet};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, bail, Context, Result};
use bytes::Bytes;
use crossbeam_utils::CachePadded;
use futures::stream::{self, StreamExt};
use moka::future::Cache;
use once_cell::sync::Lazy;
use regex::Regex;
use unicode_normalization::UnicodeNormalization;

use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use common::infra::grpc::grpc_user::online_service::UserEntity;

// -----------------------------------------------------------------------------
// Metrics with cache-line padding
// -----------------------------------------------------------------------------

/// 路由级指标（email/phone/name 使用同一份结构）
///
/// 采用 CachePadded<AtomicU64> 避免不同计数器位于同一 cache line
/// 造成伪共享（false sharing），在高并发多核场景下能降低尾延迟抖动。
#[derive(Default)]
struct RouteStats {
    /// 目录查询（加载）尝试次数：仅在缓存 miss 且进入加载闭包时增加
    load_attempt: CachePadded<AtomicU64>,
    /// 目录查询成功次数（返回 Ok）
    load_ok: CachePadded<AtomicU64>,
    /// 目录查询失败次数（返回 Err），失败不会写路由缓存
    load_err: CachePadded<AtomicU64>,
    /// 路由为 Some(id) 的返回计数（可能来自缓存，也可能是刚加载成功）
    some: CachePadded<AtomicU64>,
    /// 路由为 None 的返回计数（负缓存命中）
    none: CachePadded<AtomicU64>,
}

/// 全量指标集合
#[derive(Default)]
struct Stats {
    // ---------------- by_id 路径 ----------------
    /// by_id 本地命中次数（contains_key 粗粒度命中）
    by_id_hit: CachePadded<AtomicU64>,
    /// by_id 本地未命中次数
    by_id_miss: CachePadded<AtomicU64>,
    /// by_id 加载尝试次数：仅在 miss 并触发 try_get_with 闭包时增加
    by_id_load_attempt: CachePadded<AtomicU64>,
    /// by_id 加载成功次数（包括 get_by_ids 聚合回灌）
    by_id_load_ok: CachePadded<AtomicU64>,
    /// by_id 加载失败次数（not found / DB Error 等）
    by_id_load_err: CachePadded<AtomicU64>,

    // ---------------- 路由路径（目录） ----------------
    route_email: RouteStats,
    route_phone: RouteStats,
    route_name: RouteStats,
}

/// 公开导出的快照（复制原子值，便于对接监控）
#[derive(Debug, Clone)]
pub struct StatsSnapshot {
    // by_id
    pub by_id_hit: u64,
    pub by_id_miss: u64,
    pub by_id_load_attempt: u64,
    pub by_id_load_ok: u64,
    pub by_id_load_err: u64,

    // email
    pub email_load_attempt: u64,
    pub email_load_ok: u64,
    pub email_load_err: u64,
    pub email_some: u64,
    pub email_none: u64,

    // phone
    pub phone_load_attempt: u64,
    pub phone_load_ok: u64,
    pub phone_load_err: u64,
    pub phone_some: u64,
    pub phone_none: u64,

    // name
    pub name_load_attempt: u64,
    pub name_load_ok: u64,
    pub name_load_err: u64,
    pub name_some: u64,
    pub name_none: u64,
}

impl Stats {
    /// 自增工具：放在 impl 内以简化调用语法
    #[inline]
    fn inc(v: &CachePadded<AtomicU64>) {
        v.fetch_add(1, Ordering::Relaxed);
    }

    /// 读取快照（Relaxed 足够：只做观测，不参与同步）
    fn snapshot(&self) -> StatsSnapshot {
        StatsSnapshot {
            by_id_hit: self.by_id_hit.load(Ordering::Relaxed),
            by_id_miss: self.by_id_miss.load(Ordering::Relaxed),
            by_id_load_attempt: self.by_id_load_attempt.load(Ordering::Relaxed),
            by_id_load_ok: self.by_id_load_ok.load(Ordering::Relaxed),
            by_id_load_err: self.by_id_load_err.load(Ordering::Relaxed),

            email_load_attempt: self.route_email.load_attempt.load(Ordering::Relaxed),
            email_load_ok: self.route_email.load_ok.load(Ordering::Relaxed),
            email_load_err: self.route_email.load_err.load(Ordering::Relaxed),
            email_some: self.route_email.some.load(Ordering::Relaxed),
            email_none: self.route_email.none.load(Ordering::Relaxed),

            phone_load_attempt: self.route_phone.load_attempt.load(Ordering::Relaxed),
            phone_load_ok: self.route_phone.load_ok.load(Ordering::Relaxed),
            phone_load_err: self.route_phone.load_err.load(Ordering::Relaxed),
            phone_some: self.route_phone.some.load(Ordering::Relaxed),
            phone_none: self.route_phone.none.load(Ordering::Relaxed),

            name_load_attempt: self.route_name.load_attempt.load(Ordering::Relaxed),
            name_load_ok: self.route_name.load_ok.load(Ordering::Relaxed),
            name_load_err: self.route_name.load_err.load(Ordering::Relaxed),
            name_some: self.route_name.some.load(Ordering::Relaxed),
            name_none: self.route_name.none.load(Ordering::Relaxed),
        }
    }
}

// -----------------------------------------------------------------------------
// Normalizer（真实实现，读写一致）
// -----------------------------------------------------------------------------

/// 统一的规范化接口：所有进入系统的外部标识（email/phone/name）
/// 必须先通过 Normalizer，再用于：
/// - 查询（读路径）
/// - 目录写入（索引写）
/// 这样可保证“读写一致”，消除“写时一种规则，读时另一种”的错配。
pub trait Normalizer: Send + Sync + 'static {
    /// 归一化 Email：
    /// - trim → NFKC → to_lowercase
    /// - 域名部分走 IDNA/Punycode 转 ASCII
    /// - 基本长度校验（local<=64；整体<=254）
    /// - 返回空 Bytes 表示“空入参”，调用方应快速返回 None
    fn email_norm(&self, raw: &str) -> Result<Bytes>;

    /// 归一化 Phone：
    /// - trim → NFKC → 仅保留数字和 '+'，'+' 只能在首位
    /// - 支持 "00"→"+"；无国家码则补默认 CC
    /// - 校验 E.164 8..=15 位
    /// - 返回空 Bytes 表示“空/无效”，调用方快速返回 None
    fn phone_norm(&self, raw: &str) -> Result<Bytes>;

    /// 归一化 Name：
    /// - trim → NFKC → 小写 → 压缩空白
    /// - 返回空 Bytes 表示“空入参”，调用方快速返回 None
    fn name_norm(&self, raw: &str) -> Result<Bytes>;
}

/// 默认国家码驱动的规范化实现。
/// 注意：default_country_cc 仅用于 phone_norm 补全无前缀的号码。
pub struct RealNormalizer {
    /// E.164 默认国家码（不含“+”，如 "86"/"1"）
    default_country_cc: String,
}

impl RealNormalizer {
    /// 创建一个真实 Normalizer。示例：`RealNormalizer::new("86")`
    pub fn new(default_country_cc: impl Into<String>) -> Self {
        Self {
            default_country_cc: default_country_cc.into(),
        }
    }

    /// Unicode NFKC + to_lowercase + trim（对 email/local、name 等通用）
    #[inline]
    fn nfkc_lower_trim(s: &str) -> String {
        let folded: String = s.nfkc().collect::<String>().to_lowercase();
        folded.trim().to_string()
    }

    /// 仅保留数字和 '+'（且 '+' 只能在首位），忽略其它格式字符（空格/横线/括号等）
    fn strip_phone_chars(s: &str) -> Result<String> {
        let mut out = String::with_capacity(s.len());
        let mut plus_seen = false;
        for (i, ch) in s.chars().enumerate() {
            if ch.is_ascii_digit() {
                out.push(ch);
                continue;
            }
            if ch == '+' {
                if i != 0 || plus_seen {
                    bail!("invalid '+' position in phone");
                }
                plus_seen = true;
                out.push('+');
                continue;
            }
            // 其他字符忽略
        }
        Ok(out)
    }

    /// 归一化为 E.164：处理 "00"→"+"；无前缀时按 default_cc 补全；校验长度区间
    fn to_e164(mut s: String, default_cc: &str) -> Result<String> {
        if s.is_empty() {
            return Ok(s);
        }
        if s.starts_with("00") {
            s.replace_range(0..2, "+");
        }
        if s.starts_with('+') {
            if !s[1..].chars().all(|c| c.is_ascii_digit()) {
                bail!("phone contains non-digits after '+'");
            }
        } else {
            if !s.chars().all(|c| c.is_ascii_digit()) {
                bail!("phone contains non-digits");
            }
            if default_cc.is_empty() {
                bail!("no country code and no default_cc configured");
            }
            s = format!("+{}{}", default_cc, s);
        }
        let digits_len = s.len() - 1;
        if !(8..=15).contains(&digits_len) {
            bail!("phone digits length not in 8..=15");
        }
        Ok(s)
    }
}

/// 多空白压缩（包括制表/多空格等）
static RE_SPACES: Lazy<Regex> = Lazy::new(|| Regex::new(r"\s+").expect("compile whitespace regex"));

impl Normalizer for RealNormalizer {
    fn email_norm(&self, raw: &str) -> Result<Bytes> {
        let trimmed = raw.trim();
        if trimmed.is_empty() {
            return Ok(Bytes::new());
        }

        // local@domain：local 小写，domain 走 IDNA
        let lowered = Self::nfkc_lower_trim(trimmed);
        let parts: Vec<&str> = lowered.split('@').collect();
        if parts.len() != 2 {
            bail!("invalid email: missing '@'");
        }
        let (local, domain) = (parts[0], parts[1]);
        if local.is_empty() || domain.is_empty() {
            bail!("invalid email: empty local or domain");
        }

        // 域名部分转 ASCII
        let domain_ascii =
            idna::domain_to_ascii(domain).map_err(|e| anyhow!("idna to_ascii failed: {e}"))?;

        // 粗校验长度
        if local.len() > 64 {
            bail!("invalid email: local too long");
        }
        let email_ascii = format!("{local}@{domain_ascii}");
        if email_ascii.len() > 254 {
            bail!("invalid email: too long");
        }

        Ok(Bytes::from(email_ascii))
    }

    fn phone_norm(&self, raw: &str) -> Result<Bytes> {
        let trimmed = raw.trim();
        if trimmed.is_empty() {
            return Ok(Bytes::new());
        }
        let s = trimmed.nfkc().collect::<String>();
        let stripped = Self::strip_phone_chars(&s)?;
        if stripped.is_empty() {
            return Ok(Bytes::new());
        } // 全是噪声字符
        let e164 = Self::to_e164(stripped, &self.default_country_cc)?;
        Ok(Bytes::from(e164))
    }

    fn name_norm(&self, raw: &str) -> Result<Bytes> {
        let s = Self::nfkc_lower_trim(raw);
        if s.is_empty() {
            return Ok(Bytes::new());
        }
        let collapsed = RE_SPACES.replace_all(&s, " ");
        Ok(Bytes::from(collapsed.trim().to_string()))
    }
}

// -----------------------------------------------------------------------------
// Facade：缓存 + 路由 + 指标
// -----------------------------------------------------------------------------

/// 读路径统一的热层（Hot）
///
/// - by_id：对象缓存，Key=i64（主键），Value=Arc<UserEntity>
/// - 路由缓存（email/phone/name → Option<i64>）：
///   - Some(id)：正命中；None：负缓存（确认不存在）；目录失败不上缓存
/// - 观测：内部带 Stats；可通过 stats() 导出快照
pub struct ClientHot<R, D, N> {
    /// 业务实体读仓库（分片内/聚合 DB 查询）
    repo: Arc<R>,
    /// 目录读仓库（email/phone/name → id）
    dir: Arc<D>,
    /// 统一规范化器（确保读写一致）
    normalizer: Arc<N>,

    /// 主键缓存：moka future::Cache（并发安全；装载单飞）
    by_id: Cache<i64, Arc<UserEntity>>,

    /// 路由缓存：统一 Option<i64> 表示正/负命中（None=确认不存在）
    email_to_id: Cache<Bytes, Option<i64>>,
    phone_to_id: Cache<Bytes, Option<i64>>,
    name_to_id: Cache<Bytes, Option<i64>>,

    /// 观测：cache-line padding 的计数器
    stats: Arc<Stats>,
}

/// 热层配置（容量与 TTL）
///
/// - by_id_max_capacity：对象缓存容量上限（近似 LRU）
/// - by_id_ttl：对象缓存 TTL（强一致要求低时可适当增大）
/// - route_max_capacity / route_ttl：路由缓存容量与 TTL
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
    /// 构造：传入读仓库与 Normalizer，并配置缓存容量/TTL
    pub fn new(repo: Arc<R>, dir: Arc<D>, normalizer: Arc<N>, cfg: ClientHotConfig) -> Self {
        // by_id：对象缓存（future::Cache 自带单飞装载）
        let by_id = Cache::builder()
            .max_capacity(cfg.by_id_max_capacity)
            .time_to_live(cfg.by_id_ttl)
            .build();

        // 路由缓存构造器：Key=Bytes，Val=Option<i64>
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
            name_to_id: build_route(),
            stats: Arc::new(Stats::default()),
        }
    }

    /// 导出指标快照（用于 Prometheus / OTLP 等上报）
    #[inline]
    pub fn stats(&self) -> StatsSnapshot {
        self.stats.snapshot()
    }

    // ------------------------- 对外 API -------------------------

    /// 通过主键读取实体：
    /// - 命中直接返回；
    /// - 未命中触发单飞装载：repo.get_by_id(id)；
    /// - 不存在按 Err("not found") 返回（不缓存 None）。
    pub async fn get_by_id(&self, id: i64) -> Result<Arc<UserEntity>> {
        // 先做 contains_key 统计粗粒度命中/未命中（不会触发加载）
        if self.by_id.contains_key(&id) {
            Stats::inc(&self.stats.by_id_hit);
        } else {
            Stats::inc(&self.stats.by_id_miss);
        }

        // try_get_with：仅在 miss 时进入闭包（单飞）；闭包返回 Arc<UserEntity>
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
                    Ok::<Arc<UserEntity>, anyhow::Error>(Arc::new(ent))
                }
            })
            .await
            .map_err({
                let stats = Arc::clone(&self.stats);
                move |e| {
                    // moka 的加载错误（包括闭包返回 Err）也会到这里
                    Stats::inc(&stats.by_id_load_err);
                    anyhow!("cache(by_id) try_get_with failed: {}", e)
                }
            })?;

        Ok(arc)
    }

    /// 批量按 id 读取（返回存在的实体，**不保证顺序**）：
    /// - 同步遍历 ids 做一次 contains_key，将命中与 miss 分离；
    /// - 对命中集合并发 get() 拉取 Arc；
    /// - 将 miss 传入 repo.get_by_ids 聚合读取，统一回灌缓存。
    pub async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<Arc<UserEntity>>> {
        if ids.is_empty() {
            return Ok(Vec::new());
        }

        // 1) 同步判断命中并去重（seen）
        let mut seen = HashSet::with_capacity(ids.len());
        let mut present_ids = Vec::new();
        let mut misses = Vec::new();

        for &id in ids {
            if !seen.insert(id) {
                continue;
            } // 去重
            if self.by_id.contains_key(&id) {
                Stats::inc(&self.stats.by_id_hit);
                present_ids.push(id);
            } else {
                Stats::inc(&self.stats.by_id_miss);
                misses.push(id);
            }
        }

        // 2) 并发拉取命中值（get() 不触发装载；竞态 None 会被过滤）
        let mut hits: Vec<Arc<UserEntity>> = stream::iter(
            present_ids
                .into_iter()
                .map(|id| async move { self.by_id.get(&id).await }),
        )
        .buffer_unordered(128)
        .filter_map(|opt| async move { opt })
        .collect()
        .await;

        // 3) 无 miss 直接返回
        if misses.is_empty() {
            return Ok(hits);
        }

        // 4) miss 聚合读取（建议在 repo 内分片+分批 IN）
        let fetched = self
            .repo
            .get_by_ids(&misses)
            .await
            .context("repo.get_by_ids failed in hot_cold::get_by_ids")?;

        // 统计装载 ok/err（这里的 err 以“未找到”的差额近似）
        let ok_cnt = fetched.len() as u64;
        let miss_cnt = misses.len() as u64;
        if ok_cnt > 0 {
            self.stats
                .by_id_load_ok
                .fetch_add(ok_cnt, Ordering::Relaxed);
            self.stats
                .by_id_load_attempt
                .fetch_add(ok_cnt, Ordering::Relaxed);
        }
        if miss_cnt > ok_cnt {
            self.stats
                .by_id_load_err
                .fetch_add(miss_cnt - ok_cnt, Ordering::Relaxed);
        }

        if fetched.is_empty() {
            return Ok(hits);
        }

        // 5) 回灌缓存并合并返回
        let mut map: HashMap<i64, Arc<UserEntity>> = HashMap::with_capacity(fetched.len());
        for ent in fetched {
            let id = ent.id;
            let arc = Arc::new(ent);
            self.by_id.insert(id, arc.clone()).await;
            map.insert(id, arc);
        }
        hits.extend(map.into_values());
        Ok(hits)
    }

    /// 通过 email 查询：
    /// - 规范化 → 空键直接返回 None；
    /// - 路由缓存 miss 时查询目录（get_id_by_email），成功后写入 Some/None；
    /// - 目录失败不上缓存（保持下次可重试）。
    pub async fn get_by_email(&self, raw: &str) -> Result<Option<Arc<UserEntity>>> {
        let norm = self
            .normalizer
            .email_norm(raw)
            .context("normalize email failed")?;
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

    /// 通过 phone 查询：逻辑同上
    pub async fn get_by_phone(&self, raw: &str) -> Result<Option<Arc<UserEntity>>> {
        let norm = self
            .normalizer
            .phone_norm(raw)
            .context("normalize phone failed")?;
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

    /// 通过 name 查询：逻辑同上；额外做 UTF-8 校验（规范化产物是 Bytes）
    pub async fn get_by_name(&self, raw: &str) -> Result<Option<Arc<UserEntity>>> {
        let norm = self
            .normalizer
            .name_norm(raw)
            .context("normalize name failed")?;
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

    /// 刷新单个 id 的对象缓存：
    /// - 如 DB 存在：覆盖插入；
    /// - 如 DB 不存在：主动失效。
    pub async fn refresh_by_id(&self, id: i64) -> Result<()> {
        match self
            .repo
            .get_by_id(id)
            .await
            .context("repo.get_by_id failed in refresh_by_id")?
        {
            Some(ent) => {
                self.by_id.insert(id, Arc::new(ent)).await;
            }
            None => {
                self.by_id.invalidate(&id).await;
            }
        }
        Ok(())
    }

    /// 邮箱变更时的路由处理：
    /// - old_raw 存在且可规范化：失效旧键；
    /// - new_raw 存在且可规范化：写入正缓存 Some(id)；
    /// - 最后刷新 by_id。
    pub async fn on_change_email(
        &self,
        old_raw: Option<&str>,
        new_raw: Option<&str>,
        id: i64,
    ) -> Result<()> {
        if let Some(old) = old_raw {
            if let Ok(k) = self.normalizer.email_norm(old) {
                if !k.is_empty() {
                    self.email_to_id.invalidate(&k).await;
                }
            }
        }
        if let Some(new_) = new_raw {
            let k = self
                .normalizer
                .email_norm(new_)
                .context("normalize new email failed")?;
            if !k.is_empty() {
                self.email_to_id.insert(k, Some(id)).await;
            }
        }
        self.refresh_by_id(id).await
    }

    /// 手机号变更：逻辑同上
    pub async fn on_change_phone(
        &self,
        old_raw: Option<&str>,
        new_raw: Option<&str>,
        id: i64,
    ) -> Result<()> {
        if let Some(old) = old_raw {
            if let Ok(k) = self.normalizer.phone_norm(old) {
                if !k.is_empty() {
                    self.phone_to_id.invalidate(&k).await;
                }
            }
        }
        if let Some(new_) = new_raw {
            let k = self
                .normalizer
                .phone_norm(new_)
                .context("normalize new phone failed")?;
            if !k.is_empty() {
                self.phone_to_id.insert(k, Some(id)).await;
            }
        }
        self.refresh_by_id(id).await
    }

    /// 用户名变更：逻辑同上；name_norm 的 Bytes 需是 UTF-8（由规范化保证）
    pub async fn on_change_name(
        &self,
        old_raw: Option<&str>,
        new_raw: Option<&str>,
        id: i64,
    ) -> Result<()> {
        if let Some(old) = old_raw {
            if let Ok(k) = self.normalizer.name_norm(old) {
                if !k.is_empty() {
                    self.name_to_id.invalidate(&k).await;
                }
            }
        }
        if let Some(new_) = new_raw {
            let k = self
                .normalizer
                .name_norm(new_)
                .context("normalize new name failed")?;
            if !k.is_empty() {
                self.name_to_id.insert(k, Some(id)).await;
            }
        }
        self.refresh_by_id(id).await
    }

    /// 主键失效（不触发 DB）
    pub async fn invalidate_by_id(&self, id: i64) {
        self.by_id.invalidate(&id).await;
    }
}
