use std::time::Duration;
use actix_web::web::ServiceConfig;
use actix_web::{post, web, Responder};
use deadpool_redis::redis::AsyncCommands;
use log::error;
use serde_json::json;
use validator::Validate;
use common::config::AppConfig;
use common::errors::AppError;
use common::redis::redis_pool::RedisPoolTools;
use common::result::ApiResponse;
use common::util::common_utils::{build_md5_with_key, build_uuid};
use crate::grpc::client_service::FindByContentReq;
use crate::handler::auth::register_handler_dto::{RegisterRequest, RegisterResponse, RegisterVerifyRequest};
use crate::service::client_rpc_service_impl::ClientRpcServiceImpl;
use crate::service::user_service::{UserService, UserServiceAuthOpt};
use crate::service::user_service_impl::VerifySession;

pub fn configure(cfg: &mut ServiceConfig) {
    cfg.service(auth_register_verify);
}
#[utoipa::path(
    post,
    path = "/auth/register/build/code",
    tag = "Auth",
    request_body = RegisterRequest,
    responses(
        (status = 200, description = "注册成功", body = RegisterResponse),
        (status = 400, description = "参数格式错误"),
        (status = 500, description = "服务内部错误")
    )
)]
#[post("/auth/register/build/code")]
pub async fn build_register_code(payload: web::Json<RegisterRequest>) -> Result<impl Responder, AppError> {
    // 参数校验
    if let Err(errs) = payload.validate() {
        let msg = format!("validate.error, {}", errs.to_string());
        return Ok(ApiResponse::json_error(400, msg));
    }

    let user_service= UserService::get();
    let uuid=user_service.build_register_code(&payload.name,&payload.password,&payload.reg_type,&payload.target).await?;
    let body = json!({
                "regId": uuid.to_string(),
            });
    // 返回 uuid 给前端
    return  Ok(ApiResponse::success(body))

}
#[utoipa::path(
    post,
    path = "/auth/register/verify_code",
    tag = "Auth",
    request_body = RegisterVerifyRequest,
    responses(
        (status = 200, description = "注册成功", body = RegisterResponse),
        (status = 400, description = "参数错误或验证码无效"),
        (status = 500, description = "服务内部错误")
    )
)]
#[post("/auth/register/verify_code")]
pub async fn auth_register_verify(req: web::Json<RegisterVerifyRequest>) -> Result<impl Responder, AppError> {
    if let Err(errs) = req.validate() {
        error!("RegisterVerifyRequest validation failed: {}", errs.to_string());
        return Ok(ApiResponse::json_error(400, "system.error"));
    }
    let user_service = UserService::get();
    user_service.register_verify_code(&req.reg_id,&req.code).await?;
    return  Ok(ApiResponse::json_ok())

}
