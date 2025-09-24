use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use axum::Router;
use common::arb::NodeType;
use common::config::AppConfig;
use common::service::arb_client;
use log::{info, warn};
use tokio::signal;
use tokio_util::sync::CancellationToken;
use tonic::service::Routes;

use crate::db::mysql::{ClientRepoSqlx, DirectoryRepoSqlx, SessionRepoSqlx};
use crate::grpc_hot_online::client_service_impl::{ClientEntityServiceImpl, DummyIdAlloc};
use crate::grpc_hot_online::online_service::client_rpc_service_server::ClientRpcServiceServer;
use crate::grpc_hot_online::online_service::online_service_server::OnlineServiceServer;
use crate::hot_cold::{ClientHot, ClientHotConfig, RealNormalizer};
use crate::online_store::OnlineStore;
use crate::rest_online;
use crate::service::online_service_impl::OnLineServiceImpl;

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

    let advertise_addr = std::env::var("ONLINE_GRPC_ADDR")
        .ok()
        .filter(|addr| !addr.is_empty())
        .unwrap_or_else(|| grpc_addr_str.clone());

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

    let rest_state = rest_online::AppState {
        store: store.clone(),
    };
    let rest_router = rest_online::router(rest_state);
    let http_router: Router = rest_router.merge(arb_client::http_router());

    let routes = Routes::new(OnlineServiceServer::new(online_svc))
        .add_service(ClientRpcServiceServer::new(client_svc));

    info!(
        "hot_online_service listening on grpc={} http={}",
        grpc_addr_str, http_addr_str
    );

    arb_client::register_node(NodeType::OnlineNode, advertise_addr.clone(), None).await?;

    let cancel_token = CancellationToken::new();
    let http_cancel = cancel_token.clone();
    let grpc_cancel = cancel_token.clone();

    let mut http_future = Box::pin(server_web::serve(http_addr, http_router, async move {
        http_cancel.cancelled().await;
    }));

    let mut grpc_future = Box::pin(server_grpc::serve(grpc_addr, routes, async move {
        grpc_cancel.cancelled().await;
        warn!("Ctrl+C received, shutting down...");
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
