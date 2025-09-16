//! app_socket 入口
//! - 加载配置（`APP_CONFIG` 可覆盖默认 `config-socket.toml`）
//! - 初始化会话管理策略（多端登录 + 容量限制）
//! - 启动 TCP（长度前缀 + JSON）与 Kafka→分片→会话分发流水线
//!
//! 说明：
//! - 这里仅负责基础设施启动；WebSocket 连接建立/读写建议在 web 层调用
//!   `SessionManager::register/on_client_msg/unregister` 三个方法进行集成。

// 旧 grpc 模块已移除，改用分类模块
mod grpc_arb;
mod grpc_arb_client;
mod grpc_hot_friend;
mod grpc_hot_online;
mod grpc_msg_friend;
mod grpc_msg_group;
pub mod proto;
mod server;
pub mod service;
pub mod util; // new unified server module
use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_arb_client::integration;
use crate::grpc_arb_client::server::start_arb_client_server;

use common::config::AppConfig;
use service::{start_socket_pipeline, MultiLoginPolicy, SessionManager, SessionPolicy};
use tokio::signal;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 加载配置（支持 APP_CONFIG 环境变量覆盖配置文件路径）
    let _cfg = AppConfig::init_from_env("./config-socket.toml").await;
    let cfg = AppConfig::get();
    // 初始化会话管理策略：默认“每设备类型单端 + 最大 5 会话/用户”
    let policy = SessionPolicy {
        multi_login: MultiLoginPolicy::SinglePerDeviceType,
        max_sessions_per_user: 5,
    };
    let _sm = SessionManager::init(policy);

    let grpc_cfg = cfg
        .grpc
        .as_ref()
        .ok_or_else(|| anyhow::anyhow!("grpc config missing"))?;
    let client_addr = grpc_cfg
        .client_addr
        .as_ref()
        .ok_or_else(|| anyhow::anyhow!("grpc.client_addr missing"))?;

    start_arb_client_server(client_addr).await?;
    integration::start(NodeType::SocketNode).await?;

    // 启动 TCP 监听（长度前缀 JSON 协议，端口来自配置文件）
    server::start_tcp_server().await?;

    // 启动消费/分发流水线：Kafka → mpsc 分片 → SessionManager
    start_socket_pipeline().await?;

    // 等待 Ctrl-C 以优雅退出
    let _ = signal::ctrl_c().await;
    log::info!("app_socket: received Ctrl-C, shutting down");
    Ok(())
}
