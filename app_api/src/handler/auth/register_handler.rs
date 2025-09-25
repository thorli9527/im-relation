use axum::{extract::Json, routing::post, Router};
use serde_json::json;
use validator::Validate;

use crate::handler::auth::register_handler_dto::{
    RegisterRequest, RegisterResponse, RegisterVerifyRequest,
};
use crate::service::user_service::{UserRegType, UserService, UserServiceAuthOpt};
use common::errors::AppError;
use common::result::ApiResponse;
use log::error;

pub fn router() -> Router {
    Router::new()
        .route("/auth/register/build/code", post(build_register_code))
        .route("/auth/register/verify_code", post(auth_register_verify))
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
pub async fn build_register_code(
    Json(payload): Json<RegisterRequest>,
) -> Result<ApiResponse<serde_json::Value>, AppError> {
    if let Err(errs) = payload.validate() {
        let msg = format!("validate.error, {}", errs);
        return Ok(ApiResponse::json_error(400, msg));
    }

    let user_service = UserService::get();

    if payload.reg_type == UserRegType::LoginName {
        let uid = user_service
            .register_login_name(&payload.name, &payload.password)
            .await?;
        let body = json!({ "uid": uid.to_string() });
        return Ok(ApiResponse::json(body));
    }

    let uuid = user_service
        .build_register_code(
            &payload.name,
            &payload.password,
            &payload.reg_type,
            &payload.target,
        )
        .await?;

    let body = json!({ "regId": uuid.to_string() });
    Ok(ApiResponse::json(body))
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
pub async fn auth_register_verify(
    Json(req): Json<RegisterVerifyRequest>,
) -> Result<ApiResponse<serde_json::Value>, AppError> {
    if let Err(errs) = req.validate() {
        error!("RegisterVerifyRequest validation failed: {}", errs);
        return Ok(ApiResponse::json_error(400, "system.error"));
    }

    let user_service = UserService::get();
    user_service
        .register_verify_code(&req.reg_id, &req.code)
        .await?;
    Ok(ApiResponse::json_ok())
}
