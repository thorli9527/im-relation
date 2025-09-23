use axum::{extract::Json, routing::post, Router};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::service::user_service::{UserLogType, UserService, UserServiceAuthOpt};
use common::errors::AppError;
use common::grpc::grpc_hot_online::online_service::DeviceType;
use common::result::ApiResponse;

pub fn router() -> Router {
    Router::new().route("/auth/login", post(auth_login))
}

#[derive(Deserialize, Serialize, Debug)]
pub struct LoginReq {
    pub login_type: UserLogType,
    pub password: String,
    pub target: String,
    pub device_type: DeviceType,
    pub device_id: String,
}

#[derive(Deserialize, Serialize, ToSchema, Debug)]
pub struct LoginResp {
    #[schema(example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")]
    pub token: String,
}

/// 用户登录
///
/// 用户可以使用手机号、邮箱、用户名等方式登录
pub async fn auth_login(Json(dto): Json<LoginReq>) -> Result<ApiResponse<LoginResp>, AppError> {
    let user_service = UserService::get();
    let (_client, session) = user_service
        .login_by_type(
            &dto.login_type,
            &dto.target,
            &dto.password,
            &dto.device_type,
            &dto.device_id,
        )
        .await
        .map_err(|_| AppError::BizError("login.error".to_string()))?;

    let resp = LoginResp {
        token: session.token,
    };
    Ok(ApiResponse::success(resp))
}
