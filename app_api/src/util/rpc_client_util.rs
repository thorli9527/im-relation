use ahash::{HashMap, HashMapExt};
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Result};
use arc_swap::ArcSwap;
use once_cell::sync::OnceCell;

use tonic::transport::{Channel, Endpoint};
use crate::grpc::arb_server::NodeType;
use crate::util::node_util::NodeUtil;

#[derive(Debug)]
pub struct SocketRpcClientUtil {
    // 读路径无锁：快照式读取；写时整体原子替换
    clients: ArcSwap<HashMap<String, Channel>>,
}

impl SocketRpcClientUtil {
    /// 根据 NodeUtil 构建初始表
    async fn new() -> Self {
        let node_util = NodeUtil::get();
        let list = node_util.get_list(NodeType::SocketNode);

        let mut map = HashMap::with_capacity(list.len());
        for node in list.iter() {
            let addr = format!("http://{}", node.node_addr);
            if let Ok(ch) = Self::build_endpoint(&addr).and_then(|ep| Ok(ep.connect_lazy())) {
                map.insert(addr, ch);
            } else {
                eprintln!("[SocketRpcClientUtil] endpoint build failed for {}", node.node_addr);
            }
        }

        if map.is_empty() {
            eprintln!("[SocketRpcClientUtil] WARN: no socket nodes configured at init");
        }

        Self { clients: ArcSwap::from_pointee(map) }
    }

    #[inline]
    fn build_endpoint(addr: &str) -> Result<Endpoint> {
        let ep = Endpoint::from_shared(addr.to_string())
            .map_err(|e| anyhow!("invalid uri {}: {}", addr, e))?
            // TCP
            .tcp_nodelay(true)
            .tcp_keepalive(Some(Duration::from_secs(30)))
            // HTTP/2 keep-alive
            .http2_keep_alive_interval(Duration::from_secs(10))
            .keep_alive_timeout(Duration::from_secs(20))
            .keep_alive_while_idle(true)
            // 调优
            .initial_stream_window_size(Some(1 << 20))
            .initial_connection_window_size(Some(1 << 24))
            .concurrency_limit(256);
        Ok(ep)
    }

    /// 单例：需要先 `init().await?`
    pub fn get() -> Arc<Self> {
        INSTANCE.get().expect("SocketRpcClientUtil not inited").clone()
    }

    pub async fn init()  {
        INSTANCE
            .set(Arc::new(Self::new().await))
            .expect("SocketRpcClientUtil already inited");
    }

    /// 按地址获取“临时 client”（同步、无锁）
    pub fn client_for_addr(&self, addr: &str) -> Option<SocketRpcServiceClient<Channel>> {
        let map = self.clients.load();
        map.get(addr).cloned().map(SocketRpcServiceClient::new)
    }

    /// 封装调用：内部拿 client 再执行 RPC（避免误用）
    pub async fn with_client<F, Fut, T, E>(&self, addr: &str, f: F) -> std::result::Result<T, E>
    where
        F: FnOnce(&mut SocketRpcServiceClient<Channel>) -> Fut,
        Fut: std::future::Future<Output = std::result::Result<T, E>>,
    {
        let mut client = self
            .client_for_addr(addr)
            .expect("channel not found");
        f(&mut client).await
    }

    /// 原子对齐：重建新表并一次性替换（读路径无阻塞）
    pub async fn rebuild(&self) {
        let desired_addrs: Vec<String> = NodeUtil::get()
            .get_list(NodeType::SocketNode)
            .into_iter()
            .map(|n| format!("http://{}", n.node_addr))
            .collect();

        let current = self.clients.load();
        let mut new_map = HashMap::with_capacity(desired_addrs.len());

        for addr in desired_addrs {
            if let Some(ch) = current.get(&addr) {
                // 复用旧 Channel
                new_map.insert(addr.clone(), ch.clone());
            } else if let Ok(ch) = Self::build_endpoint(&addr).and_then(|ep| Ok(ep.connect_lazy())) {
                new_map.insert(addr.clone(), ch);
                eprintln!("[SocketRpcClientUtil] added channel: {}", addr);
            } else {
                eprintln!("[SocketRpcClientUtil] add failed: {}", addr);
            }
        }

        // 原子替换
        self.clients.store(Arc::new(new_map));
    }

    /// 按需确保某地址存在（幂等、无锁）
    pub fn ensure_addr(&self, addr: &str) -> Result<()> {
        // 快路径：已有直接返回
        if self.clients.load().contains_key(addr) {
            return Ok(());
        }
        // CAS/RCU：基于旧快照构建新表
        let ch = Self::build_endpoint(addr)?.connect_lazy();
        self.clients.rcu(|old| {
            if old.contains_key(addr) {
                return Arc::clone(old);
            }
            let mut cloned = (**old).clone();
            cloned.insert(addr.to_string(), ch.clone());
            Arc::new(cloned)
        });
        Ok(())
    }

    /// 列出所有地址（同步）
    pub fn all_addrs(&self) -> Vec<String> {
        self.clients.load().keys().cloned().collect()
    }
}

static INSTANCE: OnceCell<Arc<SocketRpcClientUtil>> = OnceCell::new();
