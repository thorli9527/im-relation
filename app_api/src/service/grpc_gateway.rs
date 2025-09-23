use anyhow::{anyhow, Result};
use common::arb::NodeType;
use common::grpc::grpc_hot_online::online_service::client_rpc_service_client::ClientRpcServiceClient;
use common::grpc::grpc_hot_online::online_service::online_service_client::OnlineServiceClient;
use common::grpc::GrpcClientManager;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

use crate::util::node_util::NodeUtil;

static ONLINE_MANAGER: OnceCell<GrpcClientManager<OnlineServiceClient<Channel>, TransportError>> =
    OnceCell::new();
static CLIENT_RPC_MANAGER: OnceCell<
    GrpcClientManager<ClientRpcServiceClient<Channel>, TransportError>,
> = OnceCell::new();

fn normalize_endpoint(addr: &str) -> String {
    if addr.starts_with("http://") || addr.starts_with("https://") {
        addr.to_string()
    } else {
        format!("http://{}", addr)
    }
}

fn online_manager() -> &'static GrpcClientManager<OnlineServiceClient<Channel>, TransportError> {
    ONLINE_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            OnlineServiceClient::connect(endpoint).await
        })
    })
}

fn client_rpc_manager(
) -> &'static GrpcClientManager<ClientRpcServiceClient<Channel>, TransportError> {
    CLIENT_RPC_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            ClientRpcServiceClient::connect(endpoint).await
        })
    })
}

fn parse_addr_list(value: &str) -> Vec<String> {
    value
        .split(',')
        .map(|s| s.trim())
        .filter(|s| !s.is_empty())
        .map(|s| s.to_string())
        .collect()
}

fn default_addr(kind: NodeType, env_keys: &[&str]) -> Option<String> {
    let util = NodeUtil::get();
    if let Some(addr) = util.get_list(kind as i32).into_iter().next() {
        return Some(addr);
    }

    for key in env_keys {
        if let Ok(value) = std::env::var(key) {
            if let Some(addr) = parse_addr_list(&value).into_iter().next() {
                return Some(addr);
            }
        }
    }

    None
}

pub async fn get_online_client() -> Result<OnlineServiceClient<Channel>> {
    let addr = default_addr(
        NodeType::OnlineNode,
        &["ONLINE_NODE_ADDRS", "ONLINE_NODE_ADDR"],
    )
    .ok_or_else(|| anyhow!("online node address not configured"))?;
    online_manager()
        .get(&normalize_endpoint(&addr))
        .await
        .map(|client| client.as_ref().clone())
        .map_err(|e| anyhow!(e))
}

pub async fn get_client_rpc_client() -> Result<ClientRpcServiceClient<Channel>> {
    let addr = default_addr(
        NodeType::OnlineNode,
        &["ONLINE_NODE_ADDRS", "ONLINE_NODE_ADDR"],
    )
    .ok_or_else(|| anyhow!("client RPC node address not configured"))?;
    client_rpc_manager()
        .get(&normalize_endpoint(&addr))
        .await
        .map(|client| client.as_ref().clone())
        .map_err(|e| anyhow!(e))
}

pub async fn online_client_by_addr(
    addr: &str,
) -> Result<OnlineServiceClient<Channel>, TransportError> {
    OnlineServiceClient::connect(normalize_endpoint(addr)).await
}
