//! friend_service entrypoint.
//!
//! It bootstraps configuration (including cache autotune knobs) and defers the actual runtime
//! wiring—Kafka, gRPC, arb_service heartbeat—to `server::start`.

use common::config::{get_db, AppConfig};
use common::util::schema::apply_mysql_schema;

mod autotune;
mod db;
mod hot_cold;
mod hot_shard_store;
mod server;
pub mod service;
mod store;

#[tokio::main(flavor = "multi_thread")]
async fn main() -> anyhow::Result<()> {
    // Load configuration (potentially from `APP_CONFIG`) before any module reads global settings.
    AppConfig::init_from_env("./config-friend.toml").await;
    let pool = get_db();
    apply_mysql_schema(&pool, include_str!("../migrations/mysql_schema.sql")).await?;
    server::start().await
}
