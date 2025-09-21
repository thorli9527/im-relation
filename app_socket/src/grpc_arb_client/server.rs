//! Arb 客户端 gRPC 服务（供 arb_service 主动推送变更使用）
//!
//! 说明：
//! - 暴露 `ArbClientRpcService::sync_data` 接口，arb_service 在节点注册/变更时推送；
//! - 本实现收到推送后，解析 Arb 推送的节点信息并更新 `NodeUtil` 缓存；
//! - 仍保留对外 gRPC 服务端以供 Arb 主动调用。

use crate::grpc_arb::arb_server::arb_client_rpc_service_server::{
    ArbClientRpcService, ArbClientRpcServiceServer,
};
use crate::grpc_arb::arb_server::{BytesBlob, CommonResp, NodeInfo, NodeType, SyncDataType};
use crate::util::node_util::NodeUtil;
use log::{info, warn};
use once_cell::sync::Lazy;
use serde_json::Value;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::sync::RwLock;
use tonic::{Request, Response, Status};

static NODE_TABLE: Lazy<RwLock<HashMap<i32, HashMap<String, NodeInfo>>>> =
    Lazy::new(|| RwLock::new(HashMap::new()));

#[derive(Clone, Default)]
pub struct ArbClientImpl;

fn decode_node_info(data: &[u8]) -> Result<NodeInfo, Status> {
    let value: Value = serde_json::from_slice(data)
        .map_err(|e| Status::invalid_argument(format!("invalid node payload: {e}")))?;

    let node_addr = value
        .get("node_addr")
        .and_then(|v| v.as_str())
        .ok_or_else(|| Status::invalid_argument("node_addr missing"))?
        .to_string();

    let last_update_time = value
        .get("last_update_time")
        .and_then(|v| v.as_u64())
        .unwrap_or_default();

    let node_type = value
        .get("node_type")
        .and_then(|v| v.as_i64())
        .unwrap_or_default() as i32;

    let kafka_addr = value
        .get("kafka_addr")
        .and_then(|v| v.as_str())
        .map(|s| s.to_string());

    Ok(NodeInfo {
        node_addr,
        last_update_time,
        node_type,
        kafka_addr,
    })
}

fn update_node_cache<F>(node_type: i32, update: F)
where
    F: FnOnce(&mut HashMap<String, NodeInfo>),
{
    let mut table = NODE_TABLE.write().expect("node table write lock");
    let entry = table.entry(node_type).or_default();
    update(entry);
    NodeUtil::get().reset_list(node_type, entry.keys().cloned().collect());
}

#[tonic::async_trait]
impl ArbClientRpcService for ArbClientImpl {
    async fn sync_data(&self, request: Request<BytesBlob>) -> Result<Response<CommonResp>, Status> {
        let blob = request.into_inner();
        let sync_type = SyncDataType::try_from(blob.sync_type)
            .map_err(|_| Status::invalid_argument("unknown sync type"))?;

        match sync_type {
            SyncDataType::SocketAdd => {
                let node = decode_node_info(&blob.data)?;
                let node_type_enum =
                    NodeType::try_from(node.node_type).unwrap_or(NodeType::SocketNode);
                update_node_cache(node.node_type, |entry| {
                    entry.insert(node.node_addr.clone(), node.clone());
                });
                info!(
                    "arb-sync add: type={:?} addr={} kafka={:?}",
                    node_type_enum, node.node_addr, node.kafka_addr
                );
            }
            SyncDataType::SocketDel => {
                let node = decode_node_info(&blob.data)?;
                let node_type_enum =
                    NodeType::try_from(node.node_type).unwrap_or(NodeType::SocketNode);
                let mut removed = false;
                update_node_cache(node.node_type, |entry| {
                    removed = entry.remove(&node.node_addr).is_some();
                });
                if removed {
                    info!(
                        "arb-sync remove: type={:?} addr={}",
                        node_type_enum, node.node_addr
                    );
                } else {
                    warn!(
                        "arb-sync remove unknown node: type={:?} addr={}",
                        node_type_enum, node.node_addr
                    );
                }
            }
        }

        Ok(Response::new(CommonResp {
            success: true,
            message: "ok".to_string(),
        }))
    }
}

/// 启动 arb-client gRPC 服务，在指定地址对外提供 `ArbClientRpcService`
pub async fn start_arb_client_server(bind: &str) -> Result<(), anyhow::Error> {
    let addr: std::net::SocketAddr = bind.parse()?;
    let svc = ArbClientImpl::default();
    tokio::spawn(async move {
        if let Err(e) = tonic::transport::Server::builder()
            .add_service(ArbClientRpcServiceServer::new(svc))
            .serve(addr)
            .await
        {
            log::warn!("arb client server exited: {}", e);
        }
    });
    Ok(())
}
