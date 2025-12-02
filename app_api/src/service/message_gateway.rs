use anyhow::{anyhow, Result};
use base64::engine::general_purpose::STANDARD as BASE64;
use base64::Engine;
use common::config::AppConfig;
use common::infra::grpc::grpc_msg_group::msg_group_service::{
    group_msg_service_client::GroupMsgServiceClient, BroadcastGroupProfileUpdatesReq,
    GroupConversationSnapshot, ListGroupConversationsRequest,
};
use common::infra::grpc::grpc_msg_friend::msg_friend_service::{
    friend_msg_service_client::FriendMsgServiceClient, BroadcastProfileUpdatesReq,
    FriendConversationSnapshot, GetFriendRequestRequest, GetFriendRequestResponse,
    ListFriendConversationsRequest, ListUserFriendMessagesRequest,
};
use common::infra::grpc::grpc_msg_system::msg_system_service::{
    system_msg_service_client::SystemMsgServiceClient, QuerySystemMessagesRequest,
};
use common::infra::grpc::message::{
    self as msgpb, friend_business_content::Action as FriendAction, group_business_content::Action,
    message_content::Content as MessageContentKind, ChatScene, DeliveryOptions, DomainMessage,
    FriendBusinessContent, GroupBusinessContent, MessageContent, MsgCategory,
    SystemBusinessContent, SystemBusinessType,
};
use common::infra::grpc::GrpcClientManager;
use common::support::node::{NodeType, NodeUtil};
use common::support::util::common_utils::build_snow_id;
use common::support::util::common_utils::hash_index;
use common::support::util::date_util::now;
use once_cell::sync::OnceCell;
use prost::Message as ProstMessage;
use serde_json::json;
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
static SYSTEM_MSG_MANAGER: OnceCell<
    GrpcClientManager<SystemMsgServiceClient<Channel>, TransportError>,
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

fn system_msg_manager(
) -> &'static GrpcClientManager<SystemMsgServiceClient<Channel>, TransportError> {
    SYSTEM_MSG_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            SystemMsgServiceClient::connect(endpoint).await
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

