use common::config::AppConfig;

mod server_web;

pub mod handler;
pub mod service;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    AppConfig::init_from_env("./config-api.toml").await;
    server_web::start().await.map_err(|e| e.into())
}
