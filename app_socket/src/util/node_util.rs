use dashmap::DashMap;
use once_cell::sync::OnceCell;
use std::{cmp::Ordering, sync::Arc};
use crate::grpc_arb::arb_server::{NodeInfo, NodeType};
use once_cell::sync::OnceCell as _OnceCell;
use parking_lot::RwLock;
use std::sync::Arc as _Arc;
use common::config::AppConfig;

impl Eq for NodeInfo {}
impl Ord for NodeInfo {
    fn cmp(&self, other: &Self) -> Ordering { self.node_addr.cmp(&other.node_addr) }
}
impl PartialOrd for NodeInfo { fn partial_cmp(&self, other: &Self) -> Option<Ordering> { Some(self.cmp(other)) } }

#[derive(Debug, Default, Clone)]
pub struct SortedVec<T: Ord>(Vec<T>);
impl<T: Ord> SortedVec<T> {
    pub fn insert(&mut self, item: T) { let idx = self.0.binary_search(&item).unwrap_or_else(|e| e); self.0.insert(idx, item); }
    pub fn extend_unsorted<I: IntoIterator<Item = T>>(&mut self, it: I) { self.0.extend(it); self.0.sort(); }
    pub fn replace_sorted<I: IntoIterator<Item = T>>(&mut self, it: I) { self.0 = it.into_iter().collect(); self.0.sort(); }
    pub fn as_slice(&self) -> &[T] { &self.0 }
}

#[derive(Debug)]
pub struct NodeUtil { pub node_address_list: DashMap<NodeType, SortedVec<NodeInfo>> }
impl NodeUtil {
    pub fn new() -> Self { Self { node_address_list: DashMap::new() } }
    pub fn get() -> Arc<Self> { NODE_UTIL_INSTANCE.get_or_init(|| Arc::new(Self::new())).clone() }
    pub fn insert_node(&self, node_type: NodeType, node: NodeInfo) { self.node_address_list.entry(node_type).or_default().insert(node); }
    pub fn reset_list(&self, node_type: NodeType, vec: Vec<NodeInfo>) { self.node_address_list.entry(node_type).or_default().replace_sorted(vec); }
    pub fn get_list(&self, node_type: NodeType) -> Vec<NodeInfo> { self.node_address_list.get(&node_type).map(|sv| sv.as_slice().to_vec()).unwrap_or_default() }
}

static NODE_UTIL_INSTANCE: OnceCell<Arc<NodeUtil>> = OnceCell::new();

// --------------------
// Arb 地址解析与节点查询（迁移自 grpc/mod.rs）
// --------------------

fn resolve_arb_addr() -> String {
    if let Ok(v) = std::env::var("ARB_SERVER_ADDR") { return v; }
    if let Some(addr) = AppConfig::get().grpc.as_ref().and_then(|g| g.client_addr.clone()) { return addr; }
    "127.0.0.1:9001".to_string()
}

pub async fn fetch_msg_friend_addr() -> Option<String> {
    use crate::grpc_arb::client::connect_server;
    use crate::grpc_arb::arb_server::{QueryNodeReq, NodeType};
    let mut cli = match connect_server(&resolve_arb_addr()).await { Ok(c)=>c, Err(_)=> return None };
    let req = QueryNodeReq { node_type: NodeType::MsgFriend as i32 };
    match cli.list_all_nodes(req).await {
        Ok(resp) => {
            let nodes = resp.into_inner().nodes;
            if !nodes.is_empty() { NodeUtil::get().reset_list(NodeType::MsgFriend, nodes.clone()); }
            nodes.into_iter().map(|n| n.node_addr).next()
        },
        Err(_) => None,
    }
}

pub async fn fetch_node_addr(node_type: NodeType) -> Option<String> {
    use crate::grpc_arb::client::connect_server;
    use crate::grpc_arb::arb_server::QueryNodeReq;
    let mut cli = match connect_server(&resolve_arb_addr()).await { Ok(c)=>c, Err(_)=> return None };
    let req = QueryNodeReq { node_type: node_type as i32 };
    match cli.list_all_nodes(req).await {
        Ok(resp) => {
            let nodes = resp.into_inner().nodes;
            if !nodes.is_empty() { NodeUtil::get().reset_list(node_type, nodes.clone()); }
            nodes.into_iter().map(|n| n.node_addr).next()
        },
        Err(_) => None,
    }
}

pub async fn resolve_hot_friend_addr() -> String {
    if let Ok(v) = std::env::var("HOT_FRIEND_ADDR") { return v; }
    if let Some(a) = fetch_node_addr(NodeType::MsgFriend).await { return a; }
    "127.0.0.1:8081".to_string()
}

// 简易缓存（保留接口，当前未使用）
static MSG_FRIEND_CACHE: _OnceCell<_Arc<RwLock<Option<String>>>> = _OnceCell::new();
fn cache_cell() -> _Arc<RwLock<Option<String>>> { MSG_FRIEND_CACHE.get_or_init(|| _Arc::new(RwLock::new(None))).clone() }
pub fn set_msg_friend_cache(addr: String) { let c = cache_cell(); *c.write() = Some(addr); }
pub fn get_msg_friend_cache() -> Option<String> { cache_cell().read().clone() }
