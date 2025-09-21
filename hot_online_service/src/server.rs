use std::mem;
use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use common::config::AppConfig;
use log::{info, warn};
use tokio::signal;
use tonic::service::Routes;
use tonic::transport::Server;

use crate::db::mysql::{ClientRepoSqlx, DirectoryRepoSqlx, SessionRepoSqlx};
use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcServiceServer;
use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_arb_client::integration;
use crate::grpc_arb_client::server::ArbClientImpl;
use crate::grpc_hot_online::client_service::client_rpc_service_server::ClientRpcServiceServer;
use crate::grpc_hot_online::client_service_impl::{ClientEntityServiceImpl, DummyIdAlloc};
use crate::grpc_hot_online::online_service::online_service_server::OnlineServiceServer;
use crate::grpc_hot_online::online_service_impl::OnLineServiceImpl;
use crate::hot_cold::{ClientHot, ClientHotConfig, RealNormalizer};
use crate::online_store::OnlineStore;

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

    let shard_count = std::env::var("ONLINE_SHARDS")
        .ok()
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(128);
    let store = Arc::new(OnlineStore::new(shard_count));
    let default_cc = std::env::var("DEFAULT_CC").unwrap_or_else(|_| "86".to_string());
    let normalizer = Arc::new(RealNormalizer::new(default_cc));

    let client_repo = Arc::new(ClientRepoSqlx::new());
    let directory_repo = Arc::new(DirectoryRepoSqlx::new());
    let hot_cfg = ClientHotConfig {
        by_id_max_capacity: std::env::var("HOT_BY_ID_CAP")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(500_000),
        by_id_ttl: Duration::from_secs(
            std::env::var("HOT_BY_ID_TTL")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(300),
        ),
        route_max_capacity: std::env::var("HOT_ROUTE_CAP")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(200_000),
        route_ttl: Duration::from_secs(
            std::env::var("HOT_ROUTE_TTL")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(120),
        ),
    };
    let hot = ClientHot::new(
        client_repo.clone(),
        directory_repo.clone(),
        normalizer.clone(),
        hot_cfg,
    );

    let session_repo = Arc::new(SessionRepoSqlx::new());
    let online_svc = OnLineServiceImpl::new(store.clone(), session_repo.clone());
    let online_touch = {
        let st = store.clone();
        Arc::new(move |id: i64| {
            st.insert(id);
        })
    };
    let client_svc =
        ClientEntityServiceImpl::new(hot, normalizer.clone(), DummyIdAlloc, Some(online_touch));

    let rest_state = crate::rest_online::AppState {
        store: store.clone(),
    };
    let rest_router = crate::rest_online::router(rest_state);

    let mut routes = Routes::new(OnlineServiceServer::new(online_svc))
        .add_service(ClientRpcServiceServer::new(client_svc))
        .add_service(ArbClientRpcServiceServer::new(ArbClientImpl::default()));

    let router_slot = routes.axum_router_mut();
    *router_slot = mem::take(router_slot).fallback_service(rest_router);

    info!(
        "hot_online_service listening on {} (HTTP + gRPC)",
        bind_addr_str
    );

    integration::start(NodeType::OnlineNode).await?;

    Server::builder()
        .accept_http1(true)
        .add_routes(routes)
        .serve_with_shutdown(bind_addr, async {
            if let Err(err) = signal::ctrl_c().await {
                warn!("failed to listen for shutdown signal: {}", err);
            }
            warn!("Ctrl+C received, shutting down...");
        })
        .await
        .map_err(anyhow::Error::from)?;

    Ok(())
}
