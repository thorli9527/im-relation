use common::grpc::GrpcClientManager;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

use crate::grpc_arb::arb_server::arb_client_rpc_service_client::ArbClientRpcServiceClient;
use crate::grpc_arb::arb_server::arb_server_rpc_service_client::ArbServerRpcServiceClient;
use crate::grpc_hot_online::online_service::online_service_client::OnlineServiceClient;
use crate::grpc_msg_friend::msg_friend_service::friend_biz_service_client::FriendBizServiceClient;
use crate::grpc_msg_friend::msg_friend_service::friend_msg_service_client::FriendMsgServiceClient;

fn normalize_endpoint(addr: &str) -> String {
    if addr.starts_with("http://") || addr.starts_with("https://") {
        addr.to_string()
    } else {
        format!("http://{}", addr)
    }
}

static FRIEND_MSG_MANAGER: OnceCell<
    GrpcClientManager<FriendMsgServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static FRIEND_BIZ_MANAGER: OnceCell<
    GrpcClientManager<FriendBizServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static ONLINE_MANAGER: OnceCell<GrpcClientManager<OnlineServiceClient<Channel>, TransportError>> =
    OnceCell::new();
static ARB_SERVER_MANAGER: OnceCell<
    GrpcClientManager<ArbServerRpcServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static ARB_CLIENT_MANAGER: OnceCell<
    GrpcClientManager<ArbClientRpcServiceClient<Channel>, TransportError>,
> = OnceCell::new();

fn friend_msg_manager(
) -> &'static GrpcClientManager<FriendMsgServiceClient<Channel>, TransportError> {
    FRIEND_MSG_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            FriendMsgServiceClient::connect(endpoint).await
        })
    })
}

fn friend_biz_manager(
) -> &'static GrpcClientManager<FriendBizServiceClient<Channel>, TransportError> {
    FRIEND_BIZ_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            FriendBizServiceClient::connect(endpoint).await
        })
    })
}

fn online_manager() -> &'static GrpcClientManager<OnlineServiceClient<Channel>, TransportError> {
    ONLINE_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            OnlineServiceClient::connect(endpoint).await
        })
    })
}

fn arb_server_manager(
) -> &'static GrpcClientManager<ArbServerRpcServiceClient<Channel>, TransportError> {
    ARB_SERVER_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            ArbServerRpcServiceClient::connect(endpoint).await
        })
    })
}

fn arb_client_manager(
) -> &'static GrpcClientManager<ArbClientRpcServiceClient<Channel>, TransportError> {
    ARB_CLIENT_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            ArbClientRpcServiceClient::connect(endpoint).await
        })
    })
}

pub async fn friend_msg_client(
    addr: &str,
) -> Result<FriendMsgServiceClient<Channel>, TransportError> {
    let endpoint = normalize_endpoint(addr);
    friend_msg_manager()
        .get(&endpoint)
        .await
        .map(|c| c.as_ref().clone())
}

pub fn invalidate_friend_msg(addr: &str) {
    friend_msg_manager().invalidate(&normalize_endpoint(addr));
}

pub async fn friend_biz_client(
    addr: &str,
) -> Result<FriendBizServiceClient<Channel>, TransportError> {
    let endpoint = normalize_endpoint(addr);
    friend_biz_manager()
        .get(&endpoint)
        .await
        .map(|c| c.as_ref().clone())
}

pub fn invalidate_friend_biz(addr: &str) {
    friend_biz_manager().invalidate(&normalize_endpoint(addr));
}

pub async fn online_client(addr: &str) -> Result<OnlineServiceClient<Channel>, TransportError> {
    let endpoint = normalize_endpoint(addr);
    online_manager()
        .get(&endpoint)
        .await
        .map(|c| c.as_ref().clone())
}

pub fn invalidate_online(addr: &str) {
    online_manager().invalidate(&normalize_endpoint(addr));
}

pub async fn arb_server_client(
    addr: &str,
) -> Result<ArbServerRpcServiceClient<Channel>, TransportError> {
    let endpoint = normalize_endpoint(addr);
    arb_server_manager()
        .get(&endpoint)
        .await
        .map(|c| c.as_ref().clone())
}

pub async fn arb_client_client(
    addr: &str,
) -> Result<ArbClientRpcServiceClient<Channel>, TransportError> {
    let endpoint = normalize_endpoint(addr);
    arb_client_manager()
        .get(&endpoint)
        .await
        .map(|c| c.as_ref().clone())
}
