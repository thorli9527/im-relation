use dashmap::DashMap;
use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};
use std::fmt;
use std::sync::Arc;
use utoipa::ToSchema;

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

#[derive(Debug, Default, Clone)]
struct SortedVec(Vec<String>);

impl SortedVec {
    fn insert(&mut self, addr: String) {
        let idx = self.0.binary_search(&addr).unwrap_or_else(|i| i);
        self.0.insert(idx, addr);
    }

    fn replace(&mut self, addrs: Vec<String>) {
        let mut data = addrs;
        data.sort();
        self.0 = data;
    }

    fn extend(&mut self, addrs: impl IntoIterator<Item = String>) {
        self.0.extend(addrs);
        self.0.sort();
    }

    fn as_vec(&self) -> Vec<String> {
        self.0.clone()
    }
}

pub type NodeKind = i32;

#[derive(Debug)]
pub struct NodeUtil {
    inner: DashMap<NodeKind, SortedVec>,
}

static INSTANCE: OnceCell<Arc<NodeUtil>> = OnceCell::new();

impl NodeUtil {
    pub fn get() -> Arc<Self> {
        INSTANCE
            .get_or_init(|| {
                Arc::new(Self {
                    inner: DashMap::new(),
                })
            })
            .clone()
    }

    pub fn insert_node(&self, kind: NodeKind, addr: impl Into<String>) {
        self.inner.entry(kind).or_default().insert(addr.into());
    }

    pub fn reset_list(&self, kind: NodeKind, addrs: Vec<String>) {
        self.inner.entry(kind).or_default().replace(addrs);
    }

    pub fn extend_list(&self, kind: NodeKind, addrs: impl IntoIterator<Item = String>) {
        self.inner.entry(kind).or_default().extend(addrs);
    }

    pub fn get_list(&self, kind: NodeKind) -> Vec<String> {
        self.inner
            .get(&kind)
            .map(|v| v.as_vec())
            .unwrap_or_default()
    }
}
