//! Lightweight HTTP entrypoints (e.g. health probes).

use std::net::SocketAddr;

use anyhow::Result;
use axum::{routing::get, Json, Router};
use log::warn;
use serde_json::json;
use tokio::net::TcpListener;

/// Start a lightweight HTTP server exposing `/healthz` for probes.
pub async fn start_web_server(bind: &str) -> Result<()> {
    let addr: SocketAddr = bind.parse()?;
    warn!("HTTP server (app_socket) listening on {}", addr);

    let listener = TcpListener::bind(addr).await?;
    let router = Router::new().route("/healthz", get(healthz));

    tokio::spawn(async move {
        if let Err(err) = axum::serve(
            listener,
            router.into_make_service_with_connect_info::<SocketAddr>(),
        )
        .await
        {
            warn!("socket HTTP server exited: {}", err);
        }
    });

    Ok(())
}

/// 简单健康检查，供负载均衡探测。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}
