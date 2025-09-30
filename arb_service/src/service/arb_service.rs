use std::collections::HashSet;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use dashmap::DashMap;
use log::{info, warn};
use reqwest::Client;
use serde_json::json;
use tokio::time::{sleep, Duration};

use common::arb::{
    BaseRequest, BytesBlob, CommonResp, NodeInfo, NodeInfoList, NodeType, QueryNodeReq,
    RegisterRequest, SyncDataType, ACCESS_HEADER,
};
use common::errors::AppError;

/// 仲裁服务的核心实现，负责维护节点信息、处理 HTTP 请求并执行同步广播。
#[derive(Clone)]
pub struct ArbService {
    /// 以节点类型分桶的嵌套 DashMap，内层以地址为键存储节点信息。
    node_list: Arc<DashMap<NodeType, DashMap<String, NodeInfo>>>,
    /// 复用的 HTTP 客户端，用于 fan-out 同步消息。
    http_client: Client,
    /// 与其他服务约定的访问令牌，缺省情况下关闭校验。
    access_token: Option<String>,
}

impl ArbService {
    /// 节点失效阈值（毫秒），超过该值未更新则视为离线。
    pub const NODE_TIMEOUT_MS: u64 = 60_000;
    /// 定时任务执行间隔，控制失效扫描的频率。
    const CLEANUP_INTERVAL: Duration = Duration::from_secs(30);

    /// 创建服务实例并启动后台的失效节点巡检任务。
    pub fn new(access_token: Option<String>) -> Self {
        // service 为即将返回的 ArbService 实例，初始化核心字段。
        let service = Self {
            // node_list 以空 DashMap 开始，后续动态插入节点。
            node_list: Arc::new(DashMap::new()),
            // http_client 复用一个 reqwest 客户端，降低创建成本。
            http_client: Client::new(),
            // access_token 透传外部配置，用于后续 HTTP 鉴权。
            access_token,
        };
        // 启动后台定时任务，负责剔除超时节点。
        service.spawn_stale_monitor();
        service
    }

    /// 注册新节点；若为 Socket 节点，会在成功后通过 HTTP 广播给其他节点。
    pub async fn register_node(&self, req: RegisterRequest) -> Result<CommonResp, AppError> {
        // node_type 表示当前请求对应的节点类型，后续用于索引桶。
        let node_type = Self::parse_node_type(req.node_type)?;
        // now 记录注册时刻的时间戳，用于初始化 last_update_time。
        let now = Self::current_timestamp()?;

        // 获取该类型节点的映射，若不存在则创建；DashMap 支持并发写入。
        // bucket 是当前类型对应的节点表，DashMap::entry 能保证并发安全。
        let bucket = self.node_list.entry(node_type).or_insert_with(DashMap::new);

        // 地址唯一，如果同地址重复注册直接返回冲突错误。
        if bucket.value().contains_key(&req.node_addr) {
            return Err(AppError::Conflict);
        }

        // 构建节点记录，写入最后更新时间与 Kafka 地址等信息。
        let new_node = NodeInfo {
            node_addr: req.node_addr.clone(),
            last_update_time: now,
            node_type: req.node_type,
            pub_node_addr: if req.pub_node_addr.is_empty() {
                None
            } else {
                Some(req.pub_node_addr.clone())
            },
            kafka_addr: req.kafka_addr.clone(),
        };

        bucket
            .value()
            .insert(req.node_addr.clone(), new_node.clone());

        //需要广播通知给其它节点。
        self.broadcast_sync(req.node_addr.as_str(), new_node, SyncDataType::SocketAdd)
            .await;
        warn!("节点 {} 注册成功", req.node_addr);
        Ok(CommonResp {
            success: true,
            message: format!("节点 {} 注册成功", req.node_addr),
        })
    }

    /// 返回指定类型节点的快照列表，供外部服务查询路由信息。
    pub async fn list_all_nodes(&self, req: QueryNodeReq) -> Result<NodeInfoList, AppError> {
        // node_type 表示查询目标类型，合法性需要先解析。
        let node_type = Self::parse_node_type(req.node_type)?;
        // nodes 汇总当前类型下所有节点的快照结果。
        let nodes = self
            .node_list
            .get(&node_type)
            .map(|bucket| {
                // 将 DashMap 内部的节点值复制出来，形成稳定快照。
                bucket
                    .value()
                    .iter()
                    .map(|node_entry| node_entry.value().clone())
                    .collect()
            })
            .unwrap_or_default();
        Ok(NodeInfoList { nodes })
    }

