//! app_socket 入口
//! - 加载配置（`APP_CONFIG` 可覆盖默认 `config-socket.toml`）
//! - 初始化会话管理策略（多端登录 + 容量限制）
//! - 启动 TCP（长度前缀 + JSON）与 Kafka→分片→会话分发流水线
//!
//! 说明：
//! - 这里仅负责基础设施启动；WebSocket 连接建立/读写建议在 web 层调用
//!   `SessionManager::register/on_client_msg/unregister` 三个方法进行集成。

mod server;
pub mod service;
pub mod util; // new unified server module

use common::config::AppConfig;
use service::{start_socket_pipeline, MultiLoginPolicy, SessionManager, SessionPolicy};
use std::env;
use tokio::signal;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 加载配置（支持 APP_CONFIG 环境变量覆盖配置文件路径）
    let _cfg = AppConfig::init_from_env("./config-socket.toml").await;
    // 初始化会话管理策略：默认“每设备类型单端 + 最大 5 会话/用户”
    let policy = SessionPolicy {
        multi_login: MultiLoginPolicy::SinglePerDeviceType,
        max_sessions_per_user: 5,
    };
    let _sm = SessionManager::init(policy);

    let cfg = AppConfig::get();
    let server_cfg = cfg.get_server();
    let socket_cfg = cfg.get_socket();

    let tcp_host = server_cfg.host.clone();
    let tcp_port = server_cfg.port;
    let tcp_bind = format!("{}:{}", tcp_host, tcp_port);

    let http_host = socket_cfg
        .http_host
        .clone()
        .unwrap_or_else(|| tcp_host.clone());
    let default_http_port = tcp_port.saturating_add(100);
    let http_port = socket_cfg.http_port.unwrap_or(default_http_port);
    let http_bind = format!("{}:{}", http_host, http_port);

    // HTTP server handles arb sync callbacks and optional future Web/WebSocket endpoints.
    server::server_web::start_web_server(&http_bind).await?;

    // 启动 TCP 监听（长度前缀 JSON 协议，端口来自配置文件）
    server::start_tcp_server().await?;

    let advertise_http = env::var("SOCKET_HTTP_ADDR").unwrap_or_else(|_| http_bind.clone());
    let advertise_tcp = env::var("SOCKET_TCP_ADDR").unwrap_or_else(|_| tcp_bind.clone());
    server::server_arb::register_with_arb(&advertise_http, &advertise_tcp).await?;

    // 启动消费/分发流水线：Kafka → mpsc 分片 → SessionManager
    start_socket_pipeline().await?;

    // 等待 Ctrl-C 以优雅退出
    let _ = signal::ctrl_c().await;
    log::info!("app_socket: received Ctrl-C, shutting down");
    Ok(())
}
