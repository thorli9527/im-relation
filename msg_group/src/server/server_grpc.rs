use std::mem;
use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::config::{get_db, AppConfig, MySqlPool};
use log::{info, warn};
use serde_json::json;
use tokio::signal;
use tonic::service::Routes;
use tonic::transport::Server as TonicServer;

use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcServiceServer;
use crate::grpc_arb_client::server::ArbClientImpl;
use crate::grpc_msg_group::msg_group_service::group_biz_service_server::GroupBizServiceServer;
use crate::grpc_msg_group::msg_group_service::group_msg_service_server::GroupMsgServiceServer;
use crate::service::{GroupBizServiceImpl, GroupMsgServiceImpl};

#[derive(Clone)]
pub struct Services {
    pool: Arc<MySqlPool>,
}

impl Services {
    pub fn new(pool: Arc<MySqlPool>) -> Self {
        Self { pool }
    }

    pub fn pool(&self) -> &MySqlPool {
        self.pool.as_ref()
    }
}

async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}

pub async fn run_server() -> Result<()> {
    let cfg = AppConfig::get();
    let server_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let bind_addr_str = format!("{}:{}", server_cfg.host, server_cfg.port);
    let bind_addr: SocketAddr = bind_addr_str
        .parse()
        .with_context(|| format!("invalid server bind address: {}", bind_addr_str))?;

    if let Some(grpc_cfg) = cfg.grpc.as_ref() {
        if let Some(addr) = grpc_cfg.client_addr.as_ref() {
            if addr != &bind_addr_str {
                warn!(
                    "grpc.client_addr ({}) != server bind address ({}); using HTTP port for binding",
                    addr, bind_addr_str
                );
            }
        } else {
            info!(
                "grpc.client_addr missing; defaulting to HTTP port {} for registration",
                bind_addr_str
            );
        }
    }

    let pool = get_db();
    let services = Arc::new(Services::new(pool));

    let rest_router = Router::new().route("/healthz", get(healthz));

    let biz_service = GroupBizServiceImpl::new(services.clone());
    let msg_service = GroupMsgServiceImpl::new(services.clone());

    let mut routes = Routes::new(GroupBizServiceServer::new(biz_service))
        .add_service(GroupMsgServiceServer::new(msg_service))
        .add_service(ArbClientRpcServiceServer::new(ArbClientImpl::default()));

    let router_slot = routes.axum_router_mut();
    *router_slot = mem::take(router_slot).fallback_service(rest_router);

    info!("msg_group listening on {} (HTTP + gRPC)", bind_addr_str);

    TonicServer::builder()
        .accept_http1(true)
        .add_routes(routes)
        .serve_with_shutdown(bind_addr, async {
            if let Err(err) = signal::ctrl_c().await {
                warn!("failed to listen for shutdown signal: {}", err);
            }
            warn!("Ctrl+C received, shutting down...");
        })
        .await
        .map_err(anyhow::Error::from)
}
