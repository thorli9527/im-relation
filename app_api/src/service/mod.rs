use crate::util::node_util::NodeUtil;
use common::arb::NodeType;

pub mod grpc_gateway;
pub mod user_service;
pub mod user_service_impl;

/// Initialize service-level shared state.
///
/// Currently this loads node lists from optional environment variables:
/// - `SOCKET_NODE_ADDRS`: comma-separated endpoints for socket nodes
/// - `ONLINE_NODE_ADDRS`: comma-separated endpoints for online/client RPC nodes
pub async fn init() {
    load_nodes_from_env(NodeType::SocketNode, "SOCKET_NODE_ADDRS");
    load_nodes_from_env(NodeType::OnlineNode, "ONLINE_NODE_ADDRS");
}

fn load_nodes_from_env(kind: NodeType, env_key: &str) {
    if let Ok(value) = std::env::var(env_key) {
        let addrs: Vec<String> = value
            .split(',')
            .map(|s| s.trim())
            .filter(|s| !s.is_empty())
            .map(|s| s.to_string())
            .collect();
        if !addrs.is_empty() {
            NodeUtil::get().reset_list(kind as i32, addrs);
        }
    }
}
