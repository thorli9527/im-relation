use dashmap::DashMap;
use once_cell::sync::OnceCell;
use std::sync::Arc;

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
