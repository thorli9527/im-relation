use anyhow::{anyhow, Result};
use common::config::AppConfig;
use common::infra::grpc::grpc_user::online_service::online_service_client::OnlineServiceClient;
use common::infra::grpc::grpc_user::online_service::user_rpc_service_client::UserRpcServiceClient;
use common::infra::grpc::GrpcClientManager;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

use common::support::node::{NodeType, NodeUtil};

static ONLINE_MANAGER: OnceCell<GrpcClientManager<OnlineServiceClient<Channel>, TransportError>> =
    OnceCell::new();
static CLIENT_RPC_MANAGER: OnceCell<
    GrpcClientManager<UserRpcServiceClient<Channel>, TransportError>,
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

fn client_rpc_manager() -> &'static GrpcClientManager<UserRpcServiceClient<Channel>, TransportError>
{
    CLIENT_RPC_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            UserRpcServiceClient::connect(endpoint).await
        })
    })
}

async fn resolve_online_endpoint() -> Result<String> {
    if let Some(addr) = NodeUtil::get()
        .get_list(NodeType::OnlineNode as i32)
        .into_iter()
        .next()
    {
        return Ok(addr);
    }

    AppConfig::get()
        .urls_for_node_type(NodeType::OnlineNode)
        .into_iter()
        .next()
        .ok_or_else(|| anyhow!("online node address not configured"))
}

pub async fn get_online_client() -> Result<OnlineServiceClient<Channel>> {
    let addr = resolve_online_endpoint().await?;
    online_manager()
        .get(&normalize_endpoint(&addr))
        .await
        .map(|client| client.as_ref().clone())
        .map_err(|e| anyhow!(e))
}

pub async fn get_user_rpc_client() -> Result<UserRpcServiceClient<Channel>> {
    let addr = resolve_online_endpoint().await?;
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
