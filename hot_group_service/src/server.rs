use std::mem;
use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcServiceServer;
use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_arb_client::integration;
use crate::grpc_arb_client::server::ArbClientImpl;
use crate::grpc_msg_group::group_service::group_service_server::GroupServiceServer;
use crate::grpc_msg_group::group_service_impl::GroupServiceImpl;
use crate::hot_cold::{HotColdConfig, HotColdFacade};
use crate::member::shard_map::ShardMap;
use crate::profile::{GroupProfileCache, MySqlGroupProfileStore};
use crate::store::mysql::MySqlStore;
use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::config::{get_db, AppConfig};
use log::{info, warn};
use tokio::signal;
use tonic::service::Routes;
use tonic::transport::Server;

pub async fn start() -> Result<()> {
    let cfg = AppConfig::get();
    let grpc_cfg = cfg
        .grpc
        .as_ref()
        .ok_or_else(|| anyhow!("grpc config missing"))?;
    let http_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let bind_addr_str = format!("{}:{}", http_cfg.host, http_cfg.port);
    let bind_addr: SocketAddr = bind_addr_str
        .parse()
        .with_context(|| format!("invalid http host:port: {}", bind_addr_str))?;

    if let Some(client_addr) = &grpc_cfg.client_addr {
        if client_addr != &bind_addr_str {
            warn!(
                "grpc.client_addr ({}) != server host:port ({}); using HTTP port for binding",
                client_addr, bind_addr_str
            );
        }
    } else {
        warn!(
            "grpc.client_addr missing; defaulting to HTTP port {} for registration",
            bind_addr_str
        );
    }

    let hot_mem_model = crate::hot_capacity::HotMemModel {
        bytes_per_member: env_parse("HOT_BYTES_PER_MEMBER", 128usize),
        bytes_per_group_overhead: env_parse("HOT_BYTES_PER_GROUP", 64usize),
        avg_members_per_group: env_parse("HOT_AVG_MEMBERS", 32usize),
        mem_utilization: env_parse("HOT_MEM_UTIL", 0.5_f64),
    };
    let (hot_capacity, debug_line) = crate::hot_capacity::auto_hot_groups_capacity(
        hot_mem_model,
        env_parse("HOT_CAP_MAX", 1_000_000_u64),
        env_parse("HOT_CAP_MIN", 1_000_u64),
    );
    let hot_tti_secs = env_parse("HOT_TTI_SECS", 300u64);
    let shard_count = env_parse("SHARD_COUNT", 1024usize);
    let per_group_shard = env_parse("PER_GROUP_SHARD", 1usize);
    let page_cache_cap = env_parse("PAGE_CACHE_CAP", 100_000u32);
    let page_cache_tti_secs = env_parse("PAGE_CACHE_TTI_SECS", 300u64);
    let persist_debounce_ms = env_parse("PERSIST_DEBOUNCE_MS", 200u64);
    let profile_l1_cap = env_parse("PROFILE_L1_CAP", 1_000_000u64);
    let profile_l1_tti_secs = env_parse("PROFILE_L1_TTI_SECS", 600u64);

    let map = Arc::new(ShardMap::new(
        shard_count,
        per_group_shard,
        page_cache_cap,
        Some(Duration::from_secs(page_cache_tti_secs)),
    ));
    let pool = get_db();
    let storage = Arc::new(MySqlStore::new());
    let hot_cfg = HotColdConfig {
        hot_capacity,
        hot_tti: Duration::from_secs(hot_tti_secs),
        persist_debounce: Duration::from_millis(persist_debounce_ms),
    };
    let facade = Arc::new(HotColdFacade::with_config(map, storage, hot_cfg));

    let profile_store = MySqlGroupProfileStore::new();
    let profile_cache = Arc::new(GroupProfileCache::new(
        Arc::new(profile_store),
        profile_l1_cap,
        profile_l1_tti_secs,
    ));

    async fn healthz() -> Json<serde_json::Value> {
        Json(serde_json::json!({"ok": true}))
    }

    info!(
        "hot cache decided: cap={}, tti={}s, shard_count={}, per_group_shard={}, {}",
        hot_capacity, hot_tti_secs, shard_count, per_group_shard, debug_line
    );

    integration::start(NodeType::GroupNode).await?;

    let svc_impl = GroupServiceImpl::new(facade.clone(), profile_cache.clone());
    let svc = GroupServiceServer::new(svc_impl);
    let rest_router = Router::new().route("/healthz", get(healthz));

    let mut routes =
        Routes::new(svc).add_service(ArbClientRpcServiceServer::new(ArbClientImpl::default()));

    let router_slot = routes.axum_router_mut();
    *router_slot = mem::take(router_slot).fallback_service(rest_router);

    let shutdown_facade = facade.clone();
    Server::builder()
        .accept_http1(true)
        .add_routes(routes)
        .serve_with_shutdown(bind_addr, async move {
            if let Err(err) = signal::ctrl_c().await {
                warn!("failed to listen for shutdown signal: {}", err);
            }
            warn!("shutting down... flushing hot groups");
            shutdown_facade.flush_all().await;
            warn!("flush done. bye");
        })
        .await?;

    Ok(())
}

fn env_parse<T>(key: &str, default: T) -> T
where
    T: std::str::FromStr + Copy,
{
    std::env::var(key)
        .ok()
        .and_then(|s| s.parse::<T>().ok())
        .unwrap_or(default)
}
