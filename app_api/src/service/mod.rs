use common::arb::NodeType;
use common::service::arb_client;
use log::warn;

pub mod auth_models;
pub mod grpc_gateway;
pub mod user_service;
pub mod user_service_impl;

/// Initialize service-level shared state.
/// Preload arbitration caches so API can discover peer services early.
pub async fn init() {
    for node_type in [NodeType::SocketNode, NodeType::OnlineNode] {
        if let Err(err) = arb_client::ensure_nodes(node_type).await {
            warn!("preload {} nodes from arb failed: {}", node_type, err);
        }
    }
}
