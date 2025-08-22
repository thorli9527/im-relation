use actix_web::{post, web, web::ServiceConfig, HttpResponse, Responder};
use deadpool_redis::redis::AsyncCommands;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use common::config::AppConfig;
use common::errors::AppError;
use common::redis::redis_pool::RedisPoolTools;
use common::result::{result, result_data, ApiResponse};
use common::util::common_utils::{build_md5_with_key, build_uuid};
use crate::grpc::auth::DeviceType;
use crate::grpc::client_service::{ClientEntity, FindByContentReq};
use crate::service::client_rpc_service_impl::ClientRpcServiceImpl;
use crate::service::user_service::{UserLogType, UserRegType};

pub fn configure(cfg: &mut ServiceConfig) {
    cfg.service(auth_login);
}

#[derive(Deserialize, Serialize, Debug)]
pub struct LoginReq {
    login_type: UserLogType,
    password: String,
    target: String,
    device_type: DeviceType,
}

#[derive(Deserialize, Serialize, ToSchema, Debug)]
pub struct LoginResp {
    #[schema(example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")]
    token: String,
}

/// 用户登录
///
/// 用户可以使用手机号、邮箱、用户名等方式登录
#[post("/auth/login")]
pub async fn auth_login(dto: web::Json<LoginReq>) -> Result<impl Responder, AppError> {
    let client_service = ClientRpcServiceImpl::get();
    let mut client = client_service.client.lock().await;
    let req = FindByContentReq { content: dto.target.clone() };
    let md5_key = &AppConfig::get().sys.clone().unwrap().md5_key.unwrap();

    let client_op: Option<ClientEntity> = match dto.login_type {
        UserLogType::Phone => {
            let result = client.find_by_phone(req).await.map_err(|e| AppError::BizError("login.error".to_string()))?;
            let result = result.into_inner();
            if let Some(mut client) = result.client {
                let stored_password = client.password.clone();
                if dto.password == build_md5_with_key(&stored_password, md5_key) {
                    client.password = "".to_string();
                    Some(client)
                } else {
                    None
                }
            } else {
                None
            }
        },
        UserLogType::Email => {
            let result = client.find_by_email(req).await.map_err(|e| AppError::BizError("login.error".to_string()))?;
            let result = result.into_inner();
            if let Some(mut client) = result.client {
                let stored_password = client.password.clone();
                if dto.password == build_md5_with_key(&stored_password, md5_key) {
                    client.password = "".to_string();
                    Some(client)
                } else {
                    None
                }
            } else {
                None
            }
        },
        _ => {
            None
        }
    };

    if client_op.is_none() {
        return Err(AppError::BizError("login.error".to_string()));
    }

    let token = build_uuid();
    let redis_key = format!("app:token:{}", token);
    let redis_pool = RedisPoolTools::get();
    let mut conn = redis_pool.get().await.map_err(|e| AppError::BizError("redis.error".to_string()))?;
    let json_data = serde_json::to_string(&client_op.clone().unwrap())?;
    conn.set::<_, _, ()>(&redis_key, json_data).await.map_err(|e| AppError::BizError("redis.set.error".to_string()))?;
    let resp = LoginResp { token };
    Ok(HttpResponse::Ok().json(result_data(client_op.unwrap())))
}
