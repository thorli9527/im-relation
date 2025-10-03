use serde::{Deserialize, Serialize};
use std::fmt;
use utoipa::ToSchema;

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct CommonResp {
    pub success: bool,
    pub message: String,
}

impl CommonResp {
    pub fn ok() -> Self {
        Self {
            success: true,
            message: "ok".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct BaseRequest {
    pub node_addr: String,
    pub node_type: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct RegisterRequest {
    pub server_addr: String,
    pub node_type: i32,
    pub pub_node_addr: String,
    #[serde(default)]
    pub grpc_addr: Option<String>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct QueryNodeReq {
    pub node_type: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct NodeInfo {
    pub node_addr: String,
    pub last_update_time: u64,
    pub node_type: i32,
    #[serde(default)]
    pub pub_node_addr: Option<String>,
    pub kafka_addr: Option<String>,
    #[serde(default)]
    pub grpc_addr: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct NodeInfoList {
    pub nodes: Vec<NodeInfo>,
}

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SyncPayload {
    pub node: NodeInfo,
    pub sync_type: i32,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, ToSchema, PartialEq, Eq, Hash)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
#[repr(i32)]
pub enum SyncDataType {
    SocketAdd = 0,
    SocketDel = 1,
}

impl TryFrom<i32> for SyncDataType {
    type Error = &'static str;

    fn try_from(value: i32) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(SyncDataType::SocketAdd),
            1 => Ok(SyncDataType::SocketDel),
            _ => Err("invalid sync data type"),
        }
    }
}

impl From<SyncDataType> for i32 {
    fn from(value: SyncDataType) -> Self {
        value as i32
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, ToSchema, PartialEq, Eq, Hash)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
#[repr(i32)]
pub enum NodeType {
    GroupNode = 0,
    SocketNode = 1,
    SocketGateway = 2,
    OnlineNode = 3,
    MsgGateway = 4,
    MesGroup = 5,
    MsgFriend = 6,
    ApiNode = 7,
    FriendNode = 8,
}

impl TryFrom<i32> for NodeType {
    type Error = &'static str;

    fn try_from(value: i32) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(NodeType::GroupNode),
            1 => Ok(NodeType::SocketNode),
            2 => Ok(NodeType::SocketGateway),
            3 => Ok(NodeType::OnlineNode),
            4 => Ok(NodeType::MsgGateway),
            5 => Ok(NodeType::MesGroup),
            6 => Ok(NodeType::MsgFriend),
            7 => Ok(NodeType::ApiNode),
            8 => Ok(NodeType::FriendNode),
            _ => Err("invalid node type"),
        }
    }
}

impl From<NodeType> for i32 {
    fn from(value: NodeType) -> Self {
        value as i32
    }
}

impl fmt::Display for NodeType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            NodeType::GroupNode => "GROUP_NODE",
            NodeType::SocketNode => "SOCKET_NODE",
            NodeType::SocketGateway => "SOCKET_GATEWAY",
            NodeType::OnlineNode => "ONLINE_NODE",
            NodeType::MsgGateway => "MSG_GATEWAY",
            NodeType::MesGroup => "MES_GROUP",
            NodeType::MsgFriend => "MSG_FRIEND",
            NodeType::ApiNode => "API_NODE",
            NodeType::FriendNode => "FRIEND_NODE",
        };
        f.write_str(name)
    }
}
