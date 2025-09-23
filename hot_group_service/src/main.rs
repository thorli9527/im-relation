use common::config::AppConfig;

mod hot_capacity;
mod hot_cold;
mod member;
mod profile;
mod server;
mod service;
mod store;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    AppConfig::init_from_env("./config-group.toml").await;
    server::start().await
}
