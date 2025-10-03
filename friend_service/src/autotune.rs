use num_cpus;
use std::time::Duration;
use sysinfo::System;

/// —— 默认策略常量 ——
/// 最小可用预算（防止过小导致容量为 0）
const MIN_BUDGET_BYTES: u64 = 64 * 1024 * 1024; // 64 MiB
/// 主存/热键预算拆分比例（总和建议 ≤ 1.0）
const DEFAULT_SPLIT_MAIN: f64 = 0.85;
const DEFAULT_SPLIT_HOT: f64 = 0.15;
/// moka 分段上下限
const DEFAULT_SEGMENTS_MIN: usize = 8;
const DEFAULT_SEGMENTS_MAX: usize = 64;
/// 每分片热键最低条目数（避免极小容量导致命中率崩溃）
const DEFAULT_MIN_HOT_PER_SHARD: u64 = 1024;

/// 估算每条目的**总**内存占用（包含键、值、哈希/指针等开销）
fn estimate_entry_bytes(
    avg_key_bytes: usize,
    avg_value_bytes: usize,
    overhead_factor: f64,
) -> usize {
    let overhead = overhead_factor.clamp(1.0, 4.0);
    let raw = avg_key_bytes.saturating_add(avg_value_bytes);
    ((raw as f64) * overhead).ceil() as usize
}

/// 把系统内存信息读取为（total, available），单位字节
fn read_mem_bytes() -> (u64, u64) {
    let mut sys = System::new();
    sys.refresh_memory();
    (sys.total_memory(), sys.available_memory()) // sysinfo 0.30+ 已是字节
}
#[derive(Clone)]
pub struct AutoTuneConfig {
    pub shards: usize,
    pub avg_key_bytes: usize,
    pub avg_value_bytes: usize,
    pub reserve_ratio: f64,
    pub max_use_ratio: f64,
    pub overhead_factor: f64,
    pub hot_ratio: f64,
    pub split_main_ratio: f64,
    pub split_hot_ratio: f64,
    pub default_tti: Duration,
    pub segments_min: usize,
    pub segments_max: usize,
    pub min_hot_per_shard: u64,
    pub mem_reader: Option<fn() -> (u64, u64)>,
}

impl Default for AutoTuneConfig {
    fn default() -> Self {
        Self {
            shards: 16,
            avg_key_bytes: 32,
            avg_value_bytes: 64,
            reserve_ratio: 0.4,
            max_use_ratio: 0.25,
            overhead_factor: 1.6,
            hot_ratio: 0.2,
            split_main_ratio: DEFAULT_SPLIT_MAIN,
            split_hot_ratio: DEFAULT_SPLIT_HOT,
            default_tti: Duration::from_secs(15 * 60),
            segments_min: DEFAULT_SEGMENTS_MIN,
            segments_max: DEFAULT_SEGMENTS_MAX,
            min_hot_per_shard: DEFAULT_MIN_HOT_PER_SHARD,
            mem_reader: None,
        }
    }
}

/// 输出结果（带观测字段，方便日志/指标）
#[derive(Debug, Clone)]
pub struct CacheAutoTune {
    pub shards: usize,
    pub per_shard_main_capacity: u64, // DashMap 主存条目上限
    pub per_shard_hot_capacity: u64,  // moka 热键条目上限
    pub per_shard_segments: usize,    // moka 分段
    pub tti: Duration,                // 热键 TTI

    // —— 观测字段（可选使用）——
    pub budget_bytes: u64,           // 实际用于缓存的总预算（字节）
    pub total_main_entries: u64,     // 预算推导出的主存总条目
    pub total_hot_entries: u64,      // 预算推导出的热键总条目
    pub per_entry_main_bytes: usize, // 主存单条估算字节
    pub per_entry_hot_bytes: usize,  // 热键单条估算字节
}

