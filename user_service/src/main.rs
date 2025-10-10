//! user_service entrypoint.
//!
//! Responsibilities:
//! - Load configuration (including cache tuning and gRPC/HTTP bind addresses).
//! - Delegate to `server::start`, which wires gRPC servers, REST gateway, and arbitration

use common::config::{get_db, AppConfig};
use common::support::util::schema::apply_mysql_schema;

pub mod db;
mod hot_cold;
mod online_store;
mod rest_online;
mod server;
mod service;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // singleton snapshot to discover Kafka, arb_service, and cache sizing hints.
    AppConfig::init_from_env("./config-user.toml").await;
    let pool = get_db();
    apply_mysql_schema(&pool, include_str!("../migrations/mysql_schema.sql")).await?;
    // Delegate the heavy lifting (gRPC/HTTP servers + background tasks) to the `server` module.
    server::start().await
}
