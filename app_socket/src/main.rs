//! app_socket 入口
//! - 加载配置（`APP_CONFIG` 可覆盖默认 `config-socket.toml`）
//! - 初始化会话管理策略（多端登录 + 容量限制）
//! - 启动 TCP（长度前缀 + JSON）与 Kafka→分片→会话分发流水线
//!
//! 说明：
//! - 这里仅负责基础设施启动；WebSocket 连接建立/读写建议在 web 层调用
//!   `SessionManager::register/on_client_msg/unregister` 三个方法进行集成。

// 旧 grpc 模块已移除，改用分类模块
mod grpc_hot_friend;
mod grpc_msg_group;
mod grpc_hot_online;
mod grpc_arb;
mod grpc_msg_friend;
pub mod service;
pub mod proto;
pub mod util;
mod server; // new unified server module
use crate::service::arb_client_server::start_arb_client_server;

use service::{SessionManager, SessionPolicy, MultiLoginPolicy, start_socket_pipeline};
use std::future;
use tokio::signal;
use common::config::AppConfig;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 加载配置（支持 APP_CONFIG 环境变量覆盖配置文件路径）
    let _cfg = AppConfig::init_from_env("./config-socket.toml").await;
    // 初始化会话管理策略：默认“每设备类型单端 + 最大 5 会话/用户”
    let policy = SessionPolicy { multi_login: MultiLoginPolicy::SinglePerDeviceType, max_sessions_per_user: 5 };
    let _sm = SessionManager::init(policy);

    // 启动 TCP 监听（长度前缀 JSON 协议，端口来自配置文件）
    let _ = server::start_tcp_server().await?;

    // 启动消费/分发流水线：Kafka → mpsc 分片 → SessionManager
    // 注：可通过 env 设置分片数、队列容量、broker、group 等参数
    let _ = start_socket_pipeline().await?;

    // 启动 arb 客户端服务（用于接收节点变更通知），端口可通过 ARB_CLIENT_ADDR 设置
    if let Ok(bind) = std::env::var("ARB_CLIENT_ADDR") { let _ = start_arb_client_server(&bind).await; }

    // 等待 Ctrl-C 以优雅退出
    let _ = signal::ctrl_c().await;
    log::info!("app_socket: received Ctrl-C, shutting down");
    Ok(())
}
