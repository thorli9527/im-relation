//! Web (HTTP/WebSocket) and arbitration sync entrypoints.

use std::net::SocketAddr;

use anyhow::Result;
use common::service::arb_client;
use log::info;

/// Start the lightweight HTTP server that exposes `/arb/server/sync`.
///
/// Delegates to the shared helper in `common::service::arb_client`, which spawns an Axum server
/// handling arb-sync callbacks. Additional HTTP/WebSocket routes can be layered here later on.
pub async fn start_web_server(bind: &str) -> Result<()> {
    let addr: SocketAddr = bind.parse()?;
    info!("arb sync HTTP server listening on {}", addr);
    arb_client::start_arb_client_server(bind).await?;
    Ok(())
}
