use common::config::AppConfig;

mod autotune;
mod db;
mod hot_cold;
mod hot_shard_store;
mod server;
pub mod service;
mod store;

#[tokio::main(flavor = "multi_thread")]
async fn main() -> anyhow::Result<()> {
    AppConfig::init_from_env("./config-friend.toml").await;
    server::start().await
}
