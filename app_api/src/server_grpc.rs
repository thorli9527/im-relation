use std::net::SocketAddr;

use anyhow::{anyhow, Context, Result};
use common::config::AppConfig;
use tonic::transport::Server;

use crate::grpc::api::api_service_server::ApiServiceServer;
use crate::service::api_grpc_service::ApiGrpcService;

pub async fn start() -> Result<()> {
    let app_cfg = AppConfig::get();
    let server_cfg = app_cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;

    let addr: SocketAddr = server_cfg
        .require_grpc_addr()
        .context("server.grpc missing host/port")?
        .parse()
        .context("invalid grpc listen address")?;

    Server::builder()
        .add_service(ApiServiceServer::new(ApiGrpcService::default()))
        .serve(addr)
        .await?;

    Ok(())
}
