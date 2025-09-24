use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::NodeType;
use common::config::{get_db, AppConfig};
use common::grpc::grpc_hot_group::group_service::group_service_server::GroupServiceServer;
use common::service::arb_client;
use log::{info, warn};
use tokio::signal;
use tokio_util::sync::CancellationToken;
use tonic::service::Routes;

use crate::hot_cold::{HotColdConfig, HotColdFacade};
use crate::member::shard_map::ShardMap;
use crate::profile::{GroupProfileCache, MySqlGroupProfileStore};
use crate::service::group_service_impl::GroupServiceImpl;
use crate::store::mysql::MySqlStore;

mod server_grpc;
mod server_web;

pub async fn start() -> Result<()> {
    let cfg = AppConfig::get();
    let server_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;

    let grpc_addr_str = server_cfg
        .require_grpc_addr()
        .context("server.grpc missing host/port")?;
    let http_addr_str = server_cfg
        .require_http_addr()
        .context("server.http missing host/port")?;

    let grpc_addr: SocketAddr = grpc_addr_str
        .parse()
        .with_context(|| format!("invalid grpc host:port: {}", grpc_addr_str))?;
    let http_addr: SocketAddr = http_addr_str
        .parse()
        .with_context(|| format!("invalid http host:port: {}", http_addr_str))?;

    let advertise_addr = std::env::var("GROUP_GRPC_ADDR")
        .ok()
        .filter(|addr| !addr.is_empty())
        .unwrap_or_else(|| grpc_addr_str.clone());

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

    info!(
        "hot cache decided: cap={}, tti={}s, shard_count={}, per_group_shard={}, {}",
        hot_capacity, hot_tti_secs, shard_count, per_group_shard, debug_line
    );

    let http_router = Router::new()
        .route("/healthz", get(healthz))
        .merge(arb_client::http_router());

    let grpc_service =
        GroupServiceServer::new(GroupServiceImpl::new(facade.clone(), profile_cache.clone()));
    let routes = Routes::new(grpc_service);

    arb_client::register_node(NodeType::GroupNode, advertise_addr.clone(), None).await?;

    let cancel_token = CancellationToken::new();
    let http_cancel = cancel_token.clone();
    let grpc_cancel = cancel_token.clone();
    let shutdown_facade = facade.clone();

    let mut http_future = Box::pin(server_web::serve(http_addr, http_router, async move {
        http_cancel.cancelled().await;
    }));

    let mut grpc_future = Box::pin(server_grpc::serve(grpc_addr, routes, async move {
        grpc_cancel.cancelled().await;
        warn!("shutting down... flushing hot groups");
        shutdown_facade.flush_all().await;
        warn!("flush done. bye");
    }));

    tokio::select! {
        res = &mut http_future => {
            res.with_context(|| "http server exited unexpectedly")?;
            cancel_token.cancel();
        }
        res = &mut grpc_future => {
            res.with_context(|| "grpc server exited unexpectedly")?;
            cancel_token.cancel();
        }
        _ = signal::ctrl_c() => {
            warn!("Ctrl+C received, shutting down...");
            cancel_token.cancel();
        }
    }

    http_future
        .await
        .with_context(|| "http server shutdown failed")?;
    grpc_future
        .await
        .with_context(|| "grpc server shutdown failed")?;

    Ok(())
}

async fn healthz() -> Json<serde_json::Value> {
    Json(serde_json::json!({"ok": true}))
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
