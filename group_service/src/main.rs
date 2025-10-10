//! group_service entrypoint.
//!
//! This binary orchestrates the hot-group cache service: configuration bootstrap happens here,
//! while the `server` module spins up gRPC/HTTP endpoints, Kafka dispatchers, and arb_service
//! integration.

use common::config::{get_db, AppConfig};
use common::support::util::schema::apply_mysql_schema;

mod hot_capacity;
mod hot_cold;
mod member;
mod profile;
mod server;
mod service;
mod store;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Populate the global `AppConfig` snapshot: later modules read cache sizing, database, and
    // arbitration hints from it.
    AppConfig::init_from_env("./config-group.toml").await;
    let pool = get_db();
    apply_mysql_schema(&pool, include_str!("../migrations/mysql_schema.sql")).await?;
    // Defer actual service bring-up (gRPC + HTTP + background tasks) to the `server` module.
    server::start().await
}
