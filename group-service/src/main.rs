mod db { pub mod member_list_wrapper; pub mod hash_shard_map; }
mod grpc;
mod store;
mod hot_cold;

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{Context, Result};
use log::warn;
use common::config::{get_db, AppConfig};
use sqlx::{ MySql, Pool};
use tokio::signal;
use crate::db::hash_shard_map::HashShardMap;
use crate::grpc::group_service::group_service_server::GroupServiceServer;
use crate::grpc::group_service_impl::GroupServiceImpl;
use crate::hot_cold::HotColdFacade;
use crate::store::mysql::MySqlStore;

/// 应用入口
/// - 初始化配置与日志
/// - 建立数据库连接 & 应用 schema
/// - 初始化内存结构、冷热层、存储
/// - 启动 gRPC 服务（支持优雅退出）
#[actix_web::main]
async fn main() -> Result<()> {

    // 1) 读取应用配置（示例：从 TOML 文件加载）
    //    若初始化失败会直接报错退出，避免带着不完整配置继续运行
    let app_config = AppConfig::init("./group-config.toml").await;

    // 2) 获取数据库连接池
    //    这里假设 get_db() 内部已完成连接字符串配置与连接池初始化
    let pool = get_db();

    // 3) 执行 schema（多语句 DDL 逐条执行，避免 MySQL multi-statements 限制）
    apply_schema_from_ddl(&pool, include_str!("../migrations/mysql_schema.sql")).await?;

    // 4) 初始化分片结构（HashShardMap）
    //    - SHARD_COUNT 环境变量可覆盖分片数（默认 128，自动向上取 2 的幂）
    //    - per_group_shard 目前保留为 1（为更细粒度分片留扩展位）
    let shard_count = parse_env("SHARD_COUNT", 128usize);
    let map = Arc::new(HashShardMap::new(shard_count, 1));

    // 5) 初始化存储与冷热层门面
    //    - HOT_GROUPS: 热群上限（默认 1_000_000）
    //    - HOT_TTI_SECS: 热数据空闲超时（默认 1800s）
    let store = Arc::new(MySqlStore::new());
    let facade = Arc::new(HotColdFacade::new(
        map.clone(),
        store.clone(),
        parse_env("HOT_GROUPS", 1_000_000u64),
        parse_env("HOT_TTI_SECS", 1_800u64),
    ));

    // 6) 解析 gRPC 监听地址
    let grpc_cfg = app_config.grpc.expect("grpc.error");
    let grpc_addr: SocketAddr = format!("{}:{}", grpc_cfg.host, grpc_cfg.port)
        .parse()
        .context("invalid grpc host:port")?;
    warn!("Starting gRPC server on {}", grpc_addr);

    // 7) 启动 gRPC 服务 + 优雅关停（Ctrl-C 或容器 SIGTERM）
    tonic::transport::Server::builder()
        .add_service(GroupServiceServer::new(GroupServiceImpl { facade }))
        .serve_with_shutdown(grpc_addr, shutdown_signal())
        .await
        .context("gRPC server exited with error")?;

    warn!("Server shutdown complete");
    Ok(())
}

/// 执行 schema 文件中的多条 DDL 语句（逐条执行 + 事务包裹）。
///
/// 注意：这里使用了最简单的分号切分法，适合“纯 DDL、无存储过程/触发器/DELIMITER”的场景。
/// 如果将来要支持复杂 SQL，请改为：
///   1) 使用 sqlx 的迁移系统（推荐）；或
///   2) 写一个更健壮的解析器/状态机来处理 DELIMITER。
async fn apply_schema_from_ddl(pool: &Pool<MySql>, ddl: &str) -> Result<()> {
    // 预检查（可选）：测试简单连通性
    pool.acquire().await.context("failed to acquire DB connection")?;

    // 事务包裹，保证要么全部成功要么全部回滚
    let mut tx = pool.begin().await.context("failed to begin transaction")?;

    let stmts = ddl
        .split(';')             // 简单分割
        .map(str::trim)         // 去掉两端空白
        .filter(|s| !s.is_empty());

    for (i, stmt) in stmts.enumerate() {
        warn!("apply DDL stmt");
        sqlx::query(stmt)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("failed to execute DDL stmt #{}: {}", i, stmt.lines().next().unwrap_or(stmt)))?;
    }

    tx.commit().await.context("failed to commit DDL transaction")?;
    Ok(())
}

/// 解析环境变量，失败则返回默认值。
fn parse_env<T: std::str::FromStr>(key: &str, default: T) -> T {
    std::env::var(key).ok().and_then(|s| s.parse().ok()).unwrap_or(default)
}


/// 优雅关停信号（Ctrl-C 或 SIGTERM）
/// - k8s/容器化场景建议使用该模式，避免强杀导致未完成的请求被中断
async fn shutdown_signal() {
    // Ctrl+C
    let ctrl_c = async {
        signal::ctrl_c().await.expect("failed to install Ctrl+C handler");
    };

    // 其他平台（如 Unix）的 SIGTERM
    #[cfg(unix)]
    let terminate = async {
        let mut sigterm = signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install SIGTERM handler");
        sigterm.recv().await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }

}
