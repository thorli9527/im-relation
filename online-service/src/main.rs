mod online_store;
mod grpc;
mod rest_online;
mod db;

use std::{net::SocketAddr, sync::Arc};
use actix_web::{web, App, HttpServer};
use anyhow::Context;
use log::warn;
use tokio::signal;
use common::config::AppConfig;
use crate::grpc::online_service::online_service_server::OnlineServiceServer;
use crate::grpc::online_service_impl::OnLineServiceImpl;
use crate::online_store::OnlineStore;


#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let app_config=AppConfig::init("./online-config.toml").await;
    // 读取配置（可用环境变量，也可以用配置文件）
    let shard_count = std::env::var("ONLINE_SHARDS")
        .ok()
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(128);

    let grpc_cfg = app_config.grpc.expect("grpc.error");
    let grpc_addr: SocketAddr = format!("{}:{}", grpc_cfg.host, grpc_cfg.port)
        .parse()
        .context("invalid grpc host:port")?;
    warn!("Starting gRPC server on {}", grpc_addr);

    // 初始化全局 OnlineStore
    let store = Arc::new(OnlineStore::new(shard_count));

    // ========== gRPC 服务 ==========
    let grpc_store = store.clone();
    let grpc_server = tokio::spawn(async move {
        let svc = OnLineServiceImpl::new(grpc_store);
        tonic::transport::Server::builder()
            .add_service(OnlineServiceServer::new(svc))
            .serve(grpc_addr)
            .await
            .map_err(anyhow::Error::from)
    });

    // 等待 Ctrl+C 或子任务错误
    tokio::select! {
        res = grpc_server => { res??; }
        _ = signal::ctrl_c() => {
            println!("Ctrl+C received, shutting down...");
        }
    }

    Ok(())
}
