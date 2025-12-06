//! app_api entrypoint.
//!
//! The API gateway hosts both REST and gRPC surfaces. Configuration must be loaded before
//! dispatching to the respective server modules so they can read arbitration, database, and socket
//! topology information.

use app_api::{server_web, service};
use common::config::AppConfig;
use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Load configuration first; downstream `service::init` eagerly reads node lists and caches.
    AppConfig::init_from_env("./config-api.toml").await;
    // Warm arbitration caches and other shared state so both servers share the same view.
    service::init().await;

    // Initialize tracing/logging only if env filter is provided (e.g. RUST_LOG).
    if let Ok(env_filter) = EnvFilter::try_from_default_env() {
        let _ = fmt().with_env_filter(env_filter).try_init();
    } else {
        let _ = fmt().try_init();
    }

    server_web::start().await?;
    Ok(())
}
