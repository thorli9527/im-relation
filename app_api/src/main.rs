use common::config::AppConfig;

mod server;

pub mod handler;
pub mod service;
pub mod util;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    AppConfig::init_from_env("./config-api.toml").await;
    server::start().await.map_err(|e| e.into())
}
