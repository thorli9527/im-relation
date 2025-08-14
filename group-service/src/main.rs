mod db { pub mod member_list_wrapper; pub mod hash_shard_map; }
mod grpc;
mod store;
mod hot_cold;

use crate::db::hash_shard_map::HashShardMap;
use crate::grpc::group_service::group_service_server::GroupServiceServer;
use crate::grpc::group_service_impl::GroupServiceImpl;
use crate::hot_cold::HotColdFacade;
use crate::store::mysql::MySqlStore;
use anyhow::Result;
use common::config::{get_db, AppConfig};
use sqlx::Executor;
use std::net::SocketAddr;
use std::sync::Arc;

#[actix_web::main]
async fn main() -> Result<()> {
    AppConfig::init(&"./group-config.toml".to_string()).await;
    let pool = get_db();
    let ddl = include_str!("../migrations/mysql_schema.sql");
    let stmts = ddl
        .split(';')
        .map(str::trim)
        .filter(|s| !s.is_empty());

    let mut tx = pool.begin().await?;

    for stmt in stmts {
        sqlx::query(stmt).execute(&mut *tx).await?;
    }

    let map = Arc::new(HashShardMap::new(
        std::env::var("SHARD_COUNT").ok().and_then(|s| s.parse().ok()).unwrap_or(128),
        1,
    ));
    let store = Arc::new(MySqlStore::new());
    let facade = Arc::new(HotColdFacade::new(
        map.clone(),
        store.clone(),
        std::env::var("HOT_GROUPS").ok().and_then(|s| s.parse().ok()).unwrap_or(10_000u64),
        std::env::var("HOT_TTI_SECS").ok().and_then(|s| s.parse().ok()).unwrap_or(1800u64),
    ));

    let grpc_addr: SocketAddr = std::env::var("GRPC_ADDR").unwrap_or_else(|_| "0.0.0.0:50051".into()).parse()?;

    tonic::transport::Server::builder()
        .add_service(GroupServiceServer::new(GroupServiceImpl { facade }))
        .serve(grpc_addr)
        .await?;

    Ok(())
}
