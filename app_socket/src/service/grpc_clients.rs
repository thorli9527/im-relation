use common::infra::grpc::grpc_msg_friend::msg_friend_service::friend_msg_service_client::FriendMsgServiceClient;
use common::infra::grpc::grpc_msg_group::msg_group_service::group_msg_service_client::GroupMsgServiceClient;
use common::infra::grpc::grpc_user::online_service::online_service_client::OnlineServiceClient;
use common::infra::grpc::grpc_user::online_service::user_rpc_service_client::UserRpcServiceClient;
use common::infra::grpc::GrpcClientManager;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

/// gRPC 地址需要显式协议，统一补全 http://。
fn normalize_endpoint(addr: &str) -> String {
    if addr.starts_with("http://") || addr.starts_with("https://") {
        addr.to_string()
    } else {
        format!("http://{}", addr)
    }
}

macro_rules! define_grpc_client {
    (
        $client_ty:ty,
        $static_name:ident,
        $manager_fn:ident,
        $get_fn:ident,
        $invalidate_fn:ident
    ) => {
        static $static_name: OnceCell<GrpcClientManager<$client_ty, TransportError>> =
            OnceCell::new();

        fn $manager_fn() -> &'static GrpcClientManager<$client_ty, TransportError> {
            $static_name.get_or_init(|| {
                GrpcClientManager::new(|endpoint: String| async move {
                    <$client_ty>::connect(endpoint).await
                })
            })
        }

        pub async fn $get_fn(addr: &str) -> Result<$client_ty, TransportError> {
            let endpoint = normalize_endpoint(addr);
            $manager_fn()
                .get(&endpoint)
                .await
                .map(|client| client.as_ref().clone())
        }

        pub fn $invalidate_fn(addr: &str) {
            $manager_fn().invalidate(&normalize_endpoint(addr));
        }
    };
}

define_grpc_client!(
    FriendMsgServiceClient<Channel>,
    FRIEND_MSG_MANAGER,
    friend_msg_manager,
    friend_msg_client,
    invalidate_friend_msg
);
define_grpc_client!(
    GroupMsgServiceClient<Channel>,
    GROUP_MSG_MANAGER,
    group_msg_manager,
    group_msg_client,
    invalidate_group_msg
);
define_grpc_client!(
    UserRpcServiceClient<Channel>,
    USER_RPC_MANAGER,
    user_rpc_manager,
    user_rpc_client,
    invalidate_user_rpc
);
define_grpc_client!(
    OnlineServiceClient<Channel>,
    ONLINE_MANAGER,
    online_manager,
    online_client,
    invalidate_online
);
