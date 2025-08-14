use std::{time::Duration, sync::Arc};
use sysinfo::{System};
use num_cpus;

/// 估算每条目的**总**内存占用（包含键、值、哈希/指针等开销）
/// - avg_key_bytes：平均 key 大小（字节）
/// - avg_value_bytes：平均 value 大小（字节）
/// - overhead_factor：结构体/分配/哈希等隐含开销放大系数（建议 1.3~2.0，保守一些）
/// 返回：每条大致占用的字节数
fn estimate_entry_bytes(avg_key_bytes: usize, avg_value_bytes: usize, overhead_factor: f64) -> usize {
    let raw = avg_key_bytes + avg_value_bytes;
    ((raw as f64) * overhead_factor).ceil() as usize
}

/// 把系统内存信息读取为（total, available），单位字节
fn read_mem_bytes() -> (u64, u64) {
    let mut sys = System::new();
    sys.refresh_memory();
    // sysinfo 0.30+ 返回字节；如果你使用旧版本，请把下面当成 KB 再 * 1024
    (sys.total_memory(), sys.available_memory())
}

#[derive(Debug, Clone)]
pub struct CacheAutoTune {
    pub shards: usize,
    pub per_shard_main_capacity: u64, // DashMap 主存条目上限
    pub per_shard_hot_capacity: u64,  // moka 热键条目上限
    pub per_shard_segments: usize,    // moka 分段
    pub tti: Duration,                // 热键 TTI
}

/// 自动根据内存与平均条目大小做参数规划
///
/// - shards: 你要开的分片数量（外层自行确定）
/// - avg_key_bytes / avg_value_bytes: 你的 Key/Value 平均字节数（尽量真实）
/// - reserve_ratio: 给**非缓存**部分预留比例（0.4 表示预留 40% 给业务/其他）
/// - max_use_ratio: 最多使用**总内存**的多少（例如 0.25 表示最多 25%）
/// - overhead_factor: 每条目的开销放大因子（建议 1.5~1.8）
/// - hot_ratio: 热键缓存占主存条目数的比例（例如 0.2 表示热键上限为主存上限的 20%）
/// - default_tti: 默认 TTI
pub fn auto_tune_cache(
    shards: usize,
    avg_key_bytes: usize,
    avg_value_bytes: usize,
    reserve_ratio: f64,
    max_use_ratio: f64,
    overhead_factor: f64,
    hot_ratio: f64,
    default_tti: Duration,
) -> CacheAutoTune {
    let (total, avail) = read_mem_bytes();

    // 预算：既不能超过可用内存的一定比例，也不能超过总内存的一定比例
    let usable_by_avail = (avail as f64) * (1.0 - reserve_ratio); // 给系统/业务留出 reserve_ratio
    let usable_by_total = (total as f64) * max_use_ratio;         // 不超过总内存的一定比例
    let budget_bytes = usable_by_avail.min(usable_by_total).max(64.0 * 1024.0 * 1024.0); // 至少 64MB

    // 条目大小估算（主存）：DashMap 中存 V；热键只存 Key 与 ()，所以热键条目更轻
    let per_entry_main = estimate_entry_bytes(avg_key_bytes, avg_value_bytes, overhead_factor) as f64;
    let per_entry_hot  = estimate_entry_bytes(avg_key_bytes, 0, overhead_factor * 0.7) as f64;

    // 把预算在主存与热键之间分配（主存重，热键轻）
    // 这里用“条目数比例”更直观：最终热键条目上限 ≈ 主存条目上限 * hot_ratio
    let main_budget_bytes = budget_bytes * 0.85;  // 85% 给主存
    let hot_budget_bytes  = budget_bytes * 0.15;  // 15% 给热键（通常够用）

    let total_main_entries = (main_budget_bytes / per_entry_main).floor().max(1.0);
    let total_hot_entries  = (hot_budget_bytes  / per_entry_hot ).floor().max(1.0);

    // 按分片均分，向下取整
    let per_shard_main = (total_main_entries / shards as f64).floor().max(1.0) as u64;

    // 热键上限 = min(按内存预算, 主存*hot_ratio) / shards
    let cap_hot_by_ratio = (total_main_entries * hot_ratio).floor().max(1.0);
    let cap_hot_final_total = total_hot_entries.min(cap_hot_by_ratio);
    let per_shard_hot = (cap_hot_final_total / shards as f64).floor().max(1024.0) as u64; // 给个合理下限

    // segments：按 CPU 数取一个 2 的幂，限制在 [8, 64]
    let cpus = num_cpus::get().max(1);
    let mut seg = cpus.next_power_of_two();
    seg = seg.clamp(8, 64);

    CacheAutoTune {
        shards,
        per_shard_main_capacity: per_shard_main,
        per_shard_hot_capacity: per_shard_hot,
        per_shard_segments: seg,
        tti: default_tti,
    }
}
