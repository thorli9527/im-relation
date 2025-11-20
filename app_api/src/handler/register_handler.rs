use axum::{routing::post, Json, Router};
use common::core::errors::AppError;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

use common::core::result::ApiResponse;

use crate::handler::utils::{map_internal_error, success, validation_msg, HandlerResult};
use crate::service::{
    auth_models::{self, RegisterRequest, RegisterVerifyRequest},
    user_service::{UserLoginType, UserRegType, UserService, UserServiceAuthOpt},
};

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct BuildRegisterCodePayload {
    password: String,
    target: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct BuildRegisterCodeResult {
    reg_id: String,
    uid: i64,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct VerifyRegisterPayload {
    reg_id: String,
    code: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct VerifyRegisterResult {
    ok: bool,
}

#[utoipa::path(
    post,
    path = "/register/code",
    request_body = BuildRegisterCodePayload,
    responses(
        (status = 200, description = "生成注册码", body = ApiResponse<BuildRegisterCodeResult>)
    ),
    tag = "app_api"
)]
async fn build_register_code(
    Json(payload): Json<BuildRegisterCodePayload>,
) -> HandlerResult<BuildRegisterCodeResult> {
    let reg_type_detected = auth_models::detect_login_type(&payload.target)
        .map_err(|err| AppError::Validation(validation_msg(&err)))?;

    if !matches!(
        reg_type_detected,
        UserLoginType::Email | UserLoginType::Phone
    ) {
        return Err(AppError::Validation(
            "only email/phone registration supported".into(),
        ));
    }

    let reg_type = match reg_type_detected {
        UserLoginType::Email => UserRegType::Email,
        UserLoginType::Phone => UserRegType::Phone,
        _ => UserRegType::Email,
    };

    let dto = RegisterRequest {
        password: payload.password,
        reg_type,
        target: payload.target.clone(),
    };
    dto.validate()?;

    let user_service = UserService::get();
    let reg_id = user_service
        .build_register_code(&dto.password, &dto.reg_type, &dto.target)
        .await
        .map_err(map_internal_error)?;
    success(BuildRegisterCodeResult { reg_id, uid: 0 })
}

#[utoipa::path(
    post,
    path = "/register/verify",
    request_body = VerifyRegisterPayload,
    responses(
        (status = 200, description = "验证注册码", body = ApiResponse<VerifyRegisterResult>)
    ),
    tag = "app_api"
)]
async fn verify_register_code(
    Json(payload): Json<VerifyRegisterPayload>,
) -> HandlerResult<VerifyRegisterResult> {
    let dto = RegisterVerifyRequest {
        reg_id: payload.reg_id,
        code: payload.code,
    };
    dto.validate()?;

    UserService::get()
        .register_verify_code(&dto.reg_id, &dto.code)
        .await
        .map_err(map_internal_error)?;

    success(VerifyRegisterResult { ok: true })
}

pub fn router() -> Router {
    Router::new()
        .route("/register/code", post(build_register_code))
        .route("/register/verify", post(verify_register_code))
}
