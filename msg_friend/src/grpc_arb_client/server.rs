use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcService;
use crate::grpc_arb::arb_server::{BytesBlob, CommonResp, NodeInfo, SyncDataType};
use common::node_util::NodeUtil;
use log::{info, warn};
use once_cell::sync::Lazy;
use serde_json::Value;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::sync::RwLock;
use tonic::{Request, Response, Status};

static SOCKET_NODES: Lazy<RwLock<HashMap<String, NodeInfo>>> =
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

#[tonic::async_trait]
impl ArbClientRpcService for ArbClientImpl {
    async fn sync_data(&self, request: Request<BytesBlob>) -> Result<Response<CommonResp>, Status> {
        let blob = request.into_inner();
        let sync_type = SyncDataType::try_from(blob.sync_type)
            .map_err(|_| Status::invalid_argument("unknown sync type"))?;

        match sync_type {
            SyncDataType::SocketAdd => {
                let node = decode_node_info(&blob.data)?;
                let mut table = SOCKET_NODES.write().expect("socket node write lock");
                table.insert(node.node_addr.clone(), node.clone());
                NodeUtil::get().reset_list(node.node_type, table.keys().cloned().collect());
                info!(
                    "arb-sync socket added: addr={} kafka={:?}",
                    node.node_addr, node.kafka_addr
                );
            }
            SyncDataType::SocketDel => {
                let node = decode_node_info(&blob.data)?;
                let mut table = SOCKET_NODES.write().expect("socket node write lock");
                let removed = table.remove(&node.node_addr);
                NodeUtil::get().reset_list(node.node_type, table.keys().cloned().collect());
                if removed.is_some() {
                    info!("arb-sync socket removed: addr={}", node.node_addr);
                } else {
                    warn!(
                        "arb-sync remove for unknown socket: addr={}",
                        node.node_addr
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

#[allow(dead_code)]
pub fn current_socket_nodes() -> Vec<NodeInfo> {
    SOCKET_NODES
        .read()
        .expect("socket node read lock")
        .values()
        .cloned()
        .collect()
}
