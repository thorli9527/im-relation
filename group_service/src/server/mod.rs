use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::config::{get_db, AppConfig};
use common::infra::grpc::grpc_group::group_service::group_service_server::GroupServiceServer;
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

    let tuning = cfg.hot_group_cfg();

    let hot_mem_model = crate::hot_capacity::HotMemModel {
        bytes_per_member: tuning.hot_bytes_per_member.unwrap_or(128),
        bytes_per_group_overhead: tuning.hot_bytes_per_group.unwrap_or(64),
        avg_members_per_group: tuning.hot_avg_members.unwrap_or(32),
        mem_utilization: tuning.hot_mem_util.unwrap_or(0.5_f64),
    };
    let (hot_capacity, debug_line) = crate::hot_capacity::auto_hot_groups_capacity(
        hot_mem_model,
        tuning.hot_cap_max.unwrap_or(1_000_000),
        tuning.hot_cap_min.unwrap_or(1_000),
    );
    let hot_tti_secs = tuning.hot_tti_secs.unwrap_or(300);
    let shard_count = tuning.shard_count.unwrap_or(1024);
    let per_group_shard = tuning.per_group_shard.unwrap_or(1);
    let page_cache_cap = tuning.page_cache_cap.unwrap_or(100_000);
    let page_cache_tti_secs = tuning.page_cache_tti_secs.unwrap_or(300);
    let persist_debounce_ms = tuning.persist_debounce_ms.unwrap_or(200);
    let profile_l1_cap = tuning.profile_l1_cap.unwrap_or(1_000_000);
    let profile_l1_tti_secs = tuning.profile_l1_tti_secs.unwrap_or(600);

    let map = Arc::new(ShardMap::new(
        shard_count,
        per_group_shard,
        page_cache_cap,
        Some(Duration::from_secs(page_cache_tti_secs)),
    ));
    let _pool = get_db();
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

    let http_router = Router::new().route("/healthz", get(healthz));

    let grpc_service =
        GroupServiceServer::new(GroupServiceImpl::new(facade.clone(), profile_cache.clone()));
    let routes = Routes::new(grpc_service);

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
