use crate::handler;
use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::NodeType;
use common::config::AppConfig;
use common::service::arb_client;
use log::warn;
use serde_json::json;
use tokio::net::TcpListener;
use tower_http::trace::TraceLayer;

pub async fn start() -> Result<()> {
    let app_cfg = AppConfig::get();
    let server_cfg = app_cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let address_and_port = server_cfg
        .require_http_addr()
        .context("server.http missing host/port")?;
    warn!("Starting server on {}", address_and_port);

    app_cfg
        .arb_server_addr()
        .context("arb server addr missing (set [arb].server_addr or [server.http])")?;

    let router: Router = handler::router()
        .route("/healthz", get(healthz))
        .merge(arb_client::http_router())
        .layer(TraceLayer::new_for_http());
    let listener = TcpListener::bind(&address_and_port).await?;

    arb_client::register_node(NodeType::ApiNode, address_and_port.clone(), None, None).await?;
    axum::serve(listener, router.into_make_service()).await?;

    Ok(())
}

/// 简单健康检查，供负载均衡探测。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}
