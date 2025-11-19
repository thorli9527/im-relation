use common::config::AppConfig;
use common::support::node::{NodeType, NodeUtil};

pub mod auth_models {
    pub use super::user_service::auth_models::*;
}
pub mod friend_gateway;
pub mod group_gateway;
pub mod message_gateway;
pub mod user_gateway;
pub mod user_service;

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

    // Initialize global service instances after node lists are ready.
    user_service::UserService::init();
}
