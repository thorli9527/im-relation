use crate::grpc_hot_online::auth::DeviceType;
use crate::service::user_service::{UserLogType, UserService, UserServiceAuthOpt};
use actix_web::{post, web, web::ServiceConfig, HttpResponse, Responder};
use common::errors::AppError;
use common::result::result_data;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

pub fn configure(cfg: &mut ServiceConfig) {
    cfg.service(auth_login);
}

#[derive(Deserialize, Serialize, Debug)]
pub struct LoginReq {
    login_type: UserLogType,
    password: String,
    target: String,
    device_type: DeviceType,
    device_id: String,
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
    Ok(HttpResponse::Ok().json(result_data(resp)))
}
