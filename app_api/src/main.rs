//! app_api entrypoint.
//!
//! The API gateway hosts both REST and gRPC surfaces. Configuration must be loaded before
//! dispatching to the respective server modules so they can read arbitration, database, and socket
//! topology information.

use common::config::AppConfig;

mod server_grpc;
mod server_web;

pub mod grpc;

pub mod handler;
pub mod service;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Load configuration first; downstream `service::init` eagerly reads node lists and caches.
    AppConfig::init_from_env("./config-api.toml").await;
    // Warm arbitration caches and other shared state so both servers share the same view.
    service::init().await;

    // Web (Axum) + gRPC run concurrently; surface-level errors bubble up as boxed errors.
    tokio::try_join!(server_web::start(), server_grpc::start())
        .map(|_| ())
        .map_err(|e| -> Box<dyn std::error::Error> { e.into() })
}
