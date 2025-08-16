// online-service/src/main.rs

mod online_store;
mod grpc;
pub mod db;
mod hot_cold;

use std::{net::SocketAddr, sync::Arc};

use actix_web::{web, App, HttpResponse, HttpServer};
use anyhow::Context;
use log::info;
use tokio::signal;

use common::config::AppConfig;

use crate::db::mysql::{ClientRepoSqlx, DirectoryRepoSqlx};
use crate::grpc::client_service::client_entity_service_server::ClientEntityServiceServer;
use crate::grpc::online_service::online_service_server::OnlineServiceServer;
use crate::grpc::online_service_impl::OnLineServiceImpl;

use crate::grpc::client_service_impl::{ClientEntityServiceImpl, DummyIdAlloc};
use crate::hot_cold::{ClientHot, ClientHotConfig, RealNormalizer};
use crate::online_store::OnlineStore;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 1) 初始化配置（内部会初始化全局 DB：get_db()）
    let app_cfg = AppConfig::init("./online-config.toml").await;

    // 2) 基础参数
    let shard_count = std::env::var("ONLINE_SHARDS")
        .ok()
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(128);

    let grpc_cfg = app_cfg.grpc.clone().context("grpc config missing")?;
    let grpc_addr: SocketAddr = format!("{}:{}", grpc_cfg.host, grpc_cfg.port)
        .parse()
        .context("invalid grpc host:port")?;

    let http_cfg = app_cfg.server.clone().context("http server config missing")?;
    let http_addr: SocketAddr = format!("{}:{}", http_cfg.host, http_cfg.port)
        .parse()
        .context("invalid http host:port")?;

    info!("Starting gRPC on {}, HTTP on {}", grpc_addr, http_addr);

    // 3) 组件实例化
    // 3.1 在线用户存储（分片 RoaringBitmap）
    let online_store = Arc::new(OnlineStore::new(shard_count));

    // 3.2 读仓库（具体类型；避免 dyn 导致的 object-safety 报错）
    let client_repo = Arc::new(ClientRepoSqlx::new());
    let directory_repo = Arc::new(DirectoryRepoSqlx::new());

    // 3.3 Normalizer（默认国家码可用环境变量覆盖）
    let default_cc = std::env::var("DEFAULT_CC").unwrap_or_else(|_| "86".to_string());
    let normalizer = Arc::new(RealNormalizer::new(default_cc));

    // 3.4 热层（具体类型参数）
    let hot_cfg = ClientHotConfig::default();
    let hot = ClientHot::new(
        client_repo.clone(),
        directory_repo.clone(),
        normalizer.clone(),
        hot_cfg,
    );

    // 3.5 “读前触摸续命”闭包：在 ClientEntityServiceImpl 中统一调用
    let touch = {
        let store = online_store.clone();
        Arc::new(move |id: i64| {
            // common::UserId 通常为 u64；按你的定义转换
            store.insert(id as common::UserId);
        })
    };

    // 3.6 gRPC 服务实例
    let online_svc = OnLineServiceImpl::new(online_store.clone());
    let client_svc = ClientEntityServiceImpl::new(
        hot,
        normalizer,
        DummyIdAlloc,
        Some(touch), // 取热前“触摸续命”
    );

    // 4) gRPC 服务器
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

    // 6) 优雅退出
    tokio::select! {
        res = grpc_task => { res??; }
        _ = signal::ctrl_c() => {
            info!("Ctrl+C received, shutting down...");
        }
    }

    Ok(())
}
