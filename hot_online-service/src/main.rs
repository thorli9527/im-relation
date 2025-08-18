// hot_online-service/src/main.rs

mod online_store;
mod grpc;
mod rest_online;
pub mod db;
mod hot_cold;

use std::{net::SocketAddr, sync::Arc};

use actix_web::{web, App, HttpResponse, HttpServer};
use anyhow::Context;
use log::{info, warn};
use tokio::signal;

use common::config::{get_db, AppConfig};

use crate::db::mysql::{ClientRepoSqlx, DirectoryRepoSqlx};
use crate::grpc::online_service::online_service_server::OnlineServiceServer;
use crate::grpc::online_service_impl::OnLineServiceImpl;

use crate::grpc::client_service::client_entity_service_server::ClientEntityServiceServer;
use crate::grpc::client_service_impl::{ClientEntityServiceImpl, DummyIdAlloc};
use crate::hot_cold::{ClientHot, ClientHotConfig, RealNormalizer};
use crate::online_store::OnlineStore;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 1) 加载配置 & 初始化（内含 DB、日志等）
    let app_cfg = AppConfig::init("./online-config.toml").await;

    // 2) 读取 gRPC/HTTP 监听地址
    let grpc_cfg = app_cfg.grpc.clone().expect("grpc config missing");
    let grpc_addr: SocketAddr = format!("{}:{}", grpc_cfg.host, grpc_cfg.port)
        .parse()
        .context("invalid grpc host:port")?;
    warn!("Starting gRPC server on {}", grpc_addr);

    let http_cfg = app_cfg.server.clone().unwrap_or_default();
    let http_addr: SocketAddr = format!("{}:{}", http_cfg.host, http_cfg.port)
        .parse()
        .context("invalid http host:port")?;
    warn!("Starting HTTP server on {}", http_addr);

    // 3) OnlineStore：分片数（建议 2 的幂）
    let shard_count = std::env::var("ONLINE_SHARDS")
        .ok()
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(128);
    let store = Arc::new(OnlineStore::new(shard_count));

    // 4) 构造 Normalizer（默认国家码，可用环境变量 DEFAULT_CC 覆盖）
    let default_cc = std::env::var("DEFAULT_CC").unwrap_or_else(|_| "86".to_string());
    let normalizer = Arc::new(RealNormalizer::new(default_cc));

    // 5) 基于 get_db() 的单池读仓库（主表 + 目录）
    let pool = get_db().as_ref().clone();
    let client_repo = Arc::new(ClientRepoSqlx::new());
    let directory_repo = Arc::new(DirectoryRepoSqlx::new());

    // 6) Hot 层
    let hot_cfg = ClientHotConfig {
        by_id_max_capacity: std::env::var("HOT_BY_ID_CAP").ok().and_then(|s| s.parse().ok()).unwrap_or(500_000),
        by_id_ttl:          std::time::Duration::from_secs(std::env::var("HOT_BY_ID_TTL").ok().and_then(|s| s.parse().ok()).unwrap_or(300)),
        route_max_capacity: std::env::var("HOT_ROUTE_CAP").ok().and_then(|s| s.parse().ok()).unwrap_or(200_000),
        route_ttl:          std::time::Duration::from_secs(std::env::var("HOT_ROUTE_TTL").ok().and_then(|s| s.parse().ok()).unwrap_or(120)),
    };
    let hot = ClientHot::new(
        client_repo.clone(),
        directory_repo.clone(),
        normalizer.clone(),
        hot_cfg,
    );

    // 7) gRPC 服务实例
    let online_svc = OnLineServiceImpl::new(store.clone());

    // “取热前触摸续命”的回调（如果 OnlineStore 没有 touch，可改为 insert）
    let online_touch = {
        let st = store.clone();
        Arc::new(move |id: i64| {
            st.insert(id); // <-- 如果没有 touch，用 st.insert(id as u64) 也可
        })
    };

    let client_svc = ClientEntityServiceImpl::new(
        hot,
        normalizer.clone(),
        DummyIdAlloc,
        Some(online_touch),
    );

    // 8) gRPC Server 任务
    let grpc_task = {
        let online_svc = online_svc;
        let client_svc = client_svc;
        tokio::spawn(async move {
            tonic::transport::Server::builder()
                .add_service(OnlineServiceServer::new(online_svc))
                .add_service(ClientEntityServiceServer::new(client_svc))
                .serve(grpc_addr)
                .await
                .map_err(anyhow::Error::from)
        })
    };


    info!("hot_online-service started. grpc={}, http={}", grpc_addr, http_addr);

    // 9) 等待 Ctrl+C 或子任务结束
    tokio::select! {
        r = grpc_task => { r??; }
        _ = signal::ctrl_c() => {
            warn!("Ctrl+C received, shutting down...");
        }
    }

    Ok(())
}
