//! msg_system 服务入口：加载配置并启动系统消息 gRPC 服务。

use common::config::{get_db, AppConfig};
use common::support::util::schema::apply_mysql_schema;

mod server;
mod service;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 加载配置文件/环境变量。
    let _cfg = AppConfig::init_from_env("./config-msg-system.toml").await;
    let pool = get_db();
    apply_mysql_schema(&pool, include_str!("../migrations/mysql_schema.sql")).await?;
    server::run_server().await
}
