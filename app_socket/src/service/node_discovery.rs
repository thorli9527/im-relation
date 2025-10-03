//! 节点发现辅助：改为通过配置文件获取并缓存节点地址。

use anyhow::{anyhow, Result};
use common::arb::NodeType;
use common::config::AppConfig;
use common::node_util::NodeUtil;

fn endpoints_for(node_type: NodeType) -> Vec<String> {
    AppConfig::get().urls_for_node_type(node_type)
}

fn seed_cache(node_type: NodeType) -> Vec<String> {
    let urls = endpoints_for(node_type);
    if !urls.is_empty() {
        NodeUtil::get().reset_list(node_type as i32, urls.clone());
    }
    urls
}

pub async fn fetch_msg_friend_addr() -> Result<Option<String>> {
    let cached = NodeUtil::get().get_list(NodeType::MsgFriend as i32);
    if !cached.is_empty() {
        return Ok(cached.into_iter().next());
    }
    Ok(seed_cache(NodeType::MsgFriend).into_iter().next())
}

pub async fn fetch_node_addr(node_type: NodeType) -> Result<Option<String>> {
    let cached = NodeUtil::get().get_list(node_type as i32);
    if !cached.is_empty() {
        return Ok(cached.into_iter().next());
    }
    Ok(seed_cache(node_type).into_iter().next())
}

pub async fn resolve_hot_friend_addr() -> Result<String> {
    fetch_node_addr(NodeType::MsgFriend)
        .await?
        .ok_or_else(|| anyhow!("hot_friend address not available"))
}

pub async fn resolve_hot_online_addr() -> Result<String> {
    fetch_node_addr(NodeType::OnlineNode)
        .await?
        .ok_or_else(|| anyhow!("hot_online address not available"))
}
