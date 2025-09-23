//! msg_friend 服务入口：加载配置后交由 server 模块启动。

use common::config::AppConfig;

mod dao;
mod hot_friend_client;
mod server;
mod service;

/// 初始化配置并启动好友消息 gRPC 服务。
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 加载配置文件/环境变量。
    let _cfg = AppConfig::init_from_env("./config-msg-friend.toml").await;
    // server::run_server 负责后续的依赖初始化与服务启动。
    server::run_server().await
}
