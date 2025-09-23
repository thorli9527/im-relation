use common::config::AppConfig;

pub mod db;
mod grpc_hot_online;
mod hot_cold;
mod online_store;
mod rest_online;
mod server;
mod service;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    AppConfig::init_from_env("./config-online.toml").await;
    server::start().await
}
