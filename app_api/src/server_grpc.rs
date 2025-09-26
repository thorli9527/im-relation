use std::convert::TryFrom;
use std::net::SocketAddr;

use anyhow::{anyhow, Context, Result};
use common::config::AppConfig;
use common::grpc::grpc_hot_online::online_service::DeviceType;
use log::warn;
use tonic::{transport::Server, Request, Response, Status};
use validator::Validate;

use crate::grpc::api::auth_service_server::{AuthService, AuthServiceServer};
use crate::grpc::api::{
    BuildRegisterCodeRequest, BuildRegisterCodeResponse, ChangeEmailRequest, ChangeEmailResponse,
    ChangePasswordRequest, ChangePasswordResponse, ChangePhoneRequest, ChangePhoneResponse,
    LoginRequest, LoginResponse, UpdateProfileRequest, UpdateProfileResponse,
    VerifyRegisterCodeRequest, VerifyRegisterCodeResponse,
};
use crate::service::auth_models::{
    ChangeEmailRequestDto, ChangePasswordRequestDto, ChangePhoneRequestDto, RegisterRequest,
    RegisterVerifyRequest, UpdateProfileRequestDto,
};
use crate::service::user_service::{UserLogType, UserRegType, UserService, UserServiceAuthOpt};

#[derive(Default)]
struct AuthGrpcService;

#[tonic::async_trait]
impl AuthService for AuthGrpcService {
    async fn build_register_code(
        &self,
        request: Request<BuildRegisterCodeRequest>,
    ) -> Result<Response<BuildRegisterCodeResponse>, Status> {
        let payload = request.into_inner();
        let reg_type = UserRegType::from_i32(payload.reg_type).ok_or_else(|| {
            Status::invalid_argument(format!("unsupported reg_type: {}", payload.reg_type))
        })?;

        let dto = RegisterRequest {
            name: payload.name.clone(),
            password: payload.password.clone(),
            reg_type,
            target: payload.target.clone(),
        };
        if let Err(errs) = dto.validate() {
            return Err(Status::invalid_argument(format!(
                "validate.error: {}",
                errs
            )));
        }

        let user_service = UserService::get();

        if reg_type == UserRegType::LoginName {
            let uid = user_service
                .register_login_name(&dto.name, &dto.password)
                .await
                .map_err(|err| Status::internal(err.to_string()))?;
            return Ok(Response::new(BuildRegisterCodeResponse {
                reg_id: String::new(),
                uid,
            }));
        }

        let reg_id = user_service
            .build_register_code(&dto.name, &dto.password, &reg_type, &dto.target)
            .await
            .map_err(|err| Status::internal(err.to_string()))?;

        Ok(Response::new(BuildRegisterCodeResponse { reg_id, uid: 0 }))
    }

    async fn verify_register_code(
        &self,
        request: Request<VerifyRegisterCodeRequest>,
    ) -> Result<Response<VerifyRegisterCodeResponse>, Status> {
        let payload = request.into_inner();
        let dto = RegisterVerifyRequest {
            code: payload.code.clone(),
            reg_id: payload.reg_id.clone(),
        };
        if let Err(errs) = dto.validate() {
            return Err(Status::invalid_argument(format!(
                "validate.error: {}",
                errs
            )));
        }

        let user_service = UserService::get();
        user_service
            .register_verify_code(&dto.reg_id, &dto.code)
            .await
            .map_err(|err| Status::internal(err.to_string()))?;

        Ok(Response::new(VerifyRegisterCodeResponse { ok: true }))
    }

    async fn login(
        &self,
        request: Request<LoginRequest>,
    ) -> Result<Response<LoginResponse>, Status> {
        let payload = request.into_inner();

        let login_type = UserLogType::from_i32(payload.login_type).ok_or_else(|| {
            Status::invalid_argument(format!("unsupported login_type: {}", payload.login_type))
        })?;

        let device_type = DeviceType::try_from(payload.device_type).map_err(|_| {
            Status::invalid_argument(format!("unsupported device_type: {}", payload.device_type))
        })?;

        if payload.target.trim().is_empty() {
            return Err(Status::invalid_argument("target is required"));
        }
        if payload.password.trim().is_empty() {
            return Err(Status::invalid_argument("password is required"));
        }

        let user_service = UserService::get();
        let (_client, session) = user_service
            .login_by_type(
                &login_type,
                &payload.target,
                &payload.password,
                &device_type,
                &payload.device_id,
            )
            .await
            .map_err(|err| {
                let msg = err.to_string();
                if msg == "login.error" {
                    Status::unauthenticated(msg)
                } else {
                    warn!("login error: {msg}");
                    Status::internal(msg)
                }
            })?;

        Ok(Response::new(LoginResponse {
            token: session.token,
            expires_at: session.expires_at,
        }))
    }

