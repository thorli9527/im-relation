use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_hot_online::online_service::SessionTokenStatus;
use crate::grpc_hot_online::online_service::ValidateSessionTokenRequest;
use crate::service::OnlineRpcServiceImpl;
use crate::util::node_util::NodeUtil;
use actix_web::{get, web, HttpRequest, HttpResponse, Responder};
use common::errors::AppError;
use common::util::common_utils::hash_index;
use serde::Serialize;

#[derive(Serialize)]
pub struct SocketAddrResponse {
    pub address: String,
}
pub fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(socket_bind_address);
}
#[get("/socket/address")]
pub async fn socket_bind_address(req: HttpRequest) -> Result<impl Responder, AppError> {
    // Authorization: <token>
    let auth = req
        .headers()
        .get("authorization")
        .and_then(|h| h.to_str().ok())
        .ok_or_else(|| AppError::BizError("socket.address.error".to_string()))?;

    let mut client = OnlineRpcServiceImpl::get_default()
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
    let i = node_list.len() as i32;
    if i == 0 {
        return Err(AppError::BizError("socket.address.error".to_string()));
    }
    let index = hash_index(&resp.user_id, i);
    let address = node_list[index as usize].clone();

    Ok(HttpResponse::Ok().json(SocketAddrResponse { address }))
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