    /// 节点主动退出：移除记录并在必要时广播删除消息。
    pub async fn graceful_leave(&self, req: NodeInfo) -> Result<CommonResp, AppError> {
        // node_type 指示待下线节点的类别。
        let node_type = Self::parse_node_type(req.node_type)?;
        // bucket 是共享引用，用于安全地读取并修改节点表。
        let bucket = match self.node_list.get(&node_type) {
            Some(entry) => entry,
            None => return Err(AppError::NotFound),
        };

        // 从映射中删除指定地址的节点，若不存在直接返回未找到。
        let removed_node = match bucket.value().remove(&req.node_addr) {
            Some((_addr, node)) => node,
            None => return Err(AppError::NotFound),
        };
        // empty_after_remove 标记该类型是否已无节点，用于后续清理。
        let empty_after_remove = bucket.value().is_empty();
        drop(bucket);

        // 若某类型下已无节点，彻底移除该分桶，避免存储空映射。
        if empty_after_remove {
            self.node_list
                .remove_if(&node_type, |_, bucket| bucket.is_empty());
        }

        // Socket 节点离线时需要通知其他节点做本地下线处理。
        if node_type == NodeType::SocketNode {
            self.broadcast_sync(
                removed_node.node_addr.as_str(),
                removed_node.clone(),
                SyncDataType::SocketDel,
            )
            .await;
        }

        Ok(CommonResp {
            success: true,
            message: format!("节点 {} 已移除", req.node_addr),
        })
    }

    /// 更新节点分片状态，仅刷新最后活跃时间。
    pub async fn update_shard_state(&self, req: BaseRequest) -> Result<CommonResp, AppError> {
        // node_type 指定请求目标；若非法会直接报错。
        let node_type = Self::parse_node_type(req.node_type)?;
        // now 代表本次更新的时间戳。
        let now = Self::current_timestamp()?;
        if let Some(bucket) = self.node_list.get(&node_type) {
            // DashMap::get 返回只读引用；get_mut 才能更新 last_update_time。
            if let Some(mut node) = bucket.value().get_mut(&req.node_addr) {
                node.last_update_time = now;
                return Ok(CommonResp {
                    success: true,
                    message: format!("节点 {} 分片状态已更新", req.node_addr),
                });
            }
        }
        Err(AppError::NotFound)
    }

    /// 处理上游心跳请求，刷新对应节点的活跃时间。
    pub async fn heartbeat(&self, req: BaseRequest) -> Result<CommonResp, AppError> {
        // node_type 用于定位心跳来源在哪个桶内。
        let node_type = Self::parse_node_type(req.node_type)?;
        // now 记录心跳收到时的时间戳。
        let now = Self::current_timestamp()?;

        if let Some(bucket) = self.node_list.get(&node_type) {
            // 心跳逻辑与分片更新一致，仅刷新时间。
            if let Some(mut node) = bucket.value().get_mut(&req.node_addr) {
                node.last_update_time = now;
                return Ok(CommonResp {
                    success: true,
                    message: format!("节点 {} 心跳成功", req.node_addr),
                });
            }
        }
        Err(AppError::NotFound)
    }

    /// 将整型的节点类型转换为枚举，并对非法输入返回校验错误。
    fn parse_node_type(node_type: i32) -> Result<NodeType, AppError> {
        NodeType::try_from(node_type)
            .map_err(|_| AppError::Validation(format!("invalid node type: {}", node_type)))
    }

