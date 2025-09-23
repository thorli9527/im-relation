//! Arbitration (arb_service) integration: registration + heartbeat for socket nodes.

use std::time::Duration;

use anyhow::Result;
use common::arb::{ArbHttpClient, BaseRequest, NodeType, RegisterRequest};
use common::config::AppConfig;
use log::{info, warn};
use tokio::time;

/// Register current socket node to arbitration service (if configured) and spawn heartbeat task.
///
/// - `http_addr`: address that exposes the `/arb/server/sync` HTTP endpoint.
/// - `tcp_addr`: actual TCP entry point for socket clients, advertised via `kafka_addr`.
pub async fn register_with_arb(http_addr: &str, tcp_addr: &str) -> Result<()> {
    let cfg = AppConfig::get();
    let Some(arb_cfg) = cfg.arb() else {
        warn!("arb config missing; skip arb registration");
        return Ok(());
    };
    let Some(server_addr) = arb_cfg.server_addr.as_ref() else {
        warn!("arb.server_addr missing; skip arb registration");
        return Ok(());
    };

    let arb_http = ArbHttpClient::new(server_addr.clone(), arb_cfg.access_token.clone())?;
    arb_http
        .register_node(&RegisterRequest {
            node_addr: http_addr.to_string(),
            node_type: NodeType::SocketNode as i32,
            kafka_addr: Some(tcp_addr.to_string()),
        })
        .await?;

    info!(
        "arb registration ok: node_type=SocketNode http_addr={} tcp_addr={}",
        http_addr, tcp_addr
    );

    spawn_heartbeat(arb_http, http_addr.to_string());
    Ok(())
}

fn spawn_heartbeat(client: ArbHttpClient, http_addr: String) {
    tokio::spawn(async move {
        let mut interval = time::interval(Duration::from_secs(10));
        loop {
            interval.tick().await;
            if let Err(err) = client
                .heartbeat(&BaseRequest {
                    node_addr: http_addr.clone(),
                    node_type: NodeType::SocketNode as i32,
                })
                .await
            {
                warn!("arb heartbeat failed: {}", err);
                time::sleep(Duration::from_secs(3)).await;
            }
        }
    });
}