    async fn change_password(
        &self,
        request: Request<ChangePasswordRequest>,
    ) -> Result<Response<ChangePasswordResponse>, Status> {
        let payload = request.into_inner();
        let dto = ChangePasswordRequestDto {
            session_token: payload.session_token.clone(),
            old_password: payload.old_password.clone(),
            new_password: payload.new_password.clone(),
        };
        if let Err(errs) = dto.validate() {
            return Err(Status::invalid_argument(format!(
                "validate.error: {}",
                errs
            )));
        }

        let user_service = UserService::get();
        user_service
            .change_password(&dto.session_token, &dto.old_password, &dto.new_password)
            .await
            .map_err(|err| Status::internal(err.to_string()))?;

        Ok(Response::new(ChangePasswordResponse { ok: true }))
    }

    async fn change_phone(
        &self,
        request: Request<ChangePhoneRequest>,
    ) -> Result<Response<ChangePhoneResponse>, Status> {
        let payload = request.into_inner();
        let dto = ChangePhoneRequestDto {
            session_token: payload.session_token.clone(),
            new_phone: payload.new_phone.clone(),
            old_phone_code: payload.old_phone_code.clone(),
            new_phone_code: payload.new_phone_code.clone(),
        };
        if let Err(errs) = dto.validate() {
            return Err(Status::invalid_argument(format!(
                "validate.error: {}",
                errs
            )));
        }

        if let Some(ref code) = dto.old_phone_code {
            if code.trim().len() != 6 {
                return Err(Status::invalid_argument("old phone code invalid"));
            }
        }

        let user_service = UserService::get();
        let phone = user_service
            .change_phone(
                &dto.session_token,
                dto.old_phone_code.as_deref(),
                &dto.new_phone,
                &dto.new_phone_code,
            )
            .await
            .map_err(|err| Status::internal(err.to_string()))?;

        Ok(Response::new(ChangePhoneResponse { ok: true, phone }))
    }

    async fn change_email(
        &self,
        request: Request<ChangeEmailRequest>,
    ) -> Result<Response<ChangeEmailResponse>, Status> {
        let payload = request.into_inner();
        let dto = ChangeEmailRequestDto {
            session_token: payload.session_token.clone(),
            new_email: payload.new_email.clone(),
            old_email_code: payload.old_email_code.clone(),
            new_email_code: payload.new_email_code.clone(),
        };
        if let Err(errs) = dto.validate() {
            return Err(Status::invalid_argument(format!(
                "validate.error: {}",
                errs
            )));
        }

        if let Some(ref code) = dto.old_email_code {
            if code.trim().len() != 6 {
                return Err(Status::invalid_argument("old email code invalid"));
            }
        }

        let user_service = UserService::get();
        let email = user_service
            .change_email(
                &dto.session_token,
                dto.old_email_code.as_deref(),
                &dto.new_email,
                &dto.new_email_code,
            )
            .await
            .map_err(|err| Status::internal(err.to_string()))?;

        Ok(Response::new(ChangeEmailResponse { ok: true, email }))
    }

    async fn update_profile(
        &self,
        request: Request<UpdateProfileRequest>,
    ) -> Result<Response<UpdateProfileResponse>, Status> {
        let payload = request.into_inner();
        let dto = UpdateProfileRequestDto {
            session_token: payload.session_token.clone(),
            avatar: payload.avatar.clone(),
            gender: payload.gender,
        };
        if let Err(errs) = dto.validate() {
            return Err(Status::invalid_argument(format!(
                "validate.error: {}",
                errs
            )));
        }

        if let Some(ref avatar) = dto.avatar {
            if avatar.trim().is_empty() {
                return Err(Status::invalid_argument("avatar cannot be empty"));
            }
        }

        if let Some(g) = dto.gender {
            if !matches!(g, 0 | 1 | 2 | 9) {
                return Err(Status::invalid_argument("gender invalid"));
            }
        }

        let user_service = UserService::get();
        user_service
            .update_profile(&dto.session_token, dto.gender, dto.avatar.as_deref())
            .await
            .map_err(|err| Status::internal(err.to_string()))?;

        Ok(Response::new(UpdateProfileResponse { ok: true }))
    }
}

pub async fn start() -> Result<()> {
    let app_cfg = AppConfig::get();
    let server_cfg = app_cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;

    let addr: SocketAddr = server_cfg
        .require_grpc_addr()
        .context("server.grpc missing host/port")?
        .parse()
        .context("invalid grpc listen address")?;

    Server::builder()
        .add_service(AuthServiceServer::new(AuthGrpcService::default()))
        .serve(addr)
        .await?;

    Ok(())
}
