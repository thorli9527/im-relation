//! 节点发现辅助：通过仲裁服务获取并缓存节点地址。

use anyhow::{anyhow, Result};
use common::arb::{ArbHttpClient, NodeInfo, NodeInfoList, NodeType, QueryNodeReq};
use common::config::AppConfig;
use common::node_util::NodeUtil;

fn resolve_arb_server_addr() -> Result<String> {
    AppConfig::get()
        .arb_server_addr()
        .ok_or_else(|| anyhow!("arb server addr missing"))
}

fn resolve_access_token() -> Option<String> {
    AppConfig::get().arb().and_then(|g| g.access_token.clone())
}

fn effective_addr(node_type: NodeType, node: &NodeInfo) -> String {
    match node_type {
        NodeType::SocketNode => node
            .kafka_addr
            .clone()
            .unwrap_or_else(|| node.node_addr.clone()),
        _ => node.node_addr.clone(),
    }
}

async fn fetch_nodes(node_type: NodeType) -> Result<NodeInfoList> {
    let addr = resolve_arb_server_addr()?;
    let client = ArbHttpClient::new(addr, resolve_access_token())?;
    client
        .list_all_nodes(&QueryNodeReq {
            node_type: node_type as i32,
        })
        .await
        .map_err(Into::into)
}

pub async fn fetch_msg_friend_addr() -> Result<Option<String>> {
    let list = fetch_nodes(NodeType::MsgFriend).await?;
    let addrs: Vec<String> = list
        .nodes
        .iter()
        .map(|node| effective_addr(NodeType::MsgFriend, node))
        .collect();
    if !addrs.is_empty() {
        NodeUtil::get().reset_list(NodeType::MsgFriend as i32, addrs.clone());
    }
    Ok(addrs.into_iter().next())
}

pub async fn fetch_node_addr(node_type: NodeType) -> Result<Option<String>> {
    let list = fetch_nodes(node_type).await?;
    let addrs: Vec<String> = list
        .nodes
        .iter()
        .map(|node| effective_addr(node_type, node))
        .collect();
    if !addrs.is_empty() {
        NodeUtil::get().reset_list(node_type as i32, addrs.clone());
    }
    Ok(addrs.into_iter().next())
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
