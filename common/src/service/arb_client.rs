use crate::arb::{BytesBlob, CommonResp, NodeInfo, NodeType, SyncDataType, ACCESS_HEADER};
use crate::config::grpc_access_token;
use crate::node_util::NodeUtil;
use anyhow::Context;
use axum::{
    http::{HeaderMap, StatusCode},
    routing::post,
    Extension, Json, Router,
};
use log::{info, warn};
use once_cell::sync::Lazy;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::net::SocketAddr;
use std::sync::{Arc, RwLock};
use tonic::service::Routes;

static NODE_TABLE: Lazy<RwLock<HashMap<i32, HashMap<String, NodeInfo>>>> =
    Lazy::new(|| RwLock::new(HashMap::new()));

fn status_with_message(
    status: StatusCode,
    message: impl Into<String>,
) -> (StatusCode, Json<CommonResp>) {
    (
        status,
        Json(CommonResp {
            success: false,
            message: message.into(),
        }),
    )
}

fn decode_node_info(data: &[u8]) -> Result<NodeInfo, (StatusCode, Json<CommonResp>)> {
    serde_json::from_slice(data).map_err(|e| {
        status_with_message(
            StatusCode::BAD_REQUEST,
            format!("invalid node payload: {e}"),
        )
    })
}

fn effective_addr(node_type: NodeType, node: &NodeInfo) -> String {
    match node_type {
        NodeType::SocketNode => node
            .kafka_addr
            .clone()
            .unwrap_or_else(|| node.node_addr.clone()),
        _ => node.node_addr.clone(),
    }
}

fn update_node_cache<F>(node_type: i32, update: F)
where
    F: FnOnce(&mut HashMap<String, NodeInfo>),
{
    let mut table = NODE_TABLE.write().expect("node table write lock");
    let entry = table.entry(node_type).or_default();
    update(entry);

    let node_type_enum = NodeType::try_from(node_type).unwrap_or(NodeType::SocketNode);
    let addresses: Vec<String> = entry
        .values()
        .map(|node| effective_addr(node_type_enum, node))
        .collect();
    NodeUtil::get().reset_list(node_type, addresses);
}

struct RestContext {
    expected_token: Option<String>,
}

impl RestContext {
    fn authorize(&self, headers: &HeaderMap) -> Result<(), (StatusCode, Json<CommonResp>)> {
        let expected = match self.expected_token.as_deref() {
            Some(token) => token,
            None => {
                return Err(status_with_message(
                    StatusCode::UNAUTHORIZED,
                    "arb access token not configured",
                ))
            }
        };

        let provided = headers
            .get(ACCESS_HEADER)
            .and_then(|value| value.to_str().ok());

        if provided == Some(expected) {
            Ok(())
        } else {
            Err(status_with_message(
                StatusCode::UNAUTHORIZED,
                "invalid arb access token",
            ))
        }
    }
}

async fn sync_data_http(
    Extension(state): Extension<Arc<RestContext>>,
    headers: HeaderMap,
    Json(payload): Json<BytesBlob>,
) -> Result<Json<CommonResp>, (StatusCode, Json<CommonResp>)> {
    state.authorize(&headers)?;
    handle_sync(payload)
}

fn handle_sync(blob: BytesBlob) -> Result<Json<CommonResp>, (StatusCode, Json<CommonResp>)> {
    let sync_type = SyncDataType::try_from(blob.sync_type)
        .map_err(|_| status_with_message(StatusCode::BAD_REQUEST, "unknown sync type"))?;

    let node = decode_node_info(&blob.data)?;
    let node_type_enum = NodeType::try_from(node.node_type).unwrap_or(NodeType::SocketNode);

    match sync_type {
        SyncDataType::SocketAdd => {
            update_node_cache(node.node_type, |entry| {
                entry.insert(node.node_addr.clone(), node.clone());
            });
            let display_addr = effective_addr(node_type_enum, &node);
            info!(
                "arb-sync add: type={:?} addr={} kafka={:?} effective={}",
                node_type_enum, node.node_addr, node.kafka_addr, display_addr
            );
        }
        SyncDataType::SocketDel => {
            let mut removed = false;
            update_node_cache(node.node_type, |entry| {
                removed = entry.remove(&node.node_addr).is_some();
            });
            if removed {
                let display_addr = effective_addr(node_type_enum, &node);
                info!(
                    "arb-sync remove: type={:?} addr={} effective={}",
                    node_type_enum, node.node_addr, display_addr
                );
            } else {
                warn!(
                    "arb-sync remove unknown node: type={:?} addr={}",
                    node_type_enum, node.node_addr
                );
            }
        }
    }

    Ok(Json(CommonResp {
        success: true,
        message: "ok".to_string(),
    }))
}

fn rest_router(token: Option<String>) -> Router {
    let ctx = Arc::new(RestContext {
        expected_token: token,
    });

    Router::new()
        .route("/arb/server/sync", post(sync_data_http))
        .layer(Extension(ctx))
}

pub fn attach_http_gateway(routes: &mut Routes) {
    let router_slot = routes.axum_router_mut();
    *router_slot = rest_router(grpc_access_token());
}

pub fn node_snapshot(node_type: i32) -> Vec<NodeInfo> {
    NODE_TABLE
        .read()
        .expect("node table read lock")
        .get(&node_type)
        .map(|entry| entry.values().cloned().collect())
        .unwrap_or_default()
}

pub fn all_node_snapshot() -> HashMap<i32, Vec<NodeInfo>> {
    NODE_TABLE
        .read()
        .expect("node table read lock")
        .iter()
        .map(|(ty, nodes)| (*ty, nodes.values().cloned().collect()))
        .collect()
}

pub async fn start_arb_client_server(bind: &str) -> Result<(), anyhow::Error> {
    let addr: SocketAddr = bind.parse().context("invalid arb client bind addr")?;
    let router = rest_router(grpc_access_token());

    let listener = tokio::net::TcpListener::bind(addr).await?;
    tokio::spawn(async move {
        if let Err(e) = axum::serve(listener, router.into_make_service()).await {
            warn!("arb client http server exited: {}", e);
        }
    });
    Ok(())
}
