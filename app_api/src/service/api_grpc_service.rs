use std::convert::TryFrom;

use anyhow::{anyhow, Result};
use common::config::AppConfig;
use common::infra::grpc::grpc_user::online_service::{DeviceType, GetUserReq};
use common::support::util::common_utils::hash_index;
use log::warn;
use tonic::{Request, Response, Status};
use validator::Validate;

use crate::grpc::api::api_service_server::ApiService;
use crate::grpc::api::{
    BuildRegisterCodeRequest, BuildRegisterCodeResponse, ChangeEmailRequest, ChangeEmailResponse,
    ChangePasswordRequest, ChangePasswordResponse, ChangePhoneRequest, ChangePhoneResponse,
    FriendSummary, GetFriendListRequest, GetFriendListResponse, GetGroupMemberDetailRequest,
    GetGroupMemberDetailResponse, GetGroupMembersRequest, GetGroupMembersResponse,
    GroupMemberSummary, LoginRequest, LoginResponse, UpdateProfileRequest, UpdateProfileResponse,
    VerifyRegisterCodeRequest, VerifyRegisterCodeResponse,
};
use crate::service::{
    auth_models::{
        ChangeEmailRequestDto, ChangePasswordRequestDto, ChangePhoneRequestDto, RegisterRequest,
        RegisterVerifyRequest, UpdateProfileRequestDto,
    },
    friend_gateway, grpc_gateway, session,
    user_service::{UserLogType, UserRegType, UserService, UserServiceAuthOpt},
};

/// gRPC 外观层，将客户端 API 请求转发到用户、好友、会话等内部服务。
#[derive(Default)]
pub struct ApiGrpcService;

#[tonic::async_trait]
impl ApiService for ApiGrpcService {
    async fn build_register_code(
        &self,
        request: Request<BuildRegisterCodeRequest>,
    ) -> Result<Response<BuildRegisterCodeResponse>, Status> {
        // 先提取请求载荷，确保后续校验与服务调用使用同一份数据。
        let payload = request.into_inner();
        let reg_type = UserRegType::from_i32(payload.reg_type).ok_or_else(|| {
            Status::invalid_argument(format!("unsupported reg_type: {}", payload.reg_type))
        })?;

        // 组装 DTO，将输入校验统一收敛到服务层的模型上。
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
            // 登录名注册不需要验证码流程，直接创建用户并返回 UID。
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
        // 在更改用户状态前先校验验证码请求的合法性。
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

        // 将原始 protobuf 枚举转换为领域枚举，避免下游继续处理裸数字。
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
        // 返回会话令牌以及 socket 地址，方便客户端建立实时通道。
        Ok(Response::new(LoginResponse {
            token: session.token,
            expires_at: session.expires_at,
            socket_addr,
        }))
    }

