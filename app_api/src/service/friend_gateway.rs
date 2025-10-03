use anyhow::{anyhow, Result};
use common::arb::NodeType;
use common::config::AppConfig;
use common::grpc::grpc_hot_friend::friend_service::friend_service_client::FriendServiceClient;
use common::grpc::grpc_hot_friend::friend_service::{FriendEntry, GetFriendsPageDetailedReq};
use common::grpc::GrpcClientManager;
use common::node_util::NodeUtil;
use common::util::common_utils::hash_index;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

static FRIEND_CLIENT_MANAGER: OnceCell<
    GrpcClientManager<FriendServiceClient<Channel>, TransportError>,
> = OnceCell::new();

fn client_manager() -> &'static GrpcClientManager<FriendServiceClient<Channel>, TransportError> {
    FRIEND_CLIENT_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            FriendServiceClient::connect(endpoint).await
        })
    })
}

fn normalize_endpoint(addr: &str) -> String {
    if addr.starts_with("http://") || addr.starts_with("https://") {
        addr.to_string()
    } else {
        format!("http://{}", addr)
    }
}

async fn resolve_friend_addr(user_id: i64) -> Result<String> {
    let node_util = NodeUtil::get();
    let mut nodes = node_util.get_list(NodeType::FriendNode as i32);

    if nodes.is_empty() {
        let fetched = AppConfig::get().urls_for_node_type(NodeType::FriendNode);
        if fetched.is_empty() {
            return Err(anyhow!("friend node list empty"));
        }
        node_util.reset_list(NodeType::FriendNode as i32, fetched.clone());
        nodes = fetched;
    }

    let count = i32::try_from(nodes.len()).unwrap_or(0);
    if count <= 0 {
        return Err(anyhow!("friend node list empty"));
    }

    let index = hash_index(&user_id, count) as usize;
    nodes
        .into_iter()
        .nth(index)
        .ok_or_else(|| anyhow!("friend node index out of range"))
}

async fn connect_friend_service(addr: &str) -> Result<FriendServiceClient<Channel>> {
    let endpoint = normalize_endpoint(addr);
    client_manager()
        .get(&endpoint)
        .await
        .map(|client| client.as_ref().clone())
        .map_err(|err| anyhow!(err))
}

pub async fn get_friends_page_detailed(
    user_id: i64,
    page: u32,
    page_size: u32,
) -> Result<Vec<FriendEntry>> {
    let addr = resolve_friend_addr(user_id).await?;
    let mut client = connect_friend_service(&addr).await?;

    let response = client
        .get_friends_page_detailed(GetFriendsPageDetailedReq {
            user_id,
            page: page as u64,
            page_size: page_size as u64,
        })
        .await
        .map_err(|err| anyhow!("friend service call failed: {err}"))?
        .into_inner();

    Ok(response.friends)
}
