use async_trait::async_trait;
use dashmap::DashMap;
use serde::Serialize;
use std::convert::TryFrom;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tokio::sync::mpsc;
use tokio::time::{timeout, Duration};
use tonic::{Request, Response, Status};
use tonic::transport::Uri;

use crate::grpc_arb::arb_server::arb_server_rpc_service_server::ArbServerRpcService;
use crate::grpc_arb::arb_server::{
    BaseRequest, CommonResp, NodeInfo, NodeInfoList, QueryNodeReq, RegisterRequest,
    NodeType, BytesBlob, SyncDataType,
};
use crate::grpc_arb::client::connect_client;

/// 仲裁服务核心实现
/// 负责节点注册、心跳管理、节点列表维护及跨节点数据同步
#[derive(Debug, Default)]
pub struct ArbServerRpcServiceImpl {
    /// 节点列表：按节点类型分组存储（线程安全）
    node_list: Arc<DashMap<NodeType, Vec<NodeInfo>>>,
    /// 客户端发送器映射：用于向连接的客户端推送消息（线程安全）
    client_senders: Arc<DashMap<String, mpsc::Sender<BytesBlob>>>,
}

impl ArbServerRpcServiceImpl {
    /// 创建新的仲裁服务实例
    pub fn new() -> Self {
        Self {
            node_list: Arc::new(DashMap::new()),
            client_senders: Arc::new(DashMap::new()),
        }
    }

    /// 注册客户端发送器（供客户端连接时调用）
    pub fn register_client(&self, client_id: String, sender: mpsc::Sender<BytesBlob>) {
        self.client_senders.insert(client_id, sender);
    }

    /// 移除客户端发送器（供客户端断开时调用）
    pub fn remove_client(&self, client_id: &str) {
        self.client_senders.remove(client_id);
    }

    // ------------------------------
    // 辅助方法：提取重复逻辑
    // ------------------------------

    /// 转换节点类型（封装重复的类型转换逻辑）
    fn parse_node_type(node_type_i32: i32) -> Result<NodeType, Status> {
        NodeType::try_from(node_type_i32)
            .map_err(|_| Status::invalid_argument("无效的节点类型（非法的枚举值）"))
    }

    /// 获取当前时间戳（毫秒）
    fn current_timestamp() -> Result<u64, Status> {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|e| Status::internal(format!("系统时间错误：{}", e)))?
            .as_millis()
            .try_into()
            .map_err(|_| Status::internal("时间戳溢出（超出u64范围）"))
    }

    /// 检查节点是否已注册
    fn check_node_existence(&self, node_type: &NodeType, node_addr: &str) -> bool {
        self.node_list
            .get(node_type)
            .map_or(false, |nodes| nodes.iter().any(|n| n.node_addr == node_addr))
    }

    // ------------------------------
    // 核心功能方法
    // ------------------------------

    /// 向所有连接的客户端广播消息
    /// 自动清理已断开连接的客户端发送器
    async fn broadcast_to_clients(&self, blob: BytesBlob) -> Result<(), Status> {
        let mut disconnected = Vec::new();

        // 遍历所有客户端发送消息
        for entry in self.client_senders.iter() {
            let client_id = entry.key().clone();
            let sender = entry.value();

            // 发送失败说明客户端已断开，记录待清理
            if sender.send(blob.clone()).await.is_err() {
                disconnected.push(client_id);
            }
        }

        // 清理已断开的客户端
        for client_id in disconnected {
            self.client_senders.remove(&client_id);
        }

        Ok(())
    }

    /// 向所有已注册节点同步数据（排除自身节点）
    /// 新增超时控制（5秒）避免无响应节点阻塞
    async fn sync_to_nodes(&self, exclude_addr: &str, blob: BytesBlob) {
        // 收集所有非自身节点
        let nodes: Vec<NodeInfo> = self.node_list
            .iter()
            .flat_map(|entry| entry.value().clone())
            .filter(|n| n.node_addr != exclude_addr)
            .collect();

        for node in nodes {
            let addr = format!("http://{}", node.node_addr);
            let blob = blob.clone();

            // 异步发送，避免单节点阻塞；添加超时控制
            tokio::spawn(async move {
                // 解析地址
                let uri = match Uri::try_from(&addr) {
                    Ok(uri) => uri,
                    Err(e) => {
                        eprintln!("[同步失败] 节点地址无效 {}: {}", addr, e);
                        return;
                    }
                };

                // 连接并同步数据（5秒超时）
                let result = timeout(Duration::from_secs(5), async {
                    match connect_client(&addr).await {
                        Ok(mut client) => {
                            client.sync_data(Request::new(blob)).await
                        }
                        Err(e) => Err(Status::unavailable(format!("连接失败: {}", e))),
                    }
                }).await;

                // 处理结果
                match result {
                    Ok(Ok(_)) => println!("[同步成功] 节点: {}", addr),
                    Ok(Err(e)) => eprintln!("[同步失败] 节点 {}: {}", addr, e),
                    Err(_) => eprintln!("[同步超时] 节点: {}", addr),
                }
            });
        }
    }
}

