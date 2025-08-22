use actix_web::{post, web, web::ServiceConfig, HttpResponse, Responder};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use common::errors::AppError;
use common::result::result;
use crate::grpc::auth::DeviceType;
use crate::grpc::client_service::FindByContentReq;
use crate::service::client_rpc_service_impl::ClientRpcServiceImpl;
use crate::service::user_service::UserRegType;

pub fn configure(cfg: &mut ServiceConfig) {
    cfg.service(auth_login);
}

#[derive(Deserialize, Serialize, ToSchema, Debug)]
pub struct LoginReq {
    #[schema(example = "phone")]
    login_type: UserRegType,
    #[schema(example = "123456")]
    password: String,
    #[schema(example = "+8613888888888")]
    target: String,
    #[schema(example = "Android")]
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
#[utoipa::path(
    post,
    path = "/auth/login",
    request_body = LoginReq,
    responses(
        (status = 200, description = "登录成功", body = LoginResp),
        (status = 401, description = "登录失败，用户名或密码错误"),
        (status = 500, description = "服务器错误"),
    ),
    tag = "auth"
)]
#[post("/auth/login")]
pub async fn auth_login(dto: web::Json<LoginReq>) -> Result<impl Responder, AppError> {
    let client_service = ClientRpcServiceImpl::get();
    let mut client = client_service.client.lock().await;
    match  dto.login_type{
        UserRegType::Phone => {
            let result = client.find_by_phone(FindByContentReq{ content: dto.target.clone() }).await.map_err(|e| AppError::BizError("login.error".to_string()))?;
            let result=result.into_inner();
            if result.client.is_some() {

            }


        },
        UserRegType::Email => {
            let result = client.login_by_email(LoginReqMsg {
                email: dto.email.clone(),
                password: dto.password.clone(),
            });
        },
    }
    match token_result {
        Ok(token) => {
            let resp = LoginResp {
                token,
            };
            Ok(HttpResponse::Ok().json(resp))
        }
        Err(e) => {
            eprintln!("Login failed: {:?}", e);
            Ok(HttpResponse::Unauthorized().body("Login failed: Invalid credentials")) // 401
        }
    }
}