    /// 返回当前毫秒时间戳，统一处理时间相关错误。
    fn current_timestamp() -> Result<u64, AppError> {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|e| AppError::Internal(e.to_string()))
            .and_then(|dur| {
                // as_millis() 返回 u128，需要转换成 u64；若溢出则视为内部错误。
                dur.as_millis()
                    .try_into()
                    .map_err(|_| AppError::Internal("timestamp overflow".to_string()))
            })
    }

    /// 将节点信息序列化为 `BytesBlob` 并触发异步广播逻辑。
    async fn broadcast_sync(&self, exclude_addr: &str, node: NodeInfo, sync_type: SyncDataType) {
        let blob = match serde_json::to_vec(&node) {
            Ok(data) => BytesBlob {
                // data 是节点信息的 JSON 序列化结果。
                data,
                // sync_type 标识当前广播属于新增还是删除。
                sync_type: sync_type.into(),
            },
            Err(err) => {
                // 序列化失败直接记录日志并退出，不再继续广播。
                warn!("serialize node info failed: {}", err);
                return;
            }
        };
        self.sync_to_nodes(exclude_addr, blob).await;
    }

    /// 遍历全量节点集合，针对每个目标节点异步发送同步请求。
    async fn sync_to_nodes(&self, exclude_addr: &str, blob: BytesBlob) {
        let nodes: Vec<String> = self
            .node_list
            .iter()
            .flat_map(|entry| {
                // entry 表示当前遍历到的节点类型桶。
                entry
                    .value()
                    .iter()
                    .filter_map(|node_entry| {
                        // addr 是节点的访问地址，用于拼接同步 URL。
                        let addr = node_entry.key();
                        if addr == exclude_addr {
                            // 排除触发广播的原节点，避免自我回传。
                            None
                        } else {
                            Some(addr.clone())
                        }
                    })
                    .collect::<Vec<_>>()
            })
            .collect();

        // token 是可选的访问令牌，后续写入 HTTP header。
        let token = self.access_token.clone();
        for addr in nodes {
            // 每个目标节点独立 spawn 一个任务，避免串行等待。
            // client 克隆 reqwest Client，确保生命周期独立。
            let client = self.http_client.clone();
            // blob 是待发送的数据载荷副本。
            let blob = blob.clone();
            // token_clone 保存访问令牌，供异步任务使用。
            let token_clone = token.clone();
            tokio::spawn(async move {
                // url 为目标节点的同步接口地址，自动补全协议头。
                let url = if addr.starts_with("http://") || addr.starts_with("https://") {
                    format!("{}/arb/server/sync", addr)
                } else {
                    format!("http://{}/arb/server/sync", addr)
                };

                let mut request = client.post(&url).json(&blob);
                if let Some(token) = &token_clone {
                    // 若配置了令牌，则在 header 中附带校验信息。
                    request = request.header(ACCESS_HEADER, token);
                }

                if let Err(err) = request.send().await {
                    // 网络请求失败时仅记录警告，等待后续心跳重新同步。
                    warn!("sync to node {} failed: {}", addr, err);
                }
            });
        }
    }

    /// 启动循环任务，固定间隔触发失效节点检查。
    fn spawn_stale_monitor(&self) {
        let this = self.clone();
        tokio::spawn(async move {
            loop {
                sleep(Self::CLEANUP_INTERVAL).await;
                this.cleanup_stale_nodes().await;
            }
        });
    }

    /// 清理超时节点，并为 Socket 节点推送删除广播。
    async fn cleanup_stale_nodes(&self) {
        let now = match Self::current_timestamp() {
            Ok(ts) => ts,
            Err(err) => {
                // 理论上不会失败，若失败说明系统时间异常，直接跳过本轮。
                warn!("cleanup: timestamp error: {}", err);
                return;
            }
        };

        // 先收集超时节点，避免在遍历 DashMap 时直接删除导致迭代冲突。
        // expired_socket_nodes 收集需要广播删除的 Socket 节点。
        let mut expired_socket_nodes = Vec::new();
        // removals 存储所有待删除的节点及其类型，用于统一处理。
        let mut removals: Vec<(NodeType, NodeInfo)> = Vec::new();

        for entry in self.node_list.iter() {
            // node_type 为当前遍历的节点类型。
            let node_type = *entry.key();
            for node_entry in entry.value().iter() {
                // node 是节点详细信息的共享引用。
                let node = node_entry.value();
                let expired = now.saturating_sub(node.last_update_time) > Self::NODE_TIMEOUT_MS;
                if expired {
                    // 记录节点所属类型与详情，后续统一处理。
                    removals.push((node_type, node.clone()));
                }
            }
        }

        // 记录因清理而变为空的节点类型，最后批量移除。
        let mut empty_types = HashSet::new();

        for (node_type, node) in &removals {
            if let Some(bucket) = self.node_list.get(node_type) {
                bucket.value().remove(&node.node_addr);
                let empty = bucket.value().is_empty();
                drop(bucket);
                if empty {
                    // empty 标记为 true 说明该类型已无节点。
                    empty_types.insert(*node_type);
                }
            }

            match NodeType::try_from(node.node_type) {
                Ok(NodeType::SocketNode) => expired_socket_nodes.push(node.clone()),
                Ok(_) => {}
                Err(err) => warn!("cleanup: invalid node type: {}", err),
            }
        }

        for kind in empty_types {
            // 仅当桶仍为空时移除，避免并发写入导致意外删除。
            self.node_list
                .remove_if(&kind, |_, bucket| bucket.is_empty());
        }

        for node in expired_socket_nodes {
            // 对超时的 Socket 节点发送删除广播，通知各节点更新本地缓存。
            info!("cleanup: stale socket node removed addr={}", node.node_addr);
            // addr 记录当前广播目标的节点地址。
            let addr = node.node_addr.clone();
            self.broadcast_sync(&addr, node, SyncDataType::SocketDel)
                .await;
        }
    }

    /// 输出节点数量统计，便于调试与监控调用。
    pub fn stats(&self) -> serde_json::Value {
        // summary 汇总每种节点类型的数量信息。
        let mut summary = Vec::new();
        for entry in self.node_list.iter() {
            summary.push(json!({
                "nodeType": i32::from(*entry.key()),
                "count": entry.value().len(),
            }));
        }
        json!({
            "summary": summary,
        })
    }
}
