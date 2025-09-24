use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::NodeType;
use common::config::{get_db, AppConfig};
use common::service::arb_client;
use common::UserId;
use log::warn;
use tokio::signal;
use tokio_util::sync::CancellationToken;

use crate::hot_cold::HotColdFriendFacade;
use crate::service::friend_service_impl::FriendServiceImpl;
use crate::store::mysql::FriendStorage;

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

    let advertise_addr = std::env::var("FRIEND_GRPC_ADDR")
        .ok()
        .filter(|addr| !addr.is_empty())
        .unwrap_or_else(|| grpc_addr_str.clone());

    let avg_key_bytes = std::mem::size_of::<UserId>();
    let avg_value_bytes = env_parse("AVG_VALUE_BYTES", 256usize);
    let shards = env_parse("SHARDS", 32usize);
    let reserve_ratio = env_parse("AUTOTUNE_RESERVE_RATIO", 0.40_f64);
    let max_use_ratio = env_parse("AUTOTUNE_MAX_USE_RATIO", 0.25_f64);
    let overhead_factor = env_parse("AUTOTUNE_OVERHEAD_FACTOR", 1.6_f64);
    let hot_ratio = env_parse("AUTOTUNE_HOT_RATIO", 0.20_f64);
    let tti_secs = env_parse("AUTOTUNE_TTI_SECS", 60u64);
    let refresh_secs = env_parse("AUTOTUNE_REFRESH_SECS", 0u64);

    let mut tune_cfg = crate::autotune::AutoTuneConfig::default();
    tune_cfg.shards = shards.max(1);
    tune_cfg.avg_key_bytes = avg_key_bytes;
    tune_cfg.avg_value_bytes = avg_value_bytes;
    tune_cfg.reserve_ratio = reserve_ratio;
    tune_cfg.max_use_ratio = max_use_ratio;
    tune_cfg.overhead_factor = overhead_factor;
    tune_cfg.hot_ratio = hot_ratio;
    tune_cfg.default_tti = Duration::from_secs(tti_secs);

    let plan: crate::autotune::CacheAutoTune = crate::autotune::auto_tune_cache(&tune_cfg);

    let pool = get_db();

    let storage = Arc::new(FriendStorage::from_pool(pool.clone()));
    let facade = Arc::new(HotColdFriendFacade::new(
        storage.clone(),
        plan.clone(),
        tokio::runtime::Handle::current(),
    ));

    if refresh_secs > 0 {
        let facade_clone = facade.clone();
        tokio::spawn(async move {
            let interval = Duration::from_secs(refresh_secs);
            loop {
                tokio::time::sleep(interval).await;
                facade_clone.refresh_by_autotune(
                    avg_key_bytes,
                    avg_value_bytes,
                    reserve_ratio,
                    max_use_ratio,
                    overhead_factor,
                    hot_ratio,
                    Duration::from_secs(tti_secs),
                );
            }
        });
    }

    let http_router = Router::new()
        .route("/healthz", get(healthz))
        .merge(arb_client::http_router());

    let grpc_service = FriendServiceImpl::<FriendStorage> {
        facade: facade.clone(),
    };

    arb_client::register_node(NodeType::FriendNode, advertise_addr.clone(), None).await?;

    let cancel_token = CancellationToken::new();
    let http_cancel = cancel_token.clone();
    let grpc_cancel = cancel_token.clone();

    let mut http_future = Box::pin(server_web::serve(http_addr, http_router, async move {
        http_cancel.cancelled().await;
    }));

    let mut grpc_future = Box::pin(server_grpc::serve(grpc_addr, grpc_service, async move {
        grpc_cancel.cancelled().await;
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
