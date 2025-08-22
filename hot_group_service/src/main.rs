mod member;
mod grpc;
mod store;
mod hot_cold;
mod profile;

use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use crate::grpc::group_service::group_service_server::GroupServiceServer;
use crate::grpc::group_service_impl::GroupServiceImpl;
use crate::hot_cold::{HotColdConfig, HotColdFacade};
use crate::member::shard_map::ShardMap;
use crate::store::mysql::MySqlStore;
use common::config::{get_db, AppConfig};
use log::{info, warn};
use sqlx::mysql::MySqlPoolOptions;
use tokio::signal;
// 成员冷存（你已有）
use crate::profile::{GroupProfileCache, MySqlGroupProfileStore};
// 群信息 L1 写穿

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
        hard_cap_min: u64,
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
    // 日志（读取 RUST_LOG，默认 info）
    let app_cfg = AppConfig::init("./config-group.toml").await;

    // ---------- 环境配置 ----------
    let hot_tti_secs: u64 = std::env::var("HOT_TTI_SECS").ok().and_then(|v| v.parse().ok()).unwrap_or(57_600); // 16h
    let (hot_capacity, debug_line) = hot_capacity::calc_hot_capacity_from_mem();

    let shard_count: usize      = parse_env("SHARD_COUNT", 1024usize);
    let per_group_shard: usize  = parse_env("PER_GROUP_SHARD", 1usize);

    // HashShardMap 分页缓存
    let page_cache_cap: u32     = parse_env("PAGE_CACHE_CAP", 100_000u32);
    let page_cache_tti_secs: u64= parse_env("PAGE_CACHE_TTI_SECS", 300u64);

    // HotColdFacade 去抖
    let persist_debounce_ms: u64= parse_env("PERSIST_DEBOUNCE_MS", 200u64);

    // 群信息 L1 写穿
    let profile_l1_cap: u64     = parse_env("PROFILE_L1_CAP", 1_000_000u64);
    let profile_l1_tti_secs: u64= parse_env("PROFILE_L1_TTI_SECS", 600u64);
    let grpc_cfg=app_cfg.grpc.clone().expect("grpc config missing");
    // gRPC 绑定地址
    let addr: SocketAddr = std::env::var("BIND_ADDR")
        .unwrap_or_else(|_| format!("{}",grpc_cfg.server_addr.unwrap()))
        .parse()
        .expect("invalid BIND_ADDR");

    // 数据库（仅供群信息 L1 写穿；成员冷存仍用你现有的 MySqlStore）

    info!(
        "hot cache decided: cap={}, tti={}s, shard_count={}, per_group_shard={}, {}",
        hot_capacity, hot_tti_secs, shard_count, per_group_shard, debug_line
    );
    info!(
        "page_cache: cap={}, tti={}s; debounce={}ms; profile_l1: cap={}, tti={}s",
        page_cache_cap, page_cache_tti_secs, persist_debounce_ms, profile_l1_cap, profile_l1_tti_secs
    );
    info!("gRPC will listen on {}", addr);

    // ---------- 连接池（群信息用） ----------


    // ---------- 成员热层 ----------
    // HashShardMap（带分页缓存）
    let map = Arc::new(ShardMap::new(
        shard_count,
        per_group_shard,
        page_cache_cap,
        Some(Duration::from_secs(page_cache_tti_secs)),
    ));
    // 成员冷存：沿用你现有的实现
    let storage = Arc::new(MySqlStore::new());
    // 热/冷门面（带去抖/单飞/逐出持久化）
    let hot_cfg = HotColdConfig {
        hot_capacity,
        hot_tti: Duration::from_secs(hot_tti_secs),
        persist_debounce: Duration::from_millis(persist_debounce_ms),
    };
    let facade = Arc::new(HotColdFacade::with_config(map, storage, hot_cfg));
    // ---------- 群信息 L1 写穿 ----------
    let profile_store = MySqlGroupProfileStore::new();
    let profile_cache = Arc::new(GroupProfileCache::new(
        Arc::new(profile_store),
        profile_l1_cap,
        profile_l1_tti_secs,
    ));

    // ---------- gRPC Server ----------
    // 若你的 GroupServiceImpl 仍旧构造：`{ facade }`，把下一行改为那个版本即可
    let svc_impl = GroupServiceImpl::new(facade.clone(),  profile_cache.clone());
    let svc = GroupServiceServer::new(svc_impl);

    tonic::transport::Server::builder()
        .add_service(svc)
        .serve_with_shutdown(addr, async {
            let _ = signal::ctrl_c().await;
            warn!("shutting down... flushing hot groups");
            facade.flush_all().await;
            warn!("flush done. bye");
        })
        .await?;

    Ok(())
}

// 兜底环境读取
fn parse_env<T: std::str::FromStr>(key: &str, default: T) -> T {
    std::env::var(key).ok().and_then(|v| v.parse().ok()).unwrap_or(default)
}
