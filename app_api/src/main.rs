use common::config::AppConfig;

mod server_grpc;
mod server_web;

pub mod grpc;

pub mod handler;
pub mod service;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    AppConfig::init_from_env("./config-api.toml").await;
    service::init().await;

    tokio::try_join!(server_web::start(), server_grpc::start())
        .map(|_| ())
        .map_err(|e| -> Box<dyn std::error::Error> { e.into() })
}