    async fn change_password(
        &self,
        request: Request<ChangePasswordRequest>,
    ) -> Result<Response<ChangePasswordResponse>, Status> {
        let payload = request.into_inner();
        // DTO 校验负责拦截空令牌或空密码，避免进入服务层。
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
        // DTO 同时收集新旧手机号及验证码，保证校验流程一致。
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
                // 旧手机号验证码需满足 6 位长度限制。
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
        // 和手机修改逻辑一致，只是换成邮箱相关字段与校验。
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
        // DTO 中整合头像与性别的可选校验，尽早截断非法输入。
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
                // 若头像仅为空白字符串，会造成存储层数据异常。
                return Err(Status::invalid_argument("avatar cannot be empty"));
            }
        }

        if let Some(g) = dto.gender {
            if !matches!(g, 0 | 1 | 2 | 9) {
                // 性别字段仅允许协议中约定的取值范围。
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
        if payload.page == 0 {
            return Err(Status::invalid_argument("page must be >= 1"));
        }
        if payload.page_size == 0 {
            return Err(Status::invalid_argument("page_size must be >= 1"));
        }
        // 查询好友前先确认会话仍然有效，避免返回敏感数据。
        let active_session = session::ensure_active_session(&payload.session_token)
            .await
            .map_err(|err| {
                let msg = err.to_string();
                if msg == "session token inactive" {
                    Status::unauthenticated(msg)
                } else {
                    Status::internal(msg)
                }
            })?;

        let entries = friend_gateway::get_friends_page_detailed(
            active_session.user_id,
            payload.page,
            payload.page_size,
        )
        .await
        .map_err(|err| Status::internal(err.to_string()))?;
        if entries.is_empty() {
            // 请求页无数据，直接返回空列表以避免额外 RPC 调用。
            return Ok(Response::new(GetFriendListResponse {
                friends: Vec::new(),
                page: payload.page,
                page_size: payload.page_size,
                has_more: false,
            }));
        }

        let mut client_rpc = grpc_gateway::get_user_rpc_client()
            .await
            .map_err(|err| Status::internal(err.to_string()))?;

        // 将存储的好友信息与实时用户资料合并，保证返回数据最新。
        let mut friends = Vec::with_capacity(entries.len());
        for entry in entries.into_iter() {
            let friend_id = entry.friend_id;
            let user = client_rpc
                .get_user(GetUserReq { id: friend_id })
                .await?
                .into_inner();

            let nickname = user.name;
            let avatar = entry
                .avatar
                .and_then(|avatar| {
                    let trimmed = avatar.trim();
                    if trimmed.is_empty() {
                        None
                    } else if trimmed.len() == avatar.len() {
                        Some(avatar)
                    } else {
                        Some(trimmed.to_string())
                    }
                })
                .unwrap_or_else(|| user.avatar.clone());

            let remark = entry.alias.and_then(|alias| {
                let trimmed = alias.trim();
                if trimmed.is_empty() {
                    None
                } else if trimmed.len() == alias.len() {
                    Some(alias)
                } else {
                    Some(trimmed.to_string())
                }
            });

            friends.push(FriendSummary {
                friend_id,
                nickname,
                avatar,
                remark,
            });
        }

        let has_more = payload.page_size > 0 && friends.len() as u32 == payload.page_size;

        Ok(Response::new(GetFriendListResponse {
            friends,
            page: payload.page,
            page_size: payload.page_size,
            has_more,
        }))
    }

    async fn get_group_members(
        &self,
        request: Request<GetGroupMembersRequest>,
    ) -> Result<Response<GetGroupMembersResponse>, Status> {
        let payload = request.into_inner();
        // 在接口层完成参数校验，使客户端能收到准确的 gRPC 错误信息。
        if payload.session_token.trim().is_empty() {
            return Err(Status::invalid_argument("session_token is required"));
        }
        if payload.group_id <= 0 {
            return Err(Status::invalid_argument("group_id must be positive"));
        }

        if payload.page == 0 {
            return Err(Status::invalid_argument("page must be >= 1"));
        }
        if payload.page_size == 0 {
            return Err(Status::invalid_argument("page_size must be >= 1"));
        }

        Ok(Response::new(GetGroupMembersResponse {
            // 临时返回空数据，在接入群组服务前维持接口契约。
            members: Vec::new(),
            page: payload.page,
            page_size: payload.page_size,
            has_more: false,
        }))
    }

    async fn get_group_member_detail(
        &self,
        request: Request<GetGroupMemberDetailRequest>,
    ) -> Result<Response<GetGroupMemberDetailResponse>, Status> {
        let payload = request.into_inner();
        // 与列表接口保持一致的防御性校验，避免通过错误信息泄露数据。
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
    let cfg = AppConfig::get();
    let sockets = cfg.app_socket_configs();

    if !sockets.is_empty() {
        // 优先使用新 socket 配置，通过哈希用户 ID 将请求均匀分布至各节点。
        let count = i32::try_from(sockets.len()).unwrap_or(0);
        if count <= 0 {
            return Err(anyhow!("socket node list empty"));
        }

        let index = hash_index(&user_id, count) as usize;
        let socket = sockets
            .get(index)
            .ok_or_else(|| anyhow!("socket node index out of range"))?;

        if let Some(addr) = socket.pub_addr() {
            return Ok(addr);
        }

        if let Ok(addr) = socket.tcp_addr() {
            return Ok(addr);
        }

        return Err(anyhow!("socket node missing public address"));
    }

    // 兼容旧配置：回退到基于 urls_for_node_type 的列表。
    let nodes = cfg.urls_for_node_type(common::support::node::NodeType::SocketNode);
    // 兼容旧配置时沿用一致的哈希逻辑，确保路由结果可预测。
    if nodes.is_empty() {
        return Err(anyhow!("socket node list empty"));
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
