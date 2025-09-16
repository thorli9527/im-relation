//! 节点发现辅助：通过仲裁服务获取并缓存节点地址。

use crate::grpc_arb::arb_server::{NodeType, QueryNodeReq};
use crate::grpc_arb::client::connect_server;
use anyhow::{anyhow, Result};
use common::config::AppConfig;
pub use common::node_util::NodeUtil;

fn resolve_arb_addr() -> Result<String> {
    AppConfig::get()
        .grpc
        .as_ref()
        .and_then(|g| g.client_addr.clone())
        .ok_or_else(|| anyhow!("grpc.client_addr missing"))
}

pub async fn fetch_msg_friend_addr() -> Result<Option<String>> {
    let server = resolve_arb_addr()?;
    let mut cli = connect_server(&server).await?;
    let req = QueryNodeReq {
        node_type: NodeType::MsgFriend as i32,
    };
    let nodes = cli.list_all_nodes(req).await?.into_inner().nodes;
    if !nodes.is_empty() {
        NodeUtil::get().reset_list(
            NodeType::MsgFriend as i32,
            nodes.iter().map(|n| n.node_addr.clone()).collect(),
        );
    }
    Ok(nodes.into_iter().map(|n| n.node_addr).next())
}

pub async fn fetch_node_addr(node_type: NodeType) -> Result<Option<String>> {
    let server = resolve_arb_addr()?;
    let mut cli = connect_server(&server).await?;
    let req = QueryNodeReq {
        node_type: node_type as i32,
    };
    let nodes = cli.list_all_nodes(req).await?.into_inner().nodes;
    if !nodes.is_empty() {
        NodeUtil::get().reset_list(
            node_type as i32,
            nodes.iter().map(|n| n.node_addr.clone()).collect(),
        );
    }
    Ok(nodes.into_iter().map(|n| n.node_addr).next())
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
