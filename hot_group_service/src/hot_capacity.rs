use sysinfo::System;

/// Memory usage model for estimating hot group cache capacity.
#[derive(Debug, Clone)]
pub struct HotMemModel {
    pub bytes_per_member: usize,
    pub bytes_per_group_overhead: usize,
    pub avg_members_per_group: usize,
    pub mem_utilization: f64,
}

/// Decide the hot cache capacity based on a simple memory model.
///
/// Returns `(capacity, debug_line)` where `debug_line` captures the
/// important inputs that led to the final decision and can be printed
/// in logs for troubleshooting.
pub fn auto_hot_groups_capacity(model: HotMemModel, cap_max: u64, cap_min: u64) -> (u64, String) {
    let mut sys = System::new();
    sys.refresh_memory();

    let total_bytes = sys.total_memory();
    let available_bytes = sys.available_memory();

    // Clamp util to a sane range; avoid fully exhausting the system.
    let util = model.mem_utilization.clamp(0.05, 0.9);

    let per_group_bytes = {
        let member_bytes = model
            .bytes_per_member
            .saturating_mul(model.avg_members_per_group);
        let total = member_bytes
            .saturating_add(model.bytes_per_group_overhead)
            .max(1);
        total as f64
    };

    let usable_limit = ((available_bytes as f64).min(total_bytes as f64)) * util;
    let raw_capacity = if per_group_bytes > 0.0 {
        (usable_limit / per_group_bytes).floor().max(1.0) as u64
    } else {
        cap_min.max(1)
    };

    let (lo, hi) = if cap_min <= cap_max {
        (cap_min, cap_max)
    } else {
        (cap_max, cap_min)
    };

    let decided = raw_capacity.clamp(lo, hi);

    let debug_line = format!(
        "total={}B avail={}B util={:.02} usable={}B per_group={}B raw_cap={} clamp=[{},{}]",
        total_bytes,
        available_bytes,
        util,
        usable_limit as u64,
        per_group_bytes as u64,
        raw_capacity,
        lo,
        hi,
    );

    (decided, debug_line)
}
