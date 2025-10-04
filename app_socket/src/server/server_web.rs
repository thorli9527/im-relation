//! Web (HTTP/WebSocket) and arbitration sync entrypoints.

use std::net::SocketAddr;

use anyhow::Result;
use axum::{routing::get, Json, Router};
use common::config::AppConfig;
use log::{info, warn};
use serde_json::json;
use tokio::net::TcpListener;

/// Start a lightweight HTTP server exposing `/healthz` for probes.
pub async fn start_web_server(bind: &str) -> Result<()> {
    let addr: SocketAddr = bind.parse()?;
    info!("socket HTTP server listening on {}", addr);

    let listener = TcpListener::bind(addr).await?;
    let router = Router::new().route("/healthz", get(healthz));

    tokio::spawn(async move {
        if let Err(err) = axum::serve(listener, router.into_make_service()).await {
            warn!("socket HTTP server exited: {}", err);
        }
    });

    Ok(())
}

/// 简单健康检查，供负载均衡探测。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}
