use common::config::AppConfig;

mod grpc_arb;
mod grpc_arb_client;
mod grpc_hot_online;
mod server;

pub mod handler;
pub mod service;
pub mod util;

#[actix_web::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    AppConfig::init_from_env("./config-api.toml").await;
    server::start().await.map_err(|e| e.into())
}
