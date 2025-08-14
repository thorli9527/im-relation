mod online_store;
mod grpc;
mod rest_online;

use std::{net::SocketAddr, sync::Arc};
use actix_web::{web, App, HttpServer};
use tokio::signal;
use crate::grpc::online_service::online_service_server::OnlineServiceServer;
use crate::grpc::online_service_impl::OnLineServiceImpl;
use crate::online_store::OnlineStore;


#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 读取配置（可用环境变量，也可以用配置文件）
    let shard_count = std::env::var("ONLINE_SHARDS")
        .ok()
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(128);

    let grpc_addr: SocketAddr = std::env::var("GRPC_ADDR")
        .unwrap_or_else(|_| "0.0.0.0:50051".into())
        .parse()?;
    let http_addr = std::env::var("HTTP_ADDR")
        .unwrap_or_else(|_| "0.0.0.0:8080".into());

    // 初始化全局 OnlineStore
    let store = Arc::new(OnlineStore::new(shard_count));

    // ========== gRPC 服务 ==========
    let grpc_store = store.clone();
    let grpc_server = tokio::spawn(async move {
        let svc = OnLineServiceImpl::new(grpc_store);
        println!("[gRPC] Listening on {}", grpc_addr);
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
