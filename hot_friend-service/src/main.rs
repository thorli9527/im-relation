use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{Context, Result};
use log::warn;
use sqlx::{MySql, Pool};
use tokio::signal;
use tonic::transport::Server;

use common::config::{get_db, AppConfig};
use common::UserId;

use crate::autotune::{auto_tune_cache, AutoTuneConfig, CacheAutoTune};
use crate::grpc::friend_service::friend_service_server::FriendServiceServer;
use crate::grpc::friend_service_impl::FriendServiceImpl;
use crate::hot_cold::HotColdFriendFacade;
use crate::store::mysql::FriendStorage;
// ← 现在用你实现的 FriendStorage

mod db;
mod store;
mod hot_cold;
pub mod grpc;
mod hot_shard_store;
mod autotune;

#[tokio::main(flavor = "multi_thread")]
async fn main() -> Result<()> {
    // 1) 读取应用配置
    let app_config = AppConfig::init("./friend-config.toml").await;
    let grpc_config = app_config.grpc.expect("grpc.config.error");

    // 0) 基本参数
    let grpc_addr: SocketAddr = format!("{}:{}", grpc_config.host, grpc_config.port)
        .parse()
        .expect("Failed to parse GRPC_ADDR");

    // 估计平均条目大小
    let avg_key_bytes = std::mem::size_of::<UserId>(); // u64 -> 8
    let avg_value_bytes = env_parse("AVG_VALUE_BYTES", 256usize);

    // 自动调参参数（支持 env 覆盖）
    let shards = env_parse("SHARDS", 32usize);
    let reserve_ratio = env_parse("AUTOTUNE_RESERVE_RATIO", 0.40_f64);
    let max_use_ratio = env_parse("AUTOTUNE_MAX_USE_RATIO", 0.25_f64);
    let overhead_factor = env_parse("AUTOTUNE_OVERHEAD_FACTOR", 1.6_f64);
    let hot_ratio = env_parse("AUTOTUNE_HOT_RATIO", 0.20_f64);
    let tti_secs = env_parse("AUTOTUNE_TTI_SECS", 60u64);
    let refresh_secs = env_parse("AUTOTUNE_REFRESH_SECS", 0u64); // >0 则周期刷新

    // 1) 自动调参（新签名：AutoTuneConfig）
    let mut cfg = AutoTuneConfig::default();
    cfg.shards = shards.max(1);
    cfg.avg_key_bytes = avg_key_bytes;
    cfg.avg_value_bytes = avg_value_bytes;
    cfg.reserve_ratio = reserve_ratio;
    cfg.max_use_ratio = max_use_ratio;
    cfg.overhead_factor = overhead_factor;
    cfg.hot_ratio = hot_ratio;
    cfg.default_tti = Duration::from_secs(tti_secs);
    // 其余 split / segments / min_hot_per_shard 使用默认值

    let plan: CacheAutoTune = auto_tune_cache(&cfg);

    // 2) 数据库初始化 & 迁移
    let pool = get_db();
    apply_schema_from_ddl(&pool, include_str!("../migrations/mysql_schema.sql")).await?;

    // 3) 存储 & 门面
    let storage = Arc::new(FriendStorage::from_pool(pool.clone()));
    let facade = Arc::new(HotColdFriendFacade::new(
        storage.clone(),
        plan.clone(),
        tokio::runtime::Handle::current(),
    ));

    // 可选：周期性在线自动刷新
    if refresh_secs > 0 {
        let facade_clone = facade.clone();
        tokio::spawn(async move {
            let interval = Duration::from_secs(refresh_secs);
            loop {
                tokio::time::sleep(interval).await;
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

    // 4) 启动 gRPC
    let svc = FriendServiceImpl::<FriendStorage> { facade };

    Server::builder()
        .add_service(FriendServiceServer::new(svc))
        .serve_with_shutdown(grpc_addr, async {
            let _ = signal::ctrl_c().await; // 优雅退出
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

/// 简单 DDL 执行器（逐条执行 + 事务包裹）
async fn apply_schema_from_ddl(pool: &Pool<MySql>, ddl: &str) -> Result<()> {
    pool.acquire().await.context("failed to acquire DB connection")?;
    let mut tx = pool.begin().await.context("failed to begin transaction")?;

    let stmts = ddl.split(';').map(str::trim).filter(|s| !s.is_empty());
    for (i, stmt) in stmts.enumerate() {
        sqlx::query(stmt)
            .execute(&mut *tx)
            .await
            .with_context(|| format!(
                "failed to execute DDL stmt #{}: {}",
                i,
                stmt.lines().next().unwrap_or(stmt)
            ))?;
    }

    tx.commit().await.context("failed to commit DDL transaction")?;
    Ok(())
}
