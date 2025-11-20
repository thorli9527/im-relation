use anyhow::{anyhow, Result};
use common::config::AppConfig;
use common::infra::grpc::grpc_msg_friend::msg_friend_service::{
    friend_msg_service_client::FriendMsgServiceClient, FriendConversationSnapshot,
    ListFriendConversationsRequest,
};
use common::infra::grpc::grpc_msg_group::msg_group_service::{
    group_msg_service_client::GroupMsgServiceClient, GroupConversationSnapshot,
    ListGroupConversationsRequest,
};
use common::infra::grpc::GrpcClientManager;
use common::support::node::{NodeType, NodeUtil};
use common::support::util::common_utils::hash_index;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

pub struct ConversationPage<T> {
    pub snapshots: Vec<T>,
    pub has_more: bool,
}

static FRIEND_MSG_MANAGER: OnceCell<
    GrpcClientManager<FriendMsgServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static GROUP_MSG_MANAGER: OnceCell<
    GrpcClientManager<GroupMsgServiceClient<Channel>, TransportError>,
> = OnceCell::new();

fn normalize_endpoint(addr: &str) -> String {
    if addr.starts_with("http://") || addr.starts_with("https://") {
        addr.to_string()
    } else {
        format!("http://{}", addr)
    }
}

fn friend_msg_manager(
) -> &'static GrpcClientManager<FriendMsgServiceClient<Channel>, TransportError> {
    FRIEND_MSG_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            FriendMsgServiceClient::connect(endpoint).await
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

async fn resolve_addr(node_type: NodeType, key: i64) -> Result<String> {
    let node_util = NodeUtil::get();
    let mut nodes = node_util.get_list(node_type as i32);

    if nodes.is_empty() {
        let configured = AppConfig::get().urls_for_node_type(node_type);
        if configured.is_empty() {
            return Err(anyhow!("node list empty for {}", node_type));
        }
        node_util.reset_list(node_type as i32, configured.clone());
        nodes = configured;
    }

    let total = i32::try_from(nodes.len()).unwrap_or(0);
    if total <= 0 {
        return Err(anyhow!("node list empty for {}", node_type));
    }

    let idx = hash_index(&key, total) as usize;
    nodes
        .into_iter()
        .nth(idx)
        .ok_or_else(|| anyhow!("node index out of range for {}", node_type))
}

async fn connect_friend_msg(addr: &str) -> Result<FriendMsgServiceClient<Channel>> {
    friend_msg_manager()
        .get(&normalize_endpoint(addr))
        .await
        .map(|client| client.as_ref().clone())
        .map_err(|err| anyhow!(err))
}

async fn connect_group_msg(addr: &str) -> Result<GroupMsgServiceClient<Channel>> {
    group_msg_manager()
        .get(&normalize_endpoint(addr))
        .await
        .map(|client| client.as_ref().clone())
        .map_err(|err| anyhow!(err))
}

pub async fn list_friend_conversations(
    owner_id: i64,
    limit: u32,
    before_updated_at: Option<i64>,
    before_conversation_id: Option<i64>,
) -> Result<ConversationPage<FriendConversationSnapshot>> {
    let addr = resolve_addr(NodeType::MsgFriend, owner_id).await?;
    let mut client = connect_friend_msg(&addr).await?;

    let request = ListFriendConversationsRequest {
        owner_id,
        limit,
        before_updated_at: before_updated_at.unwrap_or_default(),
        before_conversation_id: before_conversation_id.unwrap_or_default(),
    };

    let response = client
        .list_friend_conversations(request)
        .await
        .map_err(|status| anyhow!("friend msg rpc failed: {status}"))?
        .into_inner();

    Ok(ConversationPage {
        snapshots: response.snapshots,
        has_more: response.has_more,
    })
}

pub async fn list_group_conversations(
    user_id: i64,
    limit: u32,
    before_updated_at: Option<i64>,
    before_group_id: Option<i64>,
) -> Result<ConversationPage<GroupConversationSnapshot>> {
    let addr = resolve_addr(NodeType::MesGroup, user_id).await?;
    let mut client = connect_group_msg(&addr).await?;

    let request = ListGroupConversationsRequest {
        user_id,
        limit,
        before_updated_at: before_updated_at.unwrap_or_default(),
        before_group_id: before_group_id.unwrap_or_default(),
    };

    let response = client
        .list_group_conversations(request)
        .await
        .map_err(|status| anyhow!("group msg rpc failed: {status}"))?
        .into_inner();

    Ok(ConversationPage {
        snapshots: response.snapshots,
        has_more: response.has_more,
    })
}
