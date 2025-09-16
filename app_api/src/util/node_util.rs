use dashmap::DashMap;
use once_cell::sync::OnceCell;
use std::{cmp::Ordering, sync::Arc};
use crate::grpc_arb::arb_server::{NodeInfo, NodeType};

/// 仅用 node_addr 做比较（升序）；其它字段忽略
impl Eq for NodeInfo {}

impl Ord for NodeInfo {
    fn cmp(&self, other: &Self) -> Ordering {
        self.node_addr.cmp(&other.node_addr)
    }
}
impl PartialOrd for NodeInfo {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

/// 有序 Vec：按 Ord 进行二分插入，保持有序
#[derive(Debug, Default, Clone)]
pub struct SortedVec<T: Ord>(Vec<T>);

impl<T: Ord> SortedVec<T> {
    /// 二分插入，保持有序
    pub fn insert(&mut self, item: T) {
        let idx = self.0.binary_search(&item).unwrap_or_else(|e| e);
        self.0.insert(idx, item);
    }
    /// 批量追加（末尾再统一排序一次，提升吞吐）
    pub fn extend_unsorted<I: IntoIterator<Item = T>>(&mut self, it: I) {
        self.0.extend(it);
        self.0.sort(); // T: Ord（这里就是按 node_addr）
    }
    /// 覆盖为给定列表并排序
    pub fn replace_sorted<I: IntoIterator<Item = T>>(&mut self, it: I) {
        self.0 = it.into_iter().collect();
        self.0.sort();
    }
    pub fn as_slice(&self) -> &[T] {
        &self.0
    }
    pub fn into_vec(self) -> Vec<T> {
        self.0
    }
}

#[derive(Debug)]
pub struct NodeUtil {
    /// 每个 NodeType 映射到一个“始终按 node_addr 升序”的列表
    pub node_address_list: DashMap<NodeType, SortedVec<NodeInfo>>,
}
impl NodeUtil {
    pub fn new() -> Self {
        Self { node_address_list: DashMap::new() }
    }

    /// 幂等初始化：手动预热（可选）
    pub fn init() {
        // 如果已初始化，set 会返回 Err，忽略即可
        let _ = NODE_UTIL_INSTANCE.set(Arc::new(Self::new()));
    }

    /// 懒加载获取：如果未初始化会自动创建
    pub fn get() -> Arc<Self> {
        NODE_UTIL_INSTANCE
            .get_or_init(|| Arc::new(Self::new()))
            .clone()
    }

    // 可选：如果你想避免克隆 Arc，直接拿 &'static Arc<Self>
    pub fn get_ref() -> &'static Arc<Self> {
        NODE_UTIL_INSTANCE.get_or_init(|| Arc::new(Self::new()))
    }

    pub fn insert_node(&self, node_type: NodeType, node: NodeInfo) {
        self.node_address_list.entry(node_type).or_default().insert(node);
    }

    pub fn reset_list(&self, node_type: NodeType, vec: Vec<NodeInfo>) {
        self.node_address_list.entry(node_type).or_default().replace_sorted(vec);
    }

    pub fn push_list(&self, node_type: NodeType, vec: Vec<NodeInfo>) {
        self.node_address_list.entry(node_type).or_default().extend_unsorted(vec);
    }

    pub fn remove(&self, node_type: NodeType, node: &NodeInfo) {
        if let Some(mut entry) = self.node_address_list.get_mut(&node_type) {
            let v = &mut entry.0;
            if let Ok(pos) = v.binary_search(node) {
                v.remove(pos);
            } else {
                v.retain(|x| x.node_addr != node.node_addr);
            }
        }
    }

    pub fn get_list(&self, node_type: NodeType) -> Vec<NodeInfo> {
        self.node_address_list
            .get(&node_type)
            .map(|sv| sv.as_slice().to_vec())
            .unwrap_or_default()
    }
}


/// 全局单例
static NODE_UTIL_INSTANCE: OnceCell<Arc<NodeUtil>> = OnceCell::new();
