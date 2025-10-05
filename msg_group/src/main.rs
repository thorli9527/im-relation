//! msg_group 服务入口：加载配置 → 启动 gRPC/HTTP 服务器

use common::config::{get_db, AppConfig};
use common::util::schema::apply_mysql_schema;
use msg_group::server;

/// 初始化配置后委托给 `server::run_server` 启动 gRPC/HTTP 服务。
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 先从环境变量/配置文件加载全局配置；返回值 `_cfg` 主要用于保持引用。
    let _cfg = AppConfig::init_from_env("./config-msg-group.toml").await;
    let pool = get_db();
    apply_mysql_schema(&pool, include_str!("../migrations/mysql_schema.sql")).await?;
    // run_server 内部会完成数据库、Kafka、Arb 注册等初始化。
    server::run_server().await
}
