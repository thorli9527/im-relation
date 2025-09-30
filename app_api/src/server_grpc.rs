use std::convert::TryFrom;
use std::net::SocketAddr;

use anyhow::{anyhow, Context, Result};
use common::arb::NodeType;
use common::config::AppConfig;
use common::grpc::grpc_hot_online::online_service::DeviceType;
use common::node_util::NodeUtil;
use common::service::arb_client;
use common::util::common_utils::hash_index;
use log::warn;
use tonic::{transport::Server, Request, Response, Status};
use validator::Validate;

use crate::grpc::api::api_service_server::{ApiService, ApiServiceServer};
use crate::grpc::api::{
    BuildRegisterCodeRequest, BuildRegisterCodeResponse, ChangeEmailRequest, ChangeEmailResponse,
    ChangePasswordRequest, ChangePasswordResponse, ChangePhoneRequest, ChangePhoneResponse,
    GetFriendListRequest, GetFriendListResponse, GetGroupMemberDetailRequest,
    GetGroupMemberDetailResponse, GetGroupMembersRequest, GetGroupMembersResponse,
    GroupMemberSummary, LoginRequest, LoginResponse, UpdateProfileRequest, UpdateProfileResponse,
    VerifyRegisterCodeRequest, VerifyRegisterCodeResponse,
};
use crate::service::auth_models::{
    ChangeEmailRequestDto, ChangePasswordRequestDto, ChangePhoneRequestDto, RegisterRequest,
    RegisterVerifyRequest, UpdateProfileRequestDto,
};
use crate::service::user_service::{UserLogType, UserRegType, UserService, UserServiceAuthOpt};

#[derive(Default)]
struct ApiGrpcService;

#[tonic::async_trait]
impl ApiService for ApiGrpcService {
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
        let (client, session) = user_service
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

        let socket_addr = match resolve_socket_addr(client.id).await {
            Ok(addr) => addr,
            Err(err) => {
                warn!("resolve socket addr failed: {err}");
                String::new()
            }
        };
        let (socket_host, socket_port) = split_socket_addr(&socket_addr);

        Ok(Response::new(LoginResponse {
            token: session.token,
            expires_at: session.expires_at,
            socket_addr,
            socket_host,
            socket_port,
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

    async fn get_friend_list(
        &self,
        request: Request<GetFriendListRequest>,
    ) -> Result<Response<GetFriendListResponse>, Status> {
        let payload = request.into_inner();
        if payload.session_token.trim().is_empty() {
            return Err(Status::invalid_argument("session_token is required"));
        }

        Ok(Response::new(GetFriendListResponse {
            friends: Vec::new(),
        }))
    }

    async fn get_group_members(
        &self,
        request: Request<GetGroupMembersRequest>,
    ) -> Result<Response<GetGroupMembersResponse>, Status> {
        let payload = request.into_inner();
        if payload.session_token.trim().is_empty() {
            return Err(Status::invalid_argument("session_token is required"));
        }
        if payload.group_id <= 0 {
            return Err(Status::invalid_argument("group_id must be positive"));
        }

        Ok(Response::new(GetGroupMembersResponse {
            members: Vec::new(),
        }))
    }

    async fn get_group_member_detail(
        &self,
        request: Request<GetGroupMemberDetailRequest>,
    ) -> Result<Response<GetGroupMemberDetailResponse>, Status> {
        let payload = request.into_inner();
        if payload.session_token.trim().is_empty() {
            return Err(Status::invalid_argument("session_token is required"));
        }
        if payload.group_id <= 0 {
            return Err(Status::invalid_argument("group_id must be positive"));
        }
        if payload.member_id <= 0 {
            return Err(Status::invalid_argument("member_id must be positive"));
        }

        let member = GroupMemberSummary {
            group_id: payload.group_id,
            member_id: payload.member_id,
            nickname: String::new(),
            avatar: String::new(),
            role: 0,
        };

        Ok(Response::new(GetGroupMemberDetailResponse {
            member: Some(member),
            is_friend: false,
        }))
    }
}

async fn resolve_socket_addr(user_id: i64) -> Result<String> {
    let node_util = NodeUtil::get();
    let mut nodes = node_util.get_list(NodeType::SocketNode as i32);

    if nodes.is_empty() {
        let fetched = arb_client::ensure_nodes(NodeType::SocketNode)
            .await
            .context("load socket nodes from arb")?;
        if fetched.is_empty() {
            return Err(anyhow!("socket node list empty"));
        }
        nodes = node_util.get_list(NodeType::SocketNode as i32);
        if nodes.is_empty() {
            nodes = fetched.into_iter().map(|node| node.node_addr).collect();
        }
    }

    let count = i32::try_from(nodes.len()).unwrap_or(0);
    if count <= 0 {
        return Err(anyhow!("socket node list empty"));
    }

    let index = hash_index(&user_id, count) as usize;
    nodes
        .into_iter()
        .nth(index)
        .ok_or_else(|| anyhow!("socket node index out of range"))
}

fn split_socket_addr(addr: &str) -> (String, u32) {
    if addr.trim().is_empty() {
        return (String::new(), 0);
    }

    if let Ok(sock) = addr.parse::<std::net::SocketAddr>() {
        return (sock.ip().to_string(), sock.port() as u32);
    }

    match addr.rsplit_once(':') {
        Some((host, port_str)) => match port_str.parse::<u32>() {
            Ok(port) => (host.to_string(), port),
            Err(_) => (addr.to_string(), 0),
        },
        None => (addr.to_string(), 0),
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
        .add_service(ApiServiceServer::new(ApiGrpcService::default()))
        .serve(addr)
        .await?;

    Ok(())
}
