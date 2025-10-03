//! user_service entrypoint.
//!
//! Responsibilities:
//! - Load configuration (including cache tuning and gRPC/HTTP bind addresses).
//! - Delegate to `server::start`, which wires gRPC servers, REST gateway, and arbitration
//!   registration for hot online sessions.

use common::config::AppConfig;

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
    // Delegate the heavy lifting (gRPC/HTTP servers + background tasks) to the `server` module.
    server::start().await
}
