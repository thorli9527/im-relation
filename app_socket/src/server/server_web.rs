//! Web (HTTP/WebSocket) and arbitration sync entrypoints.

use std::net::SocketAddr;

use anyhow::Result;
use axum::{routing::get, Json, Router};
use common::arb::NodeType;
use common::config::AppConfig;
use common::service::arb_client;
use log::{info, warn};
use serde_json::json;
use tokio::net::TcpListener;

/// Start the lightweight HTTP server that exposes `/arb/server/sync`.
///
/// Spawns a dedicated Axum server using `common::service::arb_client::http_router()` so
/// arbitration updates land in the shared cache. Additional HTTP/WebSocket routes can be layered
/// here later on.
pub async fn start_web_server(bind: &str) -> Result<()> {
    let addr: SocketAddr = bind.parse()?;
    info!("arb sync HTTP server listening on {}", addr);

    let listener = TcpListener::bind(addr).await?;
    let router = Router::new()
        .route("/healthz", get(healthz))
        .merge(arb_client::http_router());

    tokio::spawn(async move {
        if let Err(err) = axum::serve(listener, router.into_make_service()).await {
            warn!("arb sync HTTP server exited: {}", err);
        }
    });

    Ok(())
}

/// Register current socket node with `arb_service`, advertising both HTTP sync and TCP addresses.
pub async fn register_with_arb(http_addr: &str, tcp_addr: &str) -> Result<()> {
    let cfg = AppConfig::get();
    if cfg.arb_server_addr().is_none() {
        warn!("arb server addr missing; skip arb registration");
        return Ok(());
    }

    let socket_cfg = cfg.get_socket();
    let kafka_addr = socket_cfg.kafka_broker.clone().or_else(|| {
        warn!("socket.kafka_broker not configured; falling back to TCP advertise address");
        Some(tcp_addr.to_string())
    });

    arb_client::register_node(NodeType::SocketNode, http_addr.to_string(), kafka_addr).await?;
    Ok(())
}

/// 简单健康检查，供负载均衡探测。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}
