//! Web (HTTP/WebSocket) and gRPC (arb client) server entry

use log::info;

/// Start the Web server at `bind`.
/// Swap in your preferred framework (Axum, Actix, etc.).
pub async fn start_web_server(bind: &str) -> anyhow::Result<()> {
    let addr: std::net::SocketAddr = bind.parse()?;
    // Placeholder; integrate a real HTTP router here.
    // 当前仅输出日志，保持接口契约，后续可替换为真实 HTTP/WebSocket 服务。
    info!("Web server placeholder bound: {}", addr);
    Ok(())
}

/// Start the gRPC Arb client server (arb-service push endpoint).
/// This exposes `ArbClientRpcService` so arb-service can notify this node.
pub async fn start_arb_client_grpc(bind: &str) -> anyhow::Result<()> {
    crate::service::arb_client_server::start_arb_client_server(bind).await
}

// 说明：合并同端口（Web+gRPC）的兼容入口已移除，按需分别启动。
