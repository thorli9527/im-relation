use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcService;
use crate::grpc_arb::arb_server::{BytesBlob, CommonResp, NodeInfo, NodeType, SyncDataType};
use crate::util::node_util::NodeUtil;
use async_trait::async_trait;
use log::{info, warn};
use once_cell::sync::Lazy;
use serde_json::Value;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::sync::RwLock;
use tonic::{Request, Response, Status};

static NODE_TABLE: Lazy<RwLock<HashMap<i32, HashMap<String, NodeInfo>>>> =
    Lazy::new(|| RwLock::new(HashMap::new()));

pub struct ArbClientServiceImpl;

impl ArbClientServiceImpl {
    pub fn new() -> Self {
        Self
    }
}

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

#[async_trait]
impl ArbClientRpcService for ArbClientServiceImpl {
    async fn sync_data(&self, request: Request<BytesBlob>) -> Result<Response<CommonResp>, Status> {
        let blob = request.into_inner();
        let sync_type = SyncDataType::try_from(blob.sync_type)
            .map_err(|_| Status::invalid_argument("unknown sync type"))?;

        match sync_type {
            SyncDataType::SocketAdd => {
                let node = decode_node_info(&blob.data)?;
                let node_type = node.node_type;
                update_node_cache(node_type, |entry| {
                    entry.insert(node.node_addr.clone(), node.clone());
                });
                info!(
                    "arb-sync add: node_type={} addr={} kafka={:?}",
                    node.node_type, node.node_addr, node.kafka_addr
                );
            }
            SyncDataType::SocketDel => {
                let node = decode_node_info(&blob.data)?;
                let node_type = node.node_type;
                let mut removed = false;
                update_node_cache(node_type, |entry| {
                    removed = entry.remove(&node.node_addr).is_some();
                });
                if removed {
                    info!(
                        "arb-sync remove: node_type={} addr={}",
                        node.node_type, node.node_addr
                    );
                } else {
                    warn!(
                        "arb-sync remove unknown node: node_type={} addr={}",
                        node.node_type, node.node_addr
                    );
                }
            }
        }

        Ok(Response::new(CommonResp {
            success: true,
            message: String::new(),
        }))
    }
}
