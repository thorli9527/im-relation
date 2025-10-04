use axum::{http::HeaderMap, routing::get, Json, Router};
use serde::Serialize;

use crate::service::grpc_gateway;
use common::errors::AppError;
use common::grpc::grpc_hot_online::online_service::SessionTokenStatus;
use common::grpc::grpc_hot_online::online_service::ValidateSessionTokenRequest;
use common::node_util::{NodeType, NodeUtil};
use common::util::common_utils::hash_index;

#[derive(Serialize)]
pub struct SocketAddrResponse {
    pub address: String,
}

pub fn router() -> Router {
    Router::new().route("/socket/address", get(socket_bind_address))
}

pub async fn socket_bind_address(headers: HeaderMap) -> Result<Json<SocketAddrResponse>, AppError> {
    let auth = headers
        .get("authorization")
        .and_then(|h| h.to_str().ok())
        .ok_or_else(|| AppError::BizError("socket.address.error".to_string()))?;

    let mut client = grpc_gateway::get_online_client()
        .await
        .map_err(|_| AppError::BizError("socket.address.error".to_string()))?;
    let resp = client
        .validate_session_token(ValidateSessionTokenRequest {
            session_token: auth.to_string(),
        })
        .await
        .map_err(|_| AppError::BizError("socket.address.error".to_string()))?
        .into_inner();

    if resp.status != SessionTokenStatus::StsActive as i32 {
        return Err(AppError::BizError("token.error".to_string()));
    }

    let node_util = NodeUtil::get();
    let node_list = node_util.get_list(NodeType::SocketNode as i32);
    let count = node_list.len() as i32;
    if count == 0 {
        return Err(AppError::BizError("socket.address.error".to_string()));
    }
    let index = hash_index(&resp.user_id, count);
    let address = node_list[index as usize].clone();

    Ok(Json(SocketAddrResponse { address }))
}

fn select_best_region(country: &str) -> Vec<&'static str> {
    match country {
        "CN" => vec!["CN", "HK", "JP"],
        "TW" => vec!["TW", "HK", "JP"],
        "HK" => vec!["HK", "JP", "CN"],
        "JP" => vec!["JP", "HK", "CN"],
        "US" | "CA" => vec!["US", "EU"],
        "GB" | "FR" | "DE" => vec!["EU", "US"],
        _ => vec!["HK", "US"],
    }
}
