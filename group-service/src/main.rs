mod db;
mod grpc;
mod store;
mod hot_cold;

use std::net::SocketAddr;
use std::sync::Arc;

use tokio::signal;
use log::{info, warn};
use crate::db::hash_shard_map::HashShardMap;
use crate::grpc::group_service::group_service_server::GroupServiceServer;
use crate::grpc::group_service_impl::GroupServiceImpl;
use crate::hot_cold::HotColdFacade;
use crate::store::mysql::MySqlStore;

mod hot_capacity {
    use std::env;
    use sysinfo::System;

    #[derive(Clone, Copy)]
    pub struct HotMemModel {
        pub bytes_per_member: usize,
        pub bytes_per_group_overhead: usize,
        pub avg_members_per_group: usize,
        pub mem_utilization: f64,
    }

    fn env_parse<T: std::str::FromStr>(key: &str, default: T) -> T {
        env::var(key).ok().and_then(|v| v.parse().ok()).unwrap_or(default)
    }

    pub fn auto_hot_groups_capacity(
        model: HotMemModel,
        hard_cap_max: u64,
        hard_cap_min: u64
    ) -> (u64, String) {
        if let Ok(v) = std::env::var("HOT_GROUPS") {
            if let Ok(n) = v.parse::<u64>() {
                return (n.clamp(hard_cap_min, hard_cap_max), "env(HOT_GROUPS)".to_string());
            }
        }

        let avg_members = env_parse("HOT_AVG_MEMBERS", model.avg_members_per_group);
        let bytes_per_member = env_parse("HOT_BYTES_PER_MEMBER", model.bytes_per_member);
        let bytes_per_group_overhead = env_parse("HOT_BYTES_PER_GROUP", model.bytes_per_group_overhead);
        let mem_utilization = env_parse("HOT_MEM_UTIL", model.mem_utilization).clamp(0.05, 0.95);

        let mut sys = System::new();
        sys.refresh_memory();
        let total_bytes = sys.total_memory() as u64;
        let avail_bytes = sys.available_memory() as u64;

        let budget_bytes = (avail_bytes as f64 * mem_utilization) as u64;
        let bytes_per_group = bytes_per_group_overhead as u64 + (avg_members as u64) * (bytes_per_member as u64);
        let cap = if bytes_per_group == 0 {
            hard_cap_min.max(1)
        } else {
            ((budget_bytes / bytes_per_group) as f64 * 0.9) as u64
        }
            .clamp(hard_cap_min, hard_cap_max);

        let debug = format!(
            "auto(total={} MB, avail={} MB, budget={} MB; group≈{} B = {} + {}*{}; util={:.2})",
            total_bytes / 1_048_576,
            avail_bytes / 1_048_576,
            budget_bytes / 1_048_576,
            bytes_per_group,
            bytes_per_group_overhead,
            avg_members,
            bytes_per_member,
            mem_utilization
        );

        (cap, debug)
    }

    pub fn calc_hot_capacity_from_mem() -> (u64, String) {
        let model = HotMemModel {
            bytes_per_member: env_parse("HOT_BYTES_PER_MEMBER", 120usize),
            bytes_per_group_overhead: env_parse("HOT_BYTES_PER_GROUP", 2_048usize),
            avg_members_per_group: env_parse("HOT_AVG_MEMBERS", 100usize),
            mem_utilization: env_parse("HOT_MEM_UTIL", 0.50f64),
        };
        auto_hot_groups_capacity(model, 1_000_000, 1_000)
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 初始化日志（默认读取 RUST_LOG）
    env_logger::init();

    let hot_tti_secs: u64 = std::env::var("HOT_TTI_SECS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(57_600); // 16 小时

    let (hot_capacity, debug_line) = hot_capacity::calc_hot_capacity_from_mem();

    let shard_count: usize = std::env::var("SHARD_COUNT").ok().and_then(|v| v.parse().ok()).unwrap_or(1024);
    let per_group_shard: usize = std::env::var("PER_GROUP_SHARD").ok().and_then(|v| v.parse().ok()).unwrap_or(1);

    info!(
        "hot cache capacity decided: hot_capacity={}, hot_tti_secs={}, shard_count={}, per_group_shard={}, {}",
        hot_capacity, hot_tti_secs, shard_count, per_group_shard, debug_line
    );

    let map = Arc::new(HashShardMap::new(shard_count, per_group_shard));
    let storage = Arc::new(MySqlStore::new());
    let facade = Arc::new(HotColdFacade::new(map, storage, hot_capacity, hot_tti_secs));

    let svc = GroupServiceImpl { facade: facade.clone() };
    let addr: SocketAddr = std::env::var("BIND_ADDR")
        .unwrap_or_else(|_| "0.0.0.0:50051".to_string())
        .parse()
        .expect("invalid BIND_ADDR");

    info!("starting gRPC server on {}", addr);

    tonic::transport::Server::builder()
        .add_service(GroupServiceServer::new(svc))
        .serve_with_shutdown(addr, async {
            let _ = signal::ctrl_c().await;
            warn!("shutting down...");
        })
        .await?;

    Ok(())
}

// 如果你项目里没有 parse_env，这里给一个兜底实现
#[allow(dead_code)]
fn parse_env<T: std::str::FromStr>(key: &str, default: T) -> T {
    std::env::var(key).ok().and_then(|v| v.parse().ok()).unwrap_or(default)
}