#[async_trait]
impl ArbServerRpcService for ArbServerRpcServiceImpl {
    /// 分片状态更新（仅允许已注册节点调用）
    async fn update_shard_state(
        &self,
        request: Request<BaseRequest>,
    ) -> Result<Response<CommonResp>, Status> {
        let req = request.into_inner();
        let node_type = Self::parse_node_type(req.node_type)?;

        // 检查节点是否已注册
        if !self.check_node_existence(&node_type, &req.node_addr) {
            return Err(Status::not_found(format!(
                "节点 {} 未注册（类型: {:?}）",
                req.node_addr, node_type
            )));
        }

        Ok(Response::new(CommonResp {
            success: true,
            message: format!("节点 {} 分片状态已更新", req.node_addr),
        }))
    }

    /// 节点注册（支持所有类型节点，SocketNode会触发广播和同步）
    async fn register_node(
        &self,
        request: Request<RegisterRequest>,
    ) -> Result<Response<CommonResp>, Status> {
        let req = request.into_inner();
        let node_type = Self::parse_node_type(req.node_type)?;
        let now = Self::current_timestamp()?;

        // 构建节点信息
        let new_node = NodeInfo {
            node_addr: req.node_addr.clone(),
            last_update_time: now,
            node_type: req.node_type,
            kafka_addr: req.kafka_addr,
        };

        // 检查节点是否已注册
        let mut entry = self.node_list.entry(node_type).or_insert_with(Vec::new);
        if entry.iter().any(|n| n.node_addr == req.node_addr) {
            return Err(Status::already_exists(format!(
                "节点 {} 已注册（类型: {:?}）",
                req.node_addr, node_type
            )));
        }

        // 新增节点
        entry.push(new_node.clone());

        // 如果是SocketNode，触发客户端广播和节点同步
        if node_type == NodeType::SocketNode {
            // 序列化节点信息
            let node_data = serde_json::to_vec(&new_node)
                .map_err(|e| Status::internal(format!("节点信息序列化失败: {}", e)))?;

            // 构建广播消息
            let sync_blob = BytesBlob {
                data: node_data,
                sync_type: SyncDataType::SocketAdd as i32,
            };

            // 向客户端广播新增事件
            self.broadcast_to_clients(sync_blob.clone()).await?;

            // 向其他节点同步信息
            self.sync_to_nodes(&req.node_addr, sync_blob).await;
        }

        Ok(Response::new(CommonResp {
            success: true,
            message: format!("节点 {} 注册成功（类型: {:?}）", req.node_addr, node_type),
        }))
    }

    /// 列出指定类型的所有节点
    async fn list_all_nodes(
        &self,
        request: Request<QueryNodeReq>,
    ) -> Result<Response<NodeInfoList>, Status> {
        let req = request.into_inner();
        let node_type = Self::parse_node_type(req.node_type)?;

        // 获取对应类型的节点列表（无则返回空列表）
        let nodes = self.node_list
            .get(&node_type)
            .map(|list| list.clone())
            .unwrap_or_default();

        Ok(Response::new(NodeInfoList { nodes }))
    }

    /// 节点优雅退出（移除节点并在必要时广播事件）
    async fn graceful_leave(
        &self,
        request: Request<NodeInfo>,
    ) -> Result<Response<CommonResp>, Status> {
        let req = request.into_inner();
        let node_type = Self::parse_node_type(req.node_type)?;

        if let Some(mut entry) = self.node_list.get_mut(&node_type) {
            let original_len = entry.len();
            // 保留所有地址不匹配的节点（即移除目标节点）
            entry.retain(|n| n.node_addr != req.node_addr);

            if original_len == entry.len() {
                return Err(Status::not_found(format!(
                    "节点 {} 不存在（类型: {:?}）",
                    req.node_addr, node_type
                )));
            }

            // 如果是SocketNode，广播移除事件
            if node_type == NodeType::SocketNode {
                let data = serde_json::to_vec(&req)
                    .map_err(|e| Status::internal(format!("节点信息序列化失败: {}", e)))?;

                let blob = BytesBlob {
                    data,
                    sync_type: SyncDataType::SocketDel as i32,
                };

                self.broadcast_to_clients(blob).await?;
            }

            Ok(Response::new(CommonResp {
                success: true,
                message: format!("节点 {} 已优雅退出", req.node_addr),
            }))
        } else {
            Err(Status::not_found(format!(
                "节点 {} 不存在（类型: {:?}）",
                req.node_addr, node_type
            )))
        }
    }

    /// 节点心跳检测（更新节点最后活跃时间）
    async fn heartbeat(
        &self,
        request: Request<BaseRequest>,
    ) -> Result<Response<CommonResp>, Status> {
        let req = request.into_inner();
        let node_type = Self::parse_node_type(req.node_type)?;
        let now = Self::current_timestamp()?;

        if let Some(mut entry) = self.node_list.get_mut(&node_type) {
            // 更新节点心跳时间
            let node_updated = entry
                .iter_mut()
                .find(|n| n.node_addr == req.node_addr)
                .map(|n| {
                    n.last_update_time = now;
                })
                .is_some();

            if node_updated {
                Ok(Response::new(CommonResp {
                    success: true,
                    message: format!("节点 {} 心跳更新成功", req.node_addr),
                }))
            } else {
                Err(Status::not_found(format!(
                    "节点 {} 未注册（类型: {:?}）",
                    req.node_addr, node_type
                )))
            }
        } else {
            Err(Status::not_found(format!(
                "节点 {} 未注册（类型: {:?}）",
                req.node_addr, node_type
            )))
        }
    }
}
