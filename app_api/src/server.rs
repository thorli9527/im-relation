use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcServiceServer;
use crate::grpc_arb_client::integration;
use crate::grpc_arb_client::server::ArbClientServiceImpl;
use crate::handler;
use crate::service;
use actix_web::middleware::Logger;
use actix_web::{App, HttpServer};
use anyhow::{anyhow, Context, Result};
use common::config::AppConfig;
use log::warn;
use tonic::transport::Server;

pub async fn start() -> Result<()> {
    service::init().await;
    integration::start(crate::grpc_arb::arb_server::NodeType::ApiNode).await?;

    let app_cfg = AppConfig::get();
    let server_cfg = app_cfg
        .server
        .clone()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let address_and_port = format!("{}:{}", server_cfg.host, server_cfg.port);
    warn!("Starting server on {}", address_and_port);

    let grpc_cfg = app_cfg
        .grpc
        .clone()
        .ok_or_else(|| anyhow!("grpc config missing"))?;
    let client_addr = grpc_cfg
        .client_addr
        .clone()
        .ok_or_else(|| anyhow!("grpc.client_addr missing"))?;
    let grpc_addr = client_addr.parse()?;
    warn!("Starting gRPC server on {}", grpc_addr);

    let arb_client_service = ArbClientServiceImpl {};
    tokio::spawn(async move {
        if let Err(e) = Server::builder()
            .add_service(ArbClientRpcServiceServer::new(arb_client_service))
            .serve(grpc_addr)
            .await
        {
            warn!("gRPC server error: {}", e);
        }
    });

    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .configure(handler::configure)
    })
    .keep_alive(actix_web::http::KeepAlive::Timeout(
        std::time::Duration::from_secs(60),
    ))
    .bind(address_and_port)?
    .run()
    .await?;

    Ok(())
}
