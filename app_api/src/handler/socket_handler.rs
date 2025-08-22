use crate::grpc::arb_server::NodeType;
use crate::grpc::client_service::ClientEntity;
use crate::util::node_util::NodeUtil;
use actix_web::{HttpRequest, HttpResponse, Responder, get, web};
use common::errors::AppError;
use common::redis::redis_pool::RedisPoolTools;
use common::util::common_utils::hash_index;
use deadpool_redis::redis::AsyncCommands;
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
    // 获取常见的 headers
    if let Some(auth) = req.headers().get("authorization") {
        if let Ok(auth_str) = auth.to_str() {
            let token = auth_str.to_string();
            let redis_key = format!("app:token:{}",token);
            let redis_pool = RedisPoolTools::get();
            let mut conn = redis_pool
                .get()
                .await
                .map_err(|e| AppError::BizError("redis.error".to_string()))?;
            let token_info: Option<String> = conn
                .get(&redis_key)
                .await
                .map_err(|e| AppError::BizError("redis.error".to_string()))?;
            if token_info.is_some() {
                let client: ClientEntity = serde_json::from_str(&token_info.unwrap())
                    .map_err(|e| AppError::BizError("token.error".to_string()))?;

                let node_util = NodeUtil::get();
                let node_list = node_util.get_list(NodeType::SocketNode);
                let i = node_list.len() as i32;
                let index = hash_index(&client.id, i);
                let address = node_list[index as usize].clone();
                return Ok(HttpResponse::Ok().json(SocketAddrResponse {
                    address: address.node_addr,
                }));
            }
        }
    }
    return Err(AppError::BizError("socket.address.error".to_string()));
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
