use crate::handler;
use crate::service;
use anyhow::{anyhow, Result};
use axum::Router;
use common::config::AppConfig;
use common::service::arb_client;
use log::warn;
use tokio::net::TcpListener;
use tower_http::trace::TraceLayer;

pub async fn start() -> Result<()> {
    service::init().await;

    let app_cfg = AppConfig::get();
    let server_cfg = app_cfg
        .server
        .clone()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let address_and_port = format!("{}:{}", server_cfg.host, server_cfg.port);
    warn!("Starting server on {}", address_and_port);

    app_cfg.arb().ok_or_else(|| anyhow!("arb config missing"))?;
    let client_addr = format!("{}:{}", server_cfg.host, server_cfg.port);
    warn!("Starting arb HTTP sync endpoint on {}", client_addr);
    arb_client::start_arb_client_server(&client_addr).await?;

    let router: Router = handler::router().layer(TraceLayer::new_for_http());
    let listener = TcpListener::bind(&address_and_port).await?;
    axum::serve(listener, router.into_make_service()).await?;

    Ok(())
}
