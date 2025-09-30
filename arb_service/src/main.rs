//! arb_service entrypoint.
//!
//! Sets up configuration, constructs the arbitration core (`ArbService`), and exposes its HTTP
//! surface so other subsystems can register/heartbeat/query node topology.

mod handler;
mod server_web;
mod service;

use anyhow::{Context, Result};
use common::config::AppConfig;
use log::warn;
use service::arb_service::ArbService;
use std::net::SocketAddr;
use tokio::net::TcpListener;

/// 仲裁服务的入口，加载配置并启动 HTTP 接入层。
#[tokio::main(flavor = "multi_thread")]
async fn main() -> Result<()> {
    // 预先从配置文件与环境变量加载应用配置。
    AppConfig::init_from_env("./config-arb.toml").await;

    // cfg 为全局配置快照，grpc_cfg 提供仲裁服务监听参数。
    let cfg = AppConfig::get();
    let server_cfg = cfg.server.as_ref().context("server config missing")?;
    let bind_addr = server_cfg
        .require_http_addr()
        .context("server.http missing host/port")?;
    let addr: SocketAddr = bind_addr.parse().context("invalid arb server address")?;

    // service 注入访问令牌，用于下游 HTTP 同步认证。
    let service = ArbService::new(cfg.arb().and_then(|c| c.access_token.clone()));
    // router 构造所有仲裁相关路由，并带入服务上下文。
    let router = server_web::router(service);

    warn!("arb server listening on {}", addr);
    // listener 绑定端口后，交由 axum::serve 处理请求生命周期。
    let listener = TcpListener::bind(addr).await.context("bind arb server")?;
    axum::serve(listener, router.into_make_service())
        .await
        .context("arb http server failed")?;
    Ok(())
}