async fn connect_system_msg(addr: &str) -> Result<SystemMsgServiceClient<Channel>> {
    system_msg_manager()
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

/// 查询好友申请详情，供受理时引用原始 remark/nickname。
pub async fn get_friend_request(
    requester_uid: i64,
    request_id: u64,
) -> Result<GetFriendRequestResponse> {
    let addr = resolve_addr(NodeType::MsgFriend, requester_uid).await?;
    let mut client = connect_friend_msg(&addr).await?;
    let resp = client
        .get_friend_request(GetFriendRequestRequest { request_id })
        .await
        .map_err(|status| anyhow!("get friend request failed: {status}"))?
        .into_inner();
    Ok(resp)
}

pub async fn list_group_conversations(
    uid: i64,
    limit: u32,
    before_updated_at: Option<i64>,
    before_group_id: Option<i64>,
) -> Result<ConversationPage<GroupConversationSnapshot>> {
    let addr = resolve_addr(NodeType::MesGroup, uid).await?;
    let mut client = connect_group_msg(&addr).await?;

    let request = ListGroupConversationsRequest {
        uid,
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

/// 批量下发 ProfileUpdate 给好友。
pub async fn send_batch_profile_update_to_friends(
    sender_id: i64,
    friend_ids: Vec<i64>,
    contents: Vec<MessageContent>,
    ts_ms: i64,
    require_ack: bool,
) -> Result<()> {
    if friend_ids.is_empty() || contents.is_empty() {
        return Ok(());
    }
    let addr = resolve_addr(NodeType::MsgFriend, sender_id).await?;
    let mut client = connect_friend_msg(&addr).await?;
    let req = BroadcastProfileUpdatesReq {
        sender_id,
        friend_ids,
        contents,
        ts_ms,
        require_ack: Some(require_ack),
    };
    client
        .broadcast_profile_updates(req)
        .await
        .map_err(|status| anyhow!("broadcast_profile_updates failed: {status}"))?;
    Ok(())
}

/// 批量下发 ProfileUpdate 给群。
pub async fn send_batch_profile_update_to_groups(
    sender_id: i64,
    group_ids: Vec<i64>,
    contents: Vec<MessageContent>,
    ts_ms: i64,
    require_ack: bool,
) -> Result<()> {
    if group_ids.is_empty() || contents.is_empty() {
        return Ok(());
    }
    let addr = resolve_addr(NodeType::MesGroup, sender_id).await?;
    let mut client = connect_group_msg(&addr).await?;
    let req = BroadcastGroupProfileUpdatesReq {
        sender_id,
        group_ids,
        contents,
        ts_ms,
        require_ack: Some(require_ack),
    };
    client
        .broadcast_group_profile_updates(req)
        .await
        .map_err(|status| anyhow!("broadcast_group_profile_updates failed: {status}"))?;
    Ok(())
}

/// 提交好友申请，落到好友消息域。
pub async fn send_friend_request_message(
    from_uid: i64,
    to_uid: i64,
    reason: &str,
    remark: &str,
    nickname: &str,
) -> Result<()> {
    let addr = resolve_addr(NodeType::MsgFriend, from_uid).await?;
    let mut client = connect_friend_msg(&addr).await?;
    let req_id = build_snow_id() as u64;
    let ts = now();
    let friend_business = FriendBusinessContent {
        action: Some(FriendAction::Request(msgpb::FriendRequestPayload {
            request_id: req_id,
            from_uid,
            to_uid,
            reason: reason.to_string(),
            source: msgpb::FriendRequestSource::FrsUnknown as i32,
            created_at: ts,
            remark: remark.to_string(),
            nickname: nickname.to_string(),
        })),
    };
    let domain = DomainMessage {
        message_id: Some(req_id),
        sender_id: from_uid,
        receiver_id: to_uid,
        timestamp: ts,
        ts_ms: ts,
        delivery: Some(DeliveryOptions {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }),
        scene: ChatScene::Single as i32,
        category: MsgCategory::Friend as i32,
        contents: Vec::new(),
        friend_business: Some(friend_business),
        group_business: None,
        system_business: None,
    };
    client
        .handle_friend_message(domain)
        .await
        .map_err(|status| anyhow!("send friend request failed: {status}"))?;

    Ok(())
}

/// 处理好友申请的决策（同意/拒绝），落到好友消息域。
pub async fn send_friend_decision_message(
    approver_uid: i64,
    requester_uid: i64,
    payload: msgpb::FriendRequestDecisionPayload,
) -> Result<()> {
    let addr = resolve_addr(NodeType::MsgFriend, approver_uid).await?;
    let mut client = connect_friend_msg(&addr).await?;
    let ts = now();
    let friend_business = FriendBusinessContent {
        action: Some(FriendAction::Decision(payload)),
    };
    let domain = DomainMessage {
        message_id: Some(build_snow_id() as u64),
        sender_id: approver_uid,
        receiver_id: requester_uid,
        timestamp: ts,
        ts_ms: ts,
        delivery: Some(DeliveryOptions {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }),
        scene: ChatScene::Single as i32,
        category: MsgCategory::Friend as i32,
        contents: Vec::new(),
        friend_business: Some(friend_business),
        group_business: None,
        system_business: None,
    };
    client
        .handle_friend_message(domain)
        .await
        .map_err(|status| anyhow!("send friend decision failed: {status}"))?;

    Ok(())
}

/// 提交加群申请，落到群消息域。
pub async fn send_group_join_request_message(
    applicant_id: i64,
    group_id: i64,
    reason: &str,
) -> Result<()> {
    let addr = resolve_addr(NodeType::MesGroup, applicant_id).await?;
    let mut client = connect_group_msg(&addr).await?;
    let req_id = build_snow_id() as u64;
    let ts = now();
    let group_business = GroupBusinessContent {
        action: Some(Action::JoinRequest(msgpb::GroupJoinRequestPayload {
            request_id: req_id,
            group_id,
            applicant_id,
            reason: reason.to_string(),
            created_at: ts,
            via_member_ids: Vec::new(),
        })),
    };
    let domain = DomainMessage {
        message_id: Some(req_id),
        sender_id: applicant_id,
        receiver_id: group_id,
        timestamp: ts,
        ts_ms: ts,
        delivery: Some(DeliveryOptions {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }),
        scene: ChatScene::Group as i32,
        category: MsgCategory::Group as i32,
        contents: Vec::new(),
        friend_business: None,
        group_business: Some(group_business),
        system_business: None,
    };
    client
        .handle_group_message(domain)
        .await
        .map_err(|status| anyhow!("send group join request failed: {status}"))?;
    Ok(())
}

/// 直接成为好友时，写一条系统文本消息。
pub async fn send_friend_system_message(sender_id: i64, peer_id: i64, text: &str) -> Result<()> {
    if text.is_empty() {
        return Ok(());
    }
    let addr = resolve_addr(NodeType::MsgFriend, sender_id).await?;
    let mut client = connect_friend_msg(&addr).await?;
    let ts = now();
    let content = MessageContent {
        content: Some(MessageContentKind::Text(msgpb::TextContent {
            text: text.to_string(),
            ..Default::default()
        })),
    };
    let domain = DomainMessage {
        message_id: Some(build_snow_id() as u64),
        sender_id,
        receiver_id: peer_id,
        timestamp: ts,
        ts_ms: ts,
        delivery: Some(DeliveryOptions {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }),
        scene: ChatScene::Single as i32,
        category: MsgCategory::Friend as i32,
        contents: vec![content],
        friend_business: None,
        group_business: None,
        system_business: None,
    };
    client
        .handle_friend_message(domain)
        .await
        .map_err(|status| anyhow!("send friend system message failed: {status}"))?;
    Ok(())
}

/// 写入系统消息通道：按 receiver_id 分片到 msg_system 节点，并持久化。
pub async fn send_system_message(
    sender_id: i64,
    receiver_id: i64,
    contents: Vec<MessageContent>,
) -> Result<()> {
    send_system_payload(sender_id, receiver_id, contents, None).await
}

/// 发送好友添加成功的系统业务通知，各向双方各推一条。
pub async fn send_friend_add_system_business(from_uid: i64, to_uid: i64) -> Result<()> {
    let business = build_friend_add_business(from_uid, to_uid);
    send_system_payload(from_uid, to_uid, Vec::new(), Some(business.clone())).await?;
    send_system_payload(to_uid, from_uid, Vec::new(), Some(business)).await
}

fn build_friend_add_business(from_uid: i64, to_uid: i64) -> SystemBusinessContent {
    SystemBusinessContent {
        business_type: SystemBusinessType::SystemFriendAdd as i32,
        title: "system.friend.add".to_string(),
        detail: json!({
            "from_uid": from_uid,
            "to_uid": to_uid
        })
        .to_string(),
    }
}

async fn send_system_payload(
    sender_id: i64,
    receiver_id: i64,
    contents: Vec<MessageContent>,
    system_business: Option<SystemBusinessContent>,
) -> Result<()> {
    if contents.is_empty() && system_business.is_none() {
        return Ok(());
    }
    let addr = resolve_addr(NodeType::MsgSystem, receiver_id).await?;
    let mut client = connect_system_msg(&addr).await?;
    let ts = now();
    let domain = DomainMessage {
        message_id: Some(build_snow_id() as u64),
        sender_id,
        receiver_id,
        timestamp: ts,
        ts_ms: ts,
        delivery: Some(DeliveryOptions {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }),
        scene: ChatScene::Profile as i32,
        category: MsgCategory::System as i32,
        contents,
        friend_business: None,
        group_business: None,
        system_business,
    };

    client
        .handle_system_message(domain)
        .await
        .map_err(|status| anyhow!("send system message failed: {status}"))?;
    Ok(())
}

/// 拉取系统消息历史（按 msg_id/timestamp 倒序分页）。
pub async fn list_system_messages(
    uid: i64,
    before_message_id: Option<u64>,
    before_timestamp: Option<i64>,
    limit: u32,
) -> Result<msgpb::QueryMessagesResponse> {
    let addr = resolve_addr(NodeType::MsgSystem, uid).await?;
    let mut client = connect_system_msg(&addr).await?;
    let requested = if limit == 0 { 20 } else { limit };
    let req = QuerySystemMessagesRequest {
        uid,
        before_message_id,
        before_timestamp,
        limit: requested,
    };
    let resp = client
        .list_system_messages(req)
        .await
        .map_err(|status| anyhow!("list system messages failed: {status}"))?
        .into_inner();
    Ok(resp)
}

/// 聚合拉取好友消息（按时间 since_ms）；用于增量同步。
pub async fn list_user_friend_messages(
    uid: i64,
    since_ms: Option<i64>,
    limit: u32,
) -> Result<Vec<msgpb::Content>> {
    let addr = resolve_addr(NodeType::MsgFriend, uid).await?;
    let mut client = connect_friend_msg(&addr).await?;
    let req = ListUserFriendMessagesRequest {
        uid,
        since_timestamp: since_ms.unwrap_or(0),
        limit,
    };
    let resp = client
        .list_user_friend_messages(req)
        .await
        .map_err(|status| anyhow!("list user friend messages failed: {status}"))?
        .into_inner();
    Ok(resp.messages)
}

/// 拉取群消息近窗口后按时间过滤（粗略增量，同步大窗口）。
pub async fn list_group_messages(
    group_id: i64,
    since_ms: i64,
    limit: u32,
) -> Result<Vec<msgpb::Content>> {
    let addr = resolve_addr(NodeType::MesGroup, group_id).await?;
    let mut client = connect_group_msg(&addr).await?;
    let req = msgpb::QueryGroupMessagesRequest {
        group_id,
        before_message_id: None,
        before_timestamp: None,
        limit,
    };
    let resp = client
        .list_group_messages(req)
        .await
        .map_err(|status| anyhow!("list group messages failed: {status}"))?
        .into_inner();
    let msgs = resp
        .messages
        .into_iter()
        .filter(|m| m.timestamp > since_ms)
        .collect();
    Ok(msgs)
}

/// 将 protobuf Content 编码为 base64，便于 API JSON 返回。
pub fn encode_messages(msgs: Vec<msgpb::Content>) -> Vec<String> {
    msgs.into_iter()
        .filter_map(|m| {
            let mut buf = Vec::new();
            m.encode(&mut buf).ok()?;
            Some(BASE64.encode(buf))
        })
        .collect()
}

/// 直接入群时，写一条群系统文本消息。
pub async fn send_group_system_message(operator_id: i64, group_id: i64, text: &str) -> Result<()> {
    if text.is_empty() {
        return Ok(());
    }
    let addr = resolve_addr(NodeType::MesGroup, operator_id).await?;
    let mut client = connect_group_msg(&addr).await?;
    let ts = now();
    let content = MessageContent {
        content: Some(MessageContentKind::Text(msgpb::TextContent {
            text: text.to_string(),
            ..Default::default()
        })),
    };
    let domain = DomainMessage {
        message_id: Some(build_snow_id() as u64),
        sender_id: operator_id,
        receiver_id: group_id,
        timestamp: ts,
        ts_ms: ts,
        delivery: Some(DeliveryOptions {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }),
        scene: ChatScene::Group as i32,
        category: MsgCategory::Group as i32,
        contents: vec![content],
        friend_business: None,
        group_business: None,
        system_business: None,
    };
    client
        .handle_group_message(domain)
        .await
        .map_err(|status| anyhow!("send group system message failed: {status}"))?;
    Ok(())
}

pub fn build_profile_content(
    event_type: msgpb::profile_event_content::ProfileEventType,
    new_value: String,
    version: Option<i64>,
    updated_at: Option<i64>,
) -> MessageContent {
    let mut metadata = std::collections::HashMap::new();
    if let Some(v) = version {
        metadata.insert("version".to_string(), v.to_string());
    }
    if let Some(ts) = updated_at {
        metadata.insert("updated_at".to_string(), ts.to_string());
    }
    MessageContent {
        content: Some(MessageContentKind::ProfileUpdate(
            msgpb::ProfileEventContent {
                event_type: event_type as i32,
                new_value,
                metadata,
            },
        )),
    }
}
