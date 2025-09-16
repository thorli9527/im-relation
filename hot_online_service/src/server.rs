use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use crate::db::mysql::{ClientRepoSqlx, DirectoryRepoSqlx, SessionRepoSqlx};
use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_arb_client::integration;
use crate::grpc_arb_client::server::start_arb_client_server;
use crate::grpc_hot_online::client_service::client_rpc_service_server::ClientRpcServiceServer;
use crate::grpc_hot_online::client_service_impl::{ClientEntityServiceImpl, DummyIdAlloc};
use crate::grpc_hot_online::online_service::online_service_server::OnlineServiceServer;
use crate::grpc_hot_online::online_service_impl::OnLineServiceImpl;
use crate::hot_cold::{ClientHot, ClientHotConfig, RealNormalizer};
use crate::online_store::OnlineStore;
use actix_web::{web, App, HttpServer};
use anyhow::{anyhow, Context, Result};
use common::config::{get_db, AppConfig};
use log::{info, warn};
use tokio::signal;
use tonic::transport::Server;

pub async fn start() -> Result<()> {
    let cfg = AppConfig::get();
    let grpc_cfg = cfg
        .grpc
        .as_ref()
        .ok_or_else(|| anyhow!("grpc config missing"))?;
    let client_addr = grpc_cfg
        .client_addr
        .as_ref()
        .ok_or_else(|| anyhow!("grpc.client_addr missing"))?;
    let grpc_addr: SocketAddr = client_addr.parse().context("invalid gRPC bind address")?;

    let http_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let http_addr: SocketAddr = format!("{}:{}", http_cfg.host, http_cfg.port)
        .parse()
        .context("invalid http host:port")?;

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

    let grpc_task = {
        let online_svc = online_svc;
        let client_svc = client_svc;
        tokio::spawn(async move {
            Server::builder()
                .add_service(OnlineServiceServer::new(online_svc))
                .add_service(ClientRpcServiceServer::new(client_svc))
                .serve(grpc_addr)
                .await
                .map_err(anyhow::Error::from)
        })
    };

    let st = store.clone();
    tokio::spawn(async move {
        let _ = HttpServer::new(move || {
            App::new()
                .app_data(web::Data::new(crate::rest_online::AppState {
                    store: st.clone(),
                }))
                .configure(crate::rest_online::config)
        })
        .bind(http_addr)
        .expect("http bind error")
        .run()
        .await;
    });

    info!(
        "hot_online_service started. grpc={}, http={}",
        client_addr, http_addr
    );

    start_arb_client_server(client_addr).await?;
    integration::start(NodeType::OnlineNode).await?;

    tokio::select! {
        r = grpc_task => { r??; }
        _ = signal::ctrl_c() => {
            warn!("Ctrl+C received, shutting down...");
        }
    }

    Ok(())
}
