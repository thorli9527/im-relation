use common::grpc::GrpcClientManager;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

use common::grpc::grpc_hot_online::online_service::online_service_client::OnlineServiceClient;
use common::grpc::grpc_msg_friend::msg_friend_service::friend_biz_service_client::FriendBizServiceClient;
use common::grpc::grpc_msg_friend::msg_friend_service::friend_msg_service_client::FriendMsgServiceClient;
use common::grpc::grpc_msg_group::msg_group_service::group_biz_service_client::GroupBizServiceClient;
use common::grpc::grpc_msg_group::msg_group_service::group_msg_service_client::GroupMsgServiceClient;

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
static GROUP_MSG_MANAGER: OnceCell<
    GrpcClientManager<GroupMsgServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static GROUP_BIZ_MANAGER: OnceCell<
    GrpcClientManager<GroupBizServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static ONLINE_MANAGER: OnceCell<GrpcClientManager<OnlineServiceClient<Channel>, TransportError>> =
    OnceCell::new();

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

fn group_msg_manager() -> &'static GrpcClientManager<GroupMsgServiceClient<Channel>, TransportError>
{
    GROUP_MSG_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            GroupMsgServiceClient::connect(endpoint).await
        })
    })
}

fn group_biz_manager() -> &'static GrpcClientManager<GroupBizServiceClient<Channel>, TransportError>
{
    GROUP_BIZ_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            GroupBizServiceClient::connect(endpoint).await
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

pub async fn group_msg_client(
    addr: &str,
) -> Result<GroupMsgServiceClient<Channel>, TransportError> {
    let endpoint = normalize_endpoint(addr);
    group_msg_manager()
        .get(&endpoint)
        .await
        .map(|c| c.as_ref().clone())
}

pub fn invalidate_group_msg(addr: &str) {
    group_msg_manager().invalidate(&normalize_endpoint(addr));
}

pub async fn group_biz_client(
    addr: &str,
) -> Result<GroupBizServiceClient<Channel>, TransportError> {
    let endpoint = normalize_endpoint(addr);
    group_biz_manager()
        .get(&endpoint)
        .await
        .map(|c| c.as_ref().clone())
}

pub fn invalidate_group_biz(addr: &str) {
    group_biz_manager().invalidate(&normalize_endpoint(addr));
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
