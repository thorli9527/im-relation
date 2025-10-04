use common::config::AppConfig;
use common::node_util::{NodeType, NodeUtil};

pub mod api_grpc_service;
pub mod auth_models;
pub mod friend_gateway;
pub mod grpc_gateway;
pub mod session;
pub mod user_service;
pub mod user_service_impl;

/// Initialize service-level shared state from static configuration.
pub async fn init() {
    let cfg = AppConfig::get();
    let node_util = NodeUtil::get();

    for node_type in [
        NodeType::SocketNode,
        NodeType::OnlineNode,
        NodeType::FriendNode,
        NodeType::MsgFriend,
        NodeType::MesGroup,
    ] {
        let urls = cfg.urls_for_node_type(node_type);
        if !urls.is_empty() {
            node_util.reset_list(node_type as i32, urls);
        }
    }
}