/// 自动根据内存与平均条目大小做参数规划（重构版）
pub fn auto_tune_cache(cfg: &AutoTuneConfig) -> CacheAutoTune {
    // —— 参数清洗与边界保护 ——
    let shards = cfg.shards.max(1);
    let reserve = cfg.reserve_ratio.clamp(0.0, 0.95);
    let max_use = cfg.max_use_ratio.clamp(0.01, 0.9);
    let hot_ratio = cfg.hot_ratio.clamp(0.0, 1.0);

    let split_main = cfg.split_main_ratio.clamp(0.0, 1.0);
    let split_hot = cfg.split_hot_ratio.clamp(0.0, 1.0);
    // 若用户把两者调大，总和 > 1.0，则按比例归一化
    let (split_main, split_hot) = normalize_two(split_main, split_hot);

    // 读取内存
    let (total, avail) = match &cfg.mem_reader {
        Some(f) => (f)(),
        None => read_mem_bytes(),
    };

    // 预算 —— 不超过“可用 * (1 - reserve)”且不超过“总内存 * max_use”
    let budget_bytes = calc_budget(total, avail, reserve, max_use);

    // 条目大小估算（主存 & 热键）
    let per_entry_main =
        estimate_entry_bytes(cfg.avg_key_bytes, cfg.avg_value_bytes, cfg.overhead_factor) as f64;
    // 热键仅以 Key 为主，overhead 适当减少
    let per_entry_hot =
        estimate_entry_bytes(cfg.avg_key_bytes, 0, cfg.overhead_factor * 0.7) as f64;

    // 主存/热键预算拆分
    let main_budget_bytes = (budget_bytes as f64) * split_main;
    let hot_budget_bytes = (budget_bytes as f64) * split_hot;

    // 预算转条目数（总量）
    let (total_main_entries, total_hot_entries) = calc_entries(
        main_budget_bytes,
        hot_budget_bytes,
        per_entry_main,
        per_entry_hot,
        hot_ratio,
    );

    // 按分片均分，并给出下限防抖
    let per_shard_main = ((total_main_entries as f64) / shards as f64)
        .floor()
        .max(1.0) as u64;
    let per_shard_hot = ((total_hot_entries as f64) / shards as f64)
        .floor()
        .max(cfg.min_hot_per_shard as f64) as u64;

    // segments：按 CPU 数取 2 的幂并夹在 [segments_min, segments_max]
    let per_shard_segments = calc_segments(cfg.segments_min, cfg.segments_max);

    CacheAutoTune {
        shards,
        per_shard_main_capacity: per_shard_main,
        per_shard_hot_capacity: per_shard_hot,
        per_shard_segments,
        tti: cfg.default_tti,

        // 观测值
        budget_bytes,
        total_main_entries,
        total_hot_entries,
        per_entry_main_bytes: per_entry_main as usize,
        per_entry_hot_bytes: per_entry_hot as usize,
    }
}

/// —— 内部工具 ——

// 预算：min(可用*(1-reserve), 总内存*max_use)，且 ≥ MIN_BUDGET_BYTES
fn calc_budget(total: u64, avail: u64, reserve: f64, max_use: f64) -> u64 {
    let usable_by_avail = (avail as f64) * (1.0 - reserve);
    let usable_by_total = (total as f64) * max_use;
    let budget = usable_by_avail
        .min(usable_by_total)
        .max(MIN_BUDGET_BYTES as f64);
    budget as u64
}

// 由预算推导条目数；热键条目额外受 hot_ratio 约束：≤ 主存条目 * hot_ratio
fn calc_entries(
    main_budget_bytes: f64,
    hot_budget_bytes: f64,
    per_entry_main: f64,
    per_entry_hot: f64,
    hot_ratio: f64,
) -> (u64, u64) {
    let total_main_entries = (main_budget_bytes / per_entry_main).floor().max(1.0) as u64;
    let hot_by_mem = (hot_budget_bytes / per_entry_hot).floor().max(1.0) as u64;
    let hot_by_ratio = ((total_main_entries as f64) * hot_ratio).floor().max(1.0) as u64;
    (total_main_entries, hot_by_mem.min(hot_by_ratio))
}

// 计算分段数：按 CPU 数上取 2 的幂，并夹取到区间
fn calc_segments(min_seg: usize, max_seg: usize) -> usize {
    let cpus = num_cpus::get().max(1);
    let pow2 = cpus.next_power_of_two();
    pow2.clamp(min_seg.max(1), max_seg.max(min_seg))
}

// 两个比例大于 1 的归一化：按比重缩放使其和为 1
fn normalize_two(a: f64, b: f64) -> (f64, f64) {
    let sum = a + b;
    if sum <= 1.0 || sum == 0.0 {
        (a, b)
    } else {
        (a / sum, b / sum)
    }
}
