mod grpc_arb;
mod service;

use anyhow::{Context, Result};
use common::config::AppConfig;
use grpc_arb::arb_server::arb_server_rpc_service_server::ArbServerRpcServiceServer;
use service::arb_server_rpc_service::ArbServerRpcServiceImpl;
use std::net::SocketAddr;
use tonic::transport::Server;

#[tokio::main(flavor = "multi_thread")]
async fn main() -> Result<()> {
    AppConfig::init_from_env("./config-arb.toml").await;

    let cfg = AppConfig::get();
    let grpc_cfg = cfg.grpc.as_ref().context("grpc config missing")?;
    let server_addr = grpc_cfg
        .server_addr
        .as_ref()
        .context("grpc.server_addr missing")?;
    let addr: SocketAddr = server_addr.parse().context("invalid gRPC server address")?;

    let svc = ArbServerRpcServiceImpl::new();

    Server::builder()
        .add_service(ArbServerRpcServiceServer::new(svc))
        .serve(addr)
        .await
        .context("gRPC server failed")?;

    Ok(())
}
