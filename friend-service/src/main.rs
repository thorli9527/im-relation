use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;
use actix_web::cookie::time::format_description::parse;
use anyhow::{Context, Result};
use log::warn;
use sqlx::{MySql, Pool};
use tokio::signal;
use tonic::transport::Server;

use common::config::{get_db, AppConfig};
use common::UserId;

use crate::autotune::{auto_tune_cache, CacheAutoTune};
use crate::grpc::friend_service::friend_service_server::FriendServiceServer;
use crate::grpc::friend_service_impl::FriendServiceImpl;
use crate::hot_cold::HotColdFriendFacade;
use crate::store::mysql::MySqlFriendStore;

mod db;
mod store;
mod hot_cold;
pub mod grpc;
mod hot_shard_store;
mod autotune;

#[tokio::main(flavor = "multi_thread")]
async fn main() -> Result<()> {
    // 1) 读取应用配置（示例：从 TOML 文件加载）
    //    若初始化失败会直接报错退出，避免带着不完整配置继续运行
    let app_config = AppConfig::init("./friend-config.toml").await;
    let grpc_config=app_config.grpc.expect("grpc.config.error");
    // ========= 0) 环境配置 =========
    let grpc_addr: SocketAddr = format!("{}:{}",grpc_config.host,grpc_config.port)
        .parse()
        .expect("Failed to parse GRPC_ADDR");

    // 估计平均条目大小（尽量结合真实数据或做在线自校准）
    let avg_key_bytes = std::mem::size_of::<UserId>(); // u64 -> 8
    let avg_value_bytes = env_parse("AVG_VALUE_BYTES", 256usize); // 例如平均好友表驻留 ~256B

    // 自动调参参数（可用 env 覆盖）
    let shards = env_parse("SHARDS", 32usize);
    let reserve_ratio = env_parse("AUTOTUNE_RESERVE_RATIO", 0.40_f64);
    let max_use_ratio = env_parse("AUTOTUNE_MAX_USE_RATIO", 0.25_f64);
    let overhead_factor = env_parse("AUTOTUNE_OVERHEAD_FACTOR", 1.6_f64);
    let hot_ratio = env_parse("AUTOTUNE_HOT_RATIO", 0.20_f64);
    let tti_secs = env_parse("AUTOTUNE_TTI_SECS", 60u64);
    let refresh_secs = env_parse("AUTOTUNE_REFRESH_SECS", 0u64); // >0 则周期性刷新

    // ========= 1) 自动调参 =========
    let plan: CacheAutoTune = auto_tune_cache(
        shards,
        avg_key_bytes,
        avg_value_bytes,
        reserve_ratio,
        max_use_ratio,
        overhead_factor,
        hot_ratio,
        Duration::from_secs(tti_secs),
    );
    
    // ========= 2) 数据库初始化 & 迁移 =========
    let pool = get_db();

    // 你的迁移文件（若已包含 meta 表，下面的手动建表会 no-op）
    apply_schema_from_ddl(&pool, include_str!("../migrations/mysql_schema.sql")).await?;

    // ========= 3) 存储 & 门面 =========
    let storage = Arc::new(MySqlFriendStore::from_pool(pool.clone()));
    let facade = Arc::new(HotColdFriendFacade::new(
        storage.clone(),
        plan.clone(),
        tokio::runtime::Handle::current(),
    ));

    // 可选：启动周期性“内存检测+自动刷新”
    if refresh_secs > 0 {
        let facade_clone = facade.clone();
        tokio::spawn(async move {
            let interval = Duration::from_secs(refresh_secs);
            loop {
                tokio::time::sleep(interval).await;
                // 使用当前同一套估计参数进行在线刷新（分片数沿用当前）
                facade_clone.refresh_by_autotune(
                    avg_key_bytes,
                    avg_value_bytes,
                    reserve_ratio,
                    max_use_ratio,
                    overhead_factor,
                    hot_ratio,
                    Duration::from_secs(tti_secs),
                );
                let p = facade_clone.current_plan();
                warn!("[autotune] refreshed plan: {:?}", p);
            }
        });
    }

    // ========= 4) 启动 gRPC =========
    let svc = FriendServiceImpl::<MySqlFriendStore> {
        facade: facade.clone(),
    };

    Server::builder()
        .add_service(FriendServiceServer::new(svc))
        .serve_with_shutdown(grpc_addr, async {
            // 优雅退出：Ctrl+C / SIGINT
            let _ = signal::ctrl_c().await;
        })
        .await?;

    Ok(())
}

// ========== 工具函数 ==========

fn env_parse<T>(key: &str, default: T) -> T
where
    T: std::str::FromStr + Copy,
{
    std::env::var(key)
        .ok()
        .and_then(|s| s.parse::<T>().ok())
        .unwrap_or(default)
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
        sqlx::query(stmt)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("failed to execute DDL stmt #{}: {}", i, stmt.lines().next().unwrap_or(stmt)))?;
    }

    tx.commit().await.context("failed to commit DDL transaction")?;
    Ok(())
}