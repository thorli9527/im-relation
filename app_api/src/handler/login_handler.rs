use axum::{extract::Json, routing::post, Router};
use common::core::errors::AppError;
use common::core::result::ApiResponse;
use common::infra::grpc::grpc_user::online_service::{
    DeviceType, SessionTokenStatus, UpsertSessionTokenRequest as OnlineUpsertSessionTokenRequest,
    ValidateSessionTokenRequest as OnlineValidateSessionTokenRequest,
};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::handler::{
    user_handler::resolve_socket_addr,
    utils::{map_internal_error, success, validation_msg, HandlerResult},
};
use crate::service::{
    auth_models, user_gateway,
    user_service::{UserService, UserServiceAuthOpt},
};

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct LoginPayload {
    password: String,
    target: String,
    device_type: i32,
    device_id: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct LoginResult {
    token: String,
    expires_at: u64,
    socket_addr: String,
    avatar: String,
    email: Option<String>,
    phone: Option<String>,
    name: String,
    uid: i64,
    language: Option<String>,
    country: Option<String>,
    nickname: Option<String>,
    gender: i32,
    version: i32,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SessionTokenPayload {
    session_token: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct SessionValidationResult {
    ok: bool,
    uid: i64,
    expires_at: u64,
    token: String,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct LogoutPayload {
    session_token: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct LogoutResult {
    ok: bool,
    revoked_token: Option<String>,
}

#[utoipa::path(
    post,
    path = "/login",
    request_body = LoginPayload,
    responses(
        (status = 200, description = "登录返回会话信息", body = ApiResponse<LoginResult>)
    ),
    tag = "app_api"
)]
async fn login(Json(payload): Json<LoginPayload>) -> HandlerResult<LoginResult> {
    let login_type = auth_models::detect_login_type(&payload.target)
        .map_err(|err| AppError::Validation(validation_msg(&err)))?;
    let device_type = DeviceType::try_from(payload.device_type)
        .map_err(|_| AppError::Validation("unsupported device_type".into()))?;
    if payload.target.trim().is_empty() {
        return Err(AppError::Validation("target is required".into()));
    }
    if payload.password.trim().is_empty() {
        return Err(AppError::Validation("password is required".into()));
    }

    let user_service = UserService::get();
    let (user, session) = user_service
        .login_by_type(
            &login_type,
            &payload.target,
            &payload.password,
            &device_type,
            &payload.device_id,
        )
        .await
        .map_err(|err| {
            if err.to_string() == "login.error" {
                AppError::Unauthorized("login.error".into())
            } else {
                map_internal_error(err)
            }
        })?;

    let socket_addr = resolve_socket_addr(user.id).await.unwrap_or_default();

    success(LoginResult {
        token: session.token,
        expires_at: session.expires_at,
        socket_addr,
        avatar: user.avatar.clone(),
        email: user.email.clone(),
        phone: user.phone.clone(),
        name: user.name.clone(),
        uid: user.id,
        language: user.language.clone(),
        country: user.country.clone(),
        nickname: user.alias.clone(),
        gender: user.gender,
        version: user.version,
    })
}

#[utoipa::path(
    post,
    path = "/session/validate",
    request_body = SessionTokenPayload,
    responses(
        (status = 200, description = "验证 session token", body = ApiResponse<SessionValidationResult>)
    ),
    tag = "app_api"
)]
async fn validate_session(
    Json(payload): Json<SessionTokenPayload>,
) -> HandlerResult<SessionValidationResult> {
    if payload.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }

    let mut online_client = user_gateway::get_online_client()
        .await
        .map_err(map_internal_error)?;

    let resp = online_client
        .validate_session_token(OnlineValidateSessionTokenRequest {
            session_token: payload.session_token.clone(),
        })
        .await
        .map_err(map_internal_error)?
        .into_inner();

    let status = SessionTokenStatus::try_from(resp.status)
        .map_err(|_| AppError::Internal("invalid session token status".into()))?;

    if status != SessionTokenStatus::StsActive {
        return success(SessionValidationResult {
            ok: false,
            uid: 0,
            expires_at: 0,
            token: String::new(),
        });
    }

    let device_type = DeviceType::try_from(resp.device_type)
        .map_err(|_| AppError::Internal("invalid device type".into()))?;
    if resp.device_id.trim().is_empty() {
        return Err(AppError::Internal("session device_id missing".into()));
    }

    let upsert = online_client
        .upsert_session_token(OnlineUpsertSessionTokenRequest {
            uid: resp.uid,
            device_type: device_type as i32,
            device_id: resp.device_id.clone(),
            login_ip: None,
            user_agent: None,
        })
        .await
        .map_err(map_internal_error)?
        .into_inner();

    success(SessionValidationResult {
        ok: true,
        uid: resp.uid,
        expires_at: upsert.expires_at,
        token: upsert.session_token,
    })
}

#[utoipa::path(
    post,
    path = "/logout",
    request_body = LogoutPayload,
    responses(
        (status = 200, description = "登出并吊销 session token", body = ApiResponse<LogoutResult>)
    ),
    tag = "app_api"
)]
async fn logout(Json(payload): Json<LogoutPayload>) -> HandlerResult<LogoutResult> {
    if payload.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }

    let service = UserService::get();
    let revoked = service
        .revoke_session_token(&payload.session_token, Some("client logout"))
        .await
        .map_err(map_internal_error)?;

    success(LogoutResult {
        ok: true,
        revoked_token: revoked,
    })
}

pub fn router() -> Router {
    Router::new()
        .route("/login", post(login))
        .route("/session/validate", post(validate_session))
        .route("/logout", post(logout))
}
