use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::Result;
use tokio::signal;
use tonic::transport::Server;

use common::config::get_db;
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
    // ========= 0) 环境配置 =========
    let grpc_addr: SocketAddr = std::env::var("GRPC_ADDR")
        .unwrap_or_else(|_| "0.0.0.0:50052".into())
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
    let ddl = include_str!("../migrations/mysql_schema.sql");
    sqlx::query(ddl).execute(&*(pool.clone())).await?;

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
                println!("[autotune] refreshed plan: {:?}", p);
            }
        });
    }

    // ========= 4) 启动 gRPC =========
    let svc = FriendServiceImpl::<MySqlFriendStore> {
        facade: facade.clone(),
    };

    println!("[grpc] starting server on {grpc_addr}");
    Server::builder()
        .add_service(FriendServiceServer::new(svc))
        .serve_with_shutdown(grpc_addr, async {
            // 优雅退出：Ctrl+C / SIGINT
            let _ = signal::ctrl_c().await;
            println!("[grpc] shutting down...");
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
