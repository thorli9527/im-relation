use anyhow::{anyhow, Result};
use async_trait::async_trait;
use common::config::AppConfig;
use common::infra::grpc::grpc_group::group_service::JoinPermission;
use common::infra::grpc::grpc_user::online_service::revoke_session_token_request::Target as RevokeTarget;
use common::infra::grpc::grpc_user::online_service::user_rpc_service_client::UserRpcServiceClient;
use common::infra::grpc::grpc_user::online_service::{
    AddFriendPolicy, AuthType, ChangeEmailReq, ChangePasswordReq, ChangePhoneReq, DeviceType,
    FindByContentReq, Gender, GetUserReq, RegisterUserReq, RevokeSessionTokenRequest,
    SessionTokenStatus, UpdateUserReq, UpsertSessionTokenRequest, UserEntity, UserType,
    ValidateSessionTokenRequest,
};
use common::infra::grpc::message::{self as msgpb};
use common::infra::redis::redis_pool::RedisPoolTools;
use common::support::util::common_utils::{build_md5_with_key, build_uuid};
use common::UID;
use deadpool_redis::redis::AsyncCommands;
use log::{error, info, warn};
use once_cell::sync::OnceCell;
use prost_types::FieldMask;
use serde::{Deserialize, Serialize};
use std::convert::TryFrom;
use std::sync::Arc;

use crate::service::{friend_gateway, group_gateway, message_gateway, user_gateway};

#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum UserLoginType {
    Phone = 1,
    Email = 2,
    QRCode = 3,
    LoginName = 4,
}

impl UserService {
    /// 资料更新后分发 ProfileUpdate 至好友与群。
    async fn dispatch_profile_update(
        &self,
        uid: i64,
        nickname: Option<&str>,
        avatar: Option<&str>,
        version: Option<i64>,
        updated_at: Option<i64>,
    ) -> anyhow::Result<()> {
        let mut contents = Vec::new();
        if let Some(nick) = nickname {
            contents.push(message_gateway::build_profile_content(
                common::infra::grpc::message::profile_event_content::ProfileEventType::EventName,
                nick.to_string(),
                version,
                updated_at,
            ));
        }
        if let Some(av) = avatar {
            contents.push(message_gateway::build_profile_content(
                common::infra::grpc::message::profile_event_content::ProfileEventType::EventAvatar,
                av.to_string(),
                version,
                updated_at,
            ));
        }
        if contents.is_empty() {
            return Ok(());
        }

        let friend_ids = self.fetch_all_friend_ids(uid).await?;
        let group_ids = self.fetch_all_group_ids(uid).await?;

        // 并发分发，减少串行 RPC。
        let ts_ms = updated_at.unwrap_or_else(common::support::util::date_util::now);
        // 批量推送好友
        let _ = message_gateway::send_batch_profile_update_to_friends(
            uid,
            friend_ids.clone(),
            contents.clone(),
            ts_ms,
            false,
        )
        .await;
        // 批量推送群
        let _ = message_gateway::send_batch_profile_update_to_groups(
            uid, group_ids, contents, ts_ms, false,
        )
        .await;

        Ok(())
    }

    async fn fetch_all_friend_ids(&self, uid: i64) -> anyhow::Result<Vec<i64>> {
        let mut page = 1;
        let page_size = 200;
        let mut ids = Vec::new();
        loop {
            let friends = friend_gateway::get_friends_page_detailed(uid, page, page_size).await?;
            if friends.is_empty() {
                break;
            }
            ids.extend(friends.iter().map(|f| f.friend_id as i64));
            if friends.len() < page_size as usize {
                break;
            }
            page += 1;
        }
        ids.sort_unstable();
        ids.dedup();
        Ok(ids)
    }

    async fn fetch_all_group_ids(&self, uid: i64) -> anyhow::Result<Vec<i64>> {
        let mut groups = Vec::new();
        let mut before_updated_at: Option<i64> = None;
        let mut before_group_id: Option<i64> = None;
        let limit = 200;

        loop {
            let page = message_gateway::list_group_conversations(
                uid,
                limit,
                before_updated_at,
                before_group_id,
            )
            .await?;
            if page.snapshots.is_empty() {
                break;
            }
            for snap in &page.snapshots {
                groups.push(snap.group_id);
            }
            if !page.has_more {
                break;
            }
            if let Some(last) = page.snapshots.last() {
                before_updated_at = Some(last.updated_at);
                before_group_id = Some(last.group_id);
            } else {
                break;
            }
        }

        groups.sort_unstable();
        groups.dedup();
        Ok(groups)
    }

    /// 通过 HTTP 加好友：
    /// - 先校验会话、拒绝自己加自己，已有好友直接返回。
    /// - 根据被加方策略：
    ///   * Anyone：直接建好友关系，并尝试推送系统消息“我们已经成为好友”。
    ///   * RequireVerify / 未指定：发送好友申请消息，返回 true 表示已提交申请。
    ///   * PhoneOnly：对方拒绝添加好友，返回错误。
    pub async fn add_friend_http(
        &self,
        session_token: &str,
        target_uid: i64,
        reason: Option<&str>,
        remark: Option<&str>,
        nickname: Option<&str>,
    ) -> anyhow::Result<bool> {
        // 会话校验，获取主动方 UID。
        let active = ensure_active_session(session_token)
            .await
            .map_err(|e| anyhow!(e))?;
        // 不能加自己
        if target_uid == active.uid {
            return Err(anyhow!("cannot add yourself as friend"));
        }

        // 已是好友则短路，不重复创建关系。
        if friend_gateway::is_friend(active.uid, target_uid).await? {
            info!(
                "add_friend_http: {} -> {} already friends, skip",
                active.uid, target_uid
            );
            return Ok(false);
        }

        // 查询被加方资料与加好友策略。
        let mut user_client = user_gateway::get_user_rpc_client().await?;
        let target = Self::get_user_by_id(&mut user_client, target_uid).await?;
        let policy = AddFriendPolicy::try_from(target.allow_add_friend)
            .unwrap_or(AddFriendPolicy::RequireVerify);

        // 归一化输入：去空格并转字符串，便于后续复用。
        let reason = reason.unwrap_or_default().trim().to_string();
        let remark = remark.unwrap_or_default().trim().to_string();
        let prefer_nick = nickname.unwrap_or("").trim().to_string();
        let target_nick = if prefer_nick.is_empty() {
            target
                .nickname
                .clone()
                .unwrap_or_else(|| target.name.clone())
        } else {
            prefer_nick.clone()
        };
        let nickname_for_user = (!prefer_nick.is_empty()).then_some(prefer_nick.as_str());
        let remark_ref = (!remark.is_empty()).then_some(remark.as_str());

        warn!(
            "add_friend_http: {} -> {} policy={:?} reason='{}' remark='{}' prefer_nick='{}'",
            active.uid, target_uid, policy, reason, remark, prefer_nick
        );

        match policy {
            AddFriendPolicy::Anyone => {
                // 对方允许任何人添加：直接建立好友关系。
                let _ = friend_gateway::add_friend(
                    active.uid,
                    target_uid,
                    remark_ref,
                    nickname_for_user,
                    None,
                )
                .await?;
                // 好友通道各发一条文本，便于会话展示。
                let active_user = Self::get_user_by_id(&mut user_client, active.uid)
                    .await
                    .ok();
                let active_lang = active_user.as_ref().and_then(|u| u.language.as_deref());
                let text_for_target = Self::friend_welcome_text(target.language.as_deref());
                let text_for_active = Self::friend_welcome_text(active_lang);
                let _ = message_gateway::send_friend_system_message(
                    active.uid,
                    target_uid,
                    text_for_target,
                )
                .await;
                let _ = message_gateway::send_friend_system_message(
                    target_uid,
                    active.uid,
                    text_for_active,
                )
                .await;
                Ok(false)
            }
            AddFriendPolicy::RequireVerify | AddFriendPolicy::AddFriendUnspecified => {
                // 对方需要验证或未指定：发送好友申请消息，返回 true 表示已提交申请。
                message_gateway::send_friend_request_message(
                    active.uid,
                    target_uid,
                    reason.as_str(),
                    remark.as_str(),
                    target_nick.as_str(),
                )
                .await?;
                info!(
                    "add_friend_http: friend request sent {} -> {}",
                    active.uid, target_uid
                );
                Ok(true)
            }
            AddFriendPolicy::PhoneOnly => {
                // 对方拒绝加好友策略：直接返回错误提示。
                Err(anyhow!("target does not accept friend requests"))
            }
        }
    }

    /// 处理好友申请（接受或拒绝），发送决策消息并在必要时建立好友关系。
    pub async fn decide_friend_request(
        &self,
        approver_uid: i64,
        requester_uid: i64,
        request_id: i64,
        accepted: bool,
        remark: Option<&str>,
        nickname: Option<&str>,
    ) -> anyhow::Result<()> {
        // 若已是好友且请求接受，直接发送决策消息即可。
        let already_friend = friend_gateway::is_friend(approver_uid, requester_uid).await?;

        // 查询双方昵称，作为默认展示昵称。
        let mut user_client = user_gateway::get_user_rpc_client().await?;
        let requester = Self::get_user_by_id(&mut user_client, requester_uid).await?;
        let approver = Self::get_user_by_id(&mut user_client, approver_uid).await?;

        let approver_nick = approver
            .nickname
            .clone()
            .unwrap_or_else(|| approver.name.clone());
        let preferred_nick = nickname
            .and_then(|n| {
                let t = n.trim();
                (!t.is_empty()).then_some(t.to_string())
            })
            .unwrap_or_else(|| requester.nickname.clone().unwrap_or_else(|| requester.name));
        let requester_lang = requester.language.as_deref();
        let approver_lang = approver.language.as_deref();
        let remark_clean = remark
            .and_then(|r| {
                let t = r.trim();
                (!t.is_empty()).then_some(t.to_string())
            })
            .unwrap_or_default();

        if accepted && !already_friend {
            // 从申请表抓取原申请侧的备注/昵称，供双向关系使用。
            // 为审批人侧写入好友关系（备注/昵称为审批人填的）。
            let _ = friend_gateway::add_friend(
                approver_uid,
                requester_uid,
                (!remark_clean.is_empty()).then_some(remark_clean.as_str()),
                Some(preferred_nick.as_str()),
                None,
            )
            .await?;
            // 为申请人侧写入好友关系，备注/昵称取申请时填写的值。
            let _ = friend_gateway::add_friend(
                requester_uid,
                approver_uid,
                None,
                Some(approver_nick.as_str()),
                None,
            )
            .await?;
            // 可选系统消息由后端发送，使用默认欢迎语。
            let text_for_requester = Self::friend_welcome_text(requester_lang);
            let text_for_approver = Self::friend_welcome_text(approver_lang);
            let _ = message_gateway::send_friend_system_message(
                approver_uid,
                requester_uid,
                text_for_requester,
            )
            .await;
            let _ = message_gateway::send_friend_system_message(
                requester_uid,
                approver_uid,
                text_for_approver,
            )
            .await;
        }

        // 发送好友业务决策消息（含默认欢迎语由 msg_friend 侧处理）。
        let decision = msgpb::FriendRequestDecisionPayload {
            request_id: request_id as u64,
            accepted,
            remark: remark_clean.clone(),
            decided_at: common::support::util::date_util::now(),
            send_default_message: accepted,
            default_message: if accepted {
                Self::friend_welcome_text(requester_lang).to_string()
            } else {
                String::new()
            },
            nickname: preferred_nick.clone(),
        };
        message_gateway::send_friend_decision_message(approver_uid, requester_uid, decision).await?;
        Ok(())
    }

    /// 通过 HTTP 加群：根据群 join_permission 决定直接入群或提交申请。
    pub async fn add_group_http(
        &self,
        session_token: &str,
        group_id: i64,
        reason: Option<&str>,
    ) -> anyhow::Result<bool> {
        let active = ensure_active_session(session_token)
            .await
            .map_err(|e| anyhow!(e))?;
        let group = group_gateway::get_group(group_id).await?;
        match JoinPermission::try_from(group.join_permission).ok() {
            Some(JoinPermission::Anyone) => {
                group_gateway::add_member(group_id, active.uid).await?;
                // 群系统消息提示加入
                let _ =
                    message_gateway::send_group_system_message(active.uid, group_id, "已加入群聊")
                        .await;
                Ok(false)
            }
            Some(JoinPermission::NeedApproval) | None | Some(JoinPermission::JoinUnspecified) => {
                let reason = reason.unwrap_or_default();
                message_gateway::send_group_join_request_message(active.uid, group_id, reason)
                    .await?;
                Ok(true)
            }
            Some(JoinPermission::InviteOnly) | Some(JoinPermission::Closed) => {
                Err(anyhow!("group is closed for joining"))
            }
        }
    }
}
impl UserLoginType {
    pub fn from_i32(value: i32) -> Option<Self> {
        match value {
            1 => Some(Self::Phone),
            2 => Some(Self::Email),
            3 => Some(Self::QRCode),
            4 => Some(Self::LoginName),
            _ => None,
        }
    }
}

#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum UserAuthOpt {
    Register,
    Login,
    Logout,
    ChangePassword,
    ResetPassword,
}

#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum UserRegType {
    Phone = 1,
    Email = 2,
    LoginName = 3,
}
impl UserRegType {
    pub fn from_i32(value: i32) -> Option<Self> {
        match value {
            1 => Some(Self::Phone),
            2 => Some(Self::Email),
            3 => Some(Self::LoginName),
            _ => None,
        }
    }
}

#[derive(Clone, Debug)]
pub struct SessionTokenInfo {
    pub token: String,
    pub expires_at: u64,
}

#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum ResetPasswordType {
    Phone = 1,
    Email = 2,
}

pub mod auth_models {
    use super::UserLoginType;
    use super::UserRegType;
    use common::support::util::validate::{
        validate_email_str, validate_password as validate_password_strength, validate_phone,
        validate_username,
    };
    use serde::{Deserialize, Serialize};
    use utoipa::ToSchema;
    use validator::{Validate, ValidationError};

    #[derive(Debug, Deserialize, Serialize, ToSchema, Validate, Clone)]
    #[validate(schema(function = "validate_register_request"))]
    pub struct RegisterRequest {
        #[validate(length(min = 8, message = "密码至少8位"))]
        #[validate(custom(function = "validate_password"))]
        pub password: String,
        pub reg_type: UserRegType,
        #[validate(custom(function = "validate_target"))]
        pub target: String,
        #[serde(default)]
        pub language: Option<String>,
        #[serde(default)]
        pub country: Option<String>,
        #[serde(default)]
        pub gender: Option<i32>,
        #[serde(default)]
        pub nickname: Option<String>,
    }

    #[derive(Debug, Deserialize, Validate, ToSchema, Clone)]
    pub struct RegisterVerifyRequest {
        #[validate(custom(function = "validate_verify_code"))]
        pub code: String,
        #[validate(length(min = 8, message = "注册 ID 无效"))]
        pub reg_id: String,
    }

    #[derive(Debug, Deserialize, Serialize, Validate, Clone, ToSchema)]
    #[serde(rename_all = "camelCase")]
    pub struct ChangePasswordRequestDto {
        #[validate(length(min = 1, message = "token.required"))]
        pub session_token: String,
        #[validate(length(min = 6, message = "密码至少6位"))]
        pub old_password: String,
        #[validate(length(min = 6, message = "密码至少6位"))]
        #[validate(custom(function = "validate_password"))]
        pub new_password: String,
    }

    #[derive(Debug, Deserialize, Serialize, Validate, Clone, ToSchema)]
    #[serde(rename_all = "camelCase")]
    pub struct ChangePhoneRequestDto {
        #[validate(length(min = 1, message = "token.required"))]
        pub session_token: String,
        #[validate(custom(function = "validate_phone"))]
        pub new_phone: String,
        pub old_phone_code: Option<String>,
        #[validate(length(equal = 6, message = "验证码格式错误"))]
        pub new_phone_code: String,
    }

    #[derive(Debug, Deserialize, Serialize, Validate, Clone, ToSchema)]
    #[serde(rename_all = "camelCase")]
    pub struct ChangeEmailRequestDto {
        #[validate(length(min = 1, message = "token.required"))]
        pub session_token: String,
        #[validate(email(message = "邮箱格式无效"))]
        pub new_email: String,
        pub old_email_code: Option<String>,
        #[validate(length(equal = 6, message = "验证码格式错误"))]
        pub new_email_code: String,
    }

    #[derive(Debug, Deserialize, Serialize, Validate, Clone, ToSchema)]
    #[serde(rename_all = "camelCase")]
    pub struct UpdateProfileRequestDto {
        #[validate(length(min = 1, message = "token.required"))]
        pub session_token: String,
        pub avatar: Option<String>,
        pub gender: Option<i32>,
        pub country: Option<String>,
        pub language: Option<String>,
        pub nickname: Option<String>,
    }

    fn validate_target(value: &str) -> Result<(), ValidationError> {
        let trimmed = value.trim();
        if trimmed.is_empty() {
            return Err(ValidationError::new("target.required"));
        }
        if trimmed.contains('@') {
            return validate_email_str(trimmed);
        }
        if trimmed.starts_with('+') || trimmed.chars().all(|c| c.is_ascii_digit()) {
            if validate_phone(trimmed).is_ok() {
                return Ok(());
            }
            return validate_username(trimmed);
        }
        validate_username(trimmed)
    }

    fn validate_password(pwd: &str) -> Result<(), ValidationError> {
        validate_password_strength(pwd)
    }

    fn validate_verify_code(code: &str) -> Result<(), ValidationError> {
        if code.is_empty() || code.len() == 6 {
            Ok(())
        } else {
            Err(ValidationError::new("验证码格式错误"))
        }
    }

    fn validate_register_request(req: &RegisterRequest) -> Result<(), ValidationError> {
        let target = req.target.trim();
        if target.is_empty() {
            return Err(ValidationError::new("target.required"));
        }
        match req.reg_type {
            UserRegType::Phone => validate_phone(target),
            UserRegType::Email => validate_email_str(target),
            UserRegType::LoginName => validate_username(target),
        }
    }

    pub fn detect_login_type(value: &str) -> Result<UserLoginType, ValidationError> {
        let target = value.trim();
        if target.is_empty() {
            return Err(ValidationError::new("target.required"));
        }
        if target.contains('@') {
            validate_email_str(target)?;
            Ok(UserLoginType::Email)
        } else if target.starts_with('+') || target.chars().all(|c| c.is_ascii_digit()) {
            validate_phone(target)?;
            Ok(UserLoginType::Phone)
        } else {
            Ok(UserLoginType::LoginName)
        }
    }
}

#[derive(Debug, Clone, Copy)]
pub struct ActiveSession {
    pub uid: i64,
    pub device_type: DeviceType,
}

pub async fn ensure_active_session(session_token: &str) -> Result<ActiveSession> {
    let mut online_client = user_gateway::get_online_client()
        .await
        .map_err(|err| anyhow!("init online client: {err}"))?;

    let response = online_client
        .validate_session_token(ValidateSessionTokenRequest {
            session_token: session_token.to_string(),
        })
        .await
        .map_err(|err| anyhow!("validate session token: {err}"))?
        .into_inner();

    let status = SessionTokenStatus::try_from(response.status)
        .map_err(|_| anyhow!("invalid session token status"))?;
    if status != SessionTokenStatus::StsActive {
        return Err(anyhow!("session token inactive"));
    }

    let device_type =
        DeviceType::try_from(response.device_type).map_err(|_| anyhow!("invalid device type"))?;

    Ok(ActiveSession {
        uid: response.uid,
        device_type,
    })
}

impl UserService {
    /// 根据语言代码选择默认好友欢迎语。
    fn friend_welcome_text(lang: Option<&str>) -> &'static str {
        match lang.map(|s| s.to_lowercase()) {
            Some(ref l) if l.starts_with("zh") => "我们已经是好友了",
            Some(ref l) if l.starts_with("ja") => "私たちはすでに友達です",
            _ => "We are now friends",
        }
    }

    /// 吊销指定 session token（调用 online_service.RevokeSessionToken）。
    pub async fn revoke_session_token(
        &self,
        session_token: &str,
        reason: Option<&str>,
    ) -> anyhow::Result<Option<String>> {
        let token = session_token.trim();
        if token.is_empty() {
            return Err(anyhow!("session_token is required"));
        }
        let mut client = user_gateway::get_online_client().await?;
        let resp = client
            .revoke_session_token(RevokeSessionTokenRequest {
                target: Some(RevokeTarget::SessionToken(token.to_string())),
                reason: reason.map(|s| s.to_string()),
            })
            .await
            .map_err(|err| anyhow!("revoke session token: {err}"))?
            .into_inner();

        if resp.ok {
            Ok(resp.revoked_token.filter(|s| !s.is_empty()))
        } else {
            Err(anyhow!("revoke session token failed"))
        }
    }
}

#[derive(Clone, Debug)]
pub struct UserService {}
impl UserService {
    pub fn new() -> Self {
        Self {}
    }
    pub fn init() {
        let instance = UserService::new();
        INSTANCE
            .set(Arc::new(instance))
            .expect("INSTANCE already initialized");
    }

    pub fn get() -> Arc<Self> {
        INSTANCE
            .get()
            .expect("UserManager is not initialized")
            .clone()
    }
}

static INSTANCE: OnceCell<Arc<UserService>> = OnceCell::new();

#[async_trait]
pub trait UserServiceAuthOpt: Send + Sync {
    async fn login_by_type(
        &self,
        login_type: &UserLoginType,
        target: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(UserEntity, SessionTokenInfo)>;

    async fn login(
        &self,
        message_id: &i64,
        auth_type: &AuthType,
        auth_content: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(SessionTokenInfo, UserEntity)>;

    async fn logout(&self, uid: UID, device_type: &DeviceType) -> anyhow::Result<()>;

    async fn build_register_code(
        &self,
        password: &str,
        reg_type: &UserRegType,
        target: &str,
        language: Option<&str>,
        country: Option<&str>,
        gender: Option<i32>,
        nickname: Option<&str>,
    ) -> anyhow::Result<String>;

    async fn register_verify_code(&self, uuid: &str, code: &str) -> anyhow::Result<()>;

    async fn change_password(
        &self,
        session_token: &str,
        old_password: &str,
        new_password: &str,
    ) -> anyhow::Result<()>;

    async fn change_phone(
        &self,
        session_token: &str,
        old_phone_code: Option<&str>,
        new_phone: &str,
        new_phone_code: &str,
    ) -> anyhow::Result<String>;

    async fn change_email(
        &self,
        session_token: &str,
        old_email_code: Option<&str>,
        new_email: &str,
        new_email_code: &str,
    ) -> anyhow::Result<String>;

    async fn update_profile(
        &self,
        session_token: &str,
        gender: Option<i32>,
        avatar: Option<&str>,
        country: Option<&str>,
        language: Option<&str>,
        nickname: Option<&str>,
    ) -> anyhow::Result<()>;

    async fn update_name(&self, session_token: &str, name: &str) -> anyhow::Result<()>;
}

#[derive(Serialize, Deserialize)]
pub struct VerifySession {
    pub password_hash: String,
    pub reg_type: UserRegType,
    pub contact: Option<String>,
    pub code: Option<String>,
    pub language: Option<String>,
    pub country: Option<String>,
    pub gender: Option<i32>,
    pub nickname: Option<String>,
}

#[derive(Clone, Debug)]
struct RegistrationTargetMeta {
    contact: Option<String>,
    requires_code: bool,
}

impl UserService {
    fn reg_type_from_login(login_type: &UserLoginType) -> Option<UserRegType> {
        match login_type {
            UserLoginType::Phone => Some(UserRegType::Phone),
            UserLoginType::Email => Some(UserRegType::Email),
            UserLoginType::LoginName => Some(UserRegType::LoginName),
            _ => None,
        }
    }

    async fn fetch_user_by_reg_type(
        client: &mut UserRpcServiceClient<tonic::transport::Channel>,
        reg_type: UserRegType,
        value: &str,
    ) -> anyhow::Result<Option<UserEntity>> {
        let req = FindByContentReq {
            content: value.to_string(),
        };
        let response = match reg_type {
            UserRegType::Email => client.find_by_email(req).await?,
            UserRegType::Phone => client.find_by_phone(req).await?,
            UserRegType::LoginName => client.find_by_name(req).await?,
        };
        Ok(response.into_inner().user)
    }

    async fn ensure_register_target(
        client: &mut UserRpcServiceClient<tonic::transport::Channel>,
        reg_type: &UserRegType,
        target: &str,
    ) -> anyhow::Result<RegistrationTargetMeta> {
        match reg_type {
            UserRegType::Email => {
                if Self::fetch_user_by_reg_type(client, *reg_type, target)
                    .await?
                    .is_some()
                {
                    return Err(anyhow!("邮箱已存在"));
                }
                Ok(RegistrationTargetMeta {
                    contact: Some(target.to_string()),
                    requires_code: true,
                })
            }
            UserRegType::Phone => {
                if Self::fetch_user_by_reg_type(client, *reg_type, target)
                    .await?
                    .is_some()
                {
                    return Err(anyhow!("手机号已存在"));
                }
                Ok(RegistrationTargetMeta {
                    contact: Some(target.to_string()),
                    requires_code: true,
                })
            }
            UserRegType::LoginName => {
                if Self::fetch_user_by_reg_type(client, *reg_type, target)
                    .await?
                    .is_some()
                {
                    return Err(anyhow!("用户名已存在"));
                }
                Ok(RegistrationTargetMeta {
                    contact: None,
                    requires_code: false,
                })
            }
        }
    }

    async fn validate_session_token(session_token: &str) -> anyhow::Result<(i64, DeviceType)> {
        let active = ensure_active_session(session_token).await?;
        Ok((active.uid, active.device_type))
    }

    async fn get_user_by_id(
        client: &mut UserRpcServiceClient<tonic::transport::Channel>,
        uid: i64,
    ) -> anyhow::Result<UserEntity> {
        let resp = client
            .find_user_by_id(GetUserReq { id: uid })
            .await?
            .into_inner();
        Ok(resp)
    }

    async fn verify_contact_code(kind: &str, contact: &str, code: &str) -> anyhow::Result<()> {
        let normalized_contact = contact.trim().to_lowercase();
        let key = format!("verify:{kind}:{}", normalized_contact);
        let mut conn = RedisPoolTools::get().get().await?;
        let stored: Option<String> = conn.get(&key).await?;
        match stored {
            Some(expected) if expected == code => {
                let _: () = conn.del(&key).await?;
                Ok(())
            }
            _ => Err(anyhow!("verify.code.invalid")),
        }
    }
}

#[async_trait]
impl UserServiceAuthOpt for UserService {
    async fn login_by_type(
        &self,
        login_type: &UserLoginType,
        target: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(UserEntity, SessionTokenInfo)> {
        let md5_key = AppConfig::get()
            .sys
            .as_ref()
            .and_then(|s| s.md5_key.clone())
            .ok_or_else(|| anyhow!("md5_key missing"))?;

        let reg_type =
            Self::reg_type_from_login(login_type).ok_or_else(|| anyhow!("Invalid auth type"))?;

        let mut client = user_gateway::get_user_rpc_client().await?;

        let mut entity = Self::fetch_user_by_reg_type(&mut client, reg_type, target)
            .await?
            .ok_or_else(|| anyhow!("login.error"))?;

        let stored_password = entity.password.clone();
        if stored_password != build_md5_with_key(password, &md5_key) {
            return Err(anyhow!("login.error"));
        }
        entity.password.clear();

        let mut online_client = user_gateway::get_online_client().await?;
        let token_resp = online_client
            .upsert_session_token(UpsertSessionTokenRequest {
                uid: entity.id,
                device_type: *device_type as i32,
                device_id: device_id.to_string(),
                login_ip: None,
                user_agent: None,
            })
            .await?
            .into_inner();

        let info: SessionTokenInfo = SessionTokenInfo {
            token: token_resp.session_token,
            expires_at: token_resp.expires_at,
        };

        Ok((entity, info))
    }

    async fn login(
        &self,
        _message_id: &i64,
        auth_type: &AuthType,
        auth_content: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(SessionTokenInfo, UserEntity)> {
        let login_type = match auth_type {
            AuthType::Email => UserLoginType::Email,
            AuthType::Phone => UserLoginType::Phone,
            AuthType::Username => UserLoginType::LoginName,
            _ => return Err(anyhow!("Invalid auth type")),
        };

        let (entity, info) = self
            .login_by_type(&login_type, auth_content, password, device_type, device_id)
            .await?;

        Ok((info, entity))
    }

    async fn logout(&self, _uid: UID, _device_type: &DeviceType) -> anyhow::Result<()> {
        Ok(())
    }

    async fn build_register_code(
        &self,
        password: &str,
        reg_type: &UserRegType,
        target: &str,
        language: Option<&str>,
        country: Option<&str>,
        gender: Option<i32>,
        nickname: Option<&str>,
    ) -> anyhow::Result<String> {
        let mut client = user_gateway::get_user_rpc_client().await?;
        let key = &AppConfig::get().sys.clone().unwrap().md5_key.unwrap();

        let meta = UserService::ensure_register_target(&mut client, reg_type, target).await?;
        let reg_id = build_uuid();
        let mut verify_session = VerifySession {
            password_hash: build_md5_with_key(password, key),
            reg_type: reg_type.clone(),
            contact: meta.contact.clone(),
            code: None,
            language: language.map(|s| s.to_string()),
            country: country.map(|s| s.to_string()),
            gender,
            nickname: nickname.map(|s| s.to_string()),
        };
        if meta.requires_code {
            verify_session.code = Some("123456".to_string());
        }
        let redis_key = format!("register:verify:uuid:{}", reg_id);

        let json_data = serde_json::to_string(&verify_session)?;

        let mut conn = RedisPoolTools::get().get().await?;
        conn.set_ex::<_, _, ()>(&redis_key, json_data, 300).await?;

        Ok(reg_id)
    }

    async fn register_verify_code(&self, reg_id: &str, code: &str) -> anyhow::Result<()> {
        let redis_key = format!("register:verify:uuid:{}", reg_id);

        let redis_pool = RedisPoolTools::get();
        let mut conn = redis_pool.get().await?;
        let json_data: String = conn.get(redis_key.clone()).await?;
        let verify_session: VerifySession = serde_json::from_str(&json_data)?;

        if let Some(expected) = &verify_session.code {
            if expected != code {
                return Err(anyhow!("Invalid verification code"));
            }
        }

        let _: () = conn.del(redis_key).await?;

        let mut client = user_gateway::get_user_rpc_client().await?;
        match verify_session.reg_type {
            UserRegType::Phone => {
                let phone = verify_session
                    .contact
                    .clone()
                    .ok_or_else(|| anyhow!("手机号缺失"))?;
                let result = client
                    .register(RegisterUserReq {
                        password: verify_session.password_hash.clone(),
                        email: None,
                        phone: Some(phone),
                        language: verify_session.language.clone(),
                        country: verify_session.country.clone(),
                        nickname: verify_session.nickname.clone(),
                        avatar: "".to_string(),
                        allow_add_friend: AddFriendPolicy::Anyone as i32,
                        gender: verify_session.gender.unwrap_or(0),
                        user_type: UserType::Normal as i32,
                        profile_fields: Default::default(),
                    })
                    .await;
                if result.is_ok() {
                    return Ok(());
                }
                error!("reg.error: {:?}", result.err().unwrap().code());
                Err(anyhow!("reg.error"))
            }
            UserRegType::Email => {
                let email = verify_session
                    .contact
                    .clone()
                    .ok_or_else(|| anyhow!("邮箱缺失"))?;
                let result = client
                    .register(RegisterUserReq {
                        password: verify_session.password_hash.clone(),
                        email: Some(email),
                        phone: None,
                        language: verify_session.language.clone(),
                        country: verify_session.country.clone(),
                        nickname: verify_session.nickname.clone(),
                        avatar: "".to_string(),
                        allow_add_friend: AddFriendPolicy::Anyone as i32,
                        gender: verify_session.gender.unwrap_or(0),
                        user_type: UserType::Normal as i32,
                        profile_fields: Default::default(),
                    })
                    .await;
                if result.is_ok() {
                    return Ok(());
                }
                error!("reg.error: {:?}", result.err().unwrap().code());
                Err(anyhow!("reg.error"))
            }
            other => {
                return Err(anyhow!("unsupported register type {:?}", other));
            }
        }
    }

    async fn change_password(
        &self,
        session_token: &str,
        old_password: &str,
        new_password: &str,
    ) -> anyhow::Result<()> {
        let md5_key = AppConfig::get()
            .sys
            .as_ref()
            .and_then(|cfg| cfg.md5_key.clone())
            .ok_or_else(|| anyhow!("md5_key missing"))?;

        let (uid, _) = UserService::validate_session_token(session_token).await?;
        let mut client = user_gateway::get_user_rpc_client().await?;
        let key = AppConfig::get()
            .sys
            .as_ref()
            .and_then(|cfg| cfg.md5_key.clone())
            .ok_or_else(|| anyhow!("md5_key missing"))?;
        let hashed_old = build_md5_with_key(old_password, &key);

        let hashed_new = build_md5_with_key(new_password, &md5_key);
        if hashed_new == hashed_old {
            return Err(anyhow!("password.nochange"));
        }

        let resp = client
            .change_password(ChangePasswordReq {
                id: uid,
                old_password: Some(hashed_old),
                new_password: hashed_new,
                verify_token: Some(session_token.to_string()),
            })
            .await?
            .into_inner();

        if !resp.success {
            return Err(anyhow!("change.password.failed"));
        }

        Ok(())
    }

    async fn change_phone(
        &self,
        session_token: &str,
        old_phone_code: Option<&str>,
        new_phone: &str,
        new_phone_code: &str,
    ) -> anyhow::Result<String> {
        let (uid, _) = UserService::validate_session_token(session_token).await?;

        let mut client = user_gateway::get_user_rpc_client().await?;
        let current = UserService::get_user_by_id(&mut client, uid).await?;

        if let Some(old_phone) = current.phone.as_deref() {
            let code = old_phone_code.ok_or_else(|| anyhow!("old.phone.code.required"))?;
            UserService::verify_contact_code("phone", old_phone, code).await?;
        } else if old_phone_code.is_some() {
            return Err(anyhow!("old.phone.not.bound"));
        }

        UserService::verify_contact_code("phone", new_phone, new_phone_code).await?;

        let updated = client
            .change_phone(ChangePhoneReq {
                id: uid,
                new_phone: Some(new_phone.to_string()),
                verify_token: Some(new_phone_code.to_string()),
            })
            .await?
            .into_inner();

        let phone = updated.phone.unwrap_or_default();
        Ok(phone)
    }

    async fn change_email(
        &self,
        session_token: &str,
        old_email_code: Option<&str>,
        new_email: &str,
        new_email_code: &str,
    ) -> anyhow::Result<String> {
        let (uid, _) = UserService::validate_session_token(session_token).await?;

        let mut client = user_gateway::get_user_rpc_client().await?;
        let current = UserService::get_user_by_id(&mut client, uid).await?;

        if let Some(old_email) = current.email.as_deref() {
            let code = old_email_code.ok_or_else(|| anyhow!("old.email.code.required"))?;
            UserService::verify_contact_code("email", old_email, code).await?;
        } else if old_email_code.is_some() {
            return Err(anyhow!("old.email.not.bound"));
        }

        UserService::verify_contact_code("email", new_email, new_email_code).await?;

        let updated = client
            .change_email(ChangeEmailReq {
                id: uid,
                new_email: Some(new_email.to_string()),
                verify_token: Some(new_email_code.to_string()),
            })
            .await?
            .into_inner();

        let email = updated.email.unwrap_or_default();
        Ok(email)
    }

    async fn update_profile(
        &self,
        session_token: &str,
        gender: Option<i32>,
        avatar: Option<&str>,
        country: Option<&str>,
        language: Option<&str>,
        nickname: Option<&str>,
    ) -> anyhow::Result<()> {
        if gender.is_none()
            && avatar.is_none()
            && country.is_none()
            && language.is_none()
            && nickname.is_none()
        {
            return Ok(());
        }

        let (uid, _) = UserService::validate_session_token(session_token).await?;

        let mut client = user_gateway::get_user_rpc_client().await?;
        let mut entity = UserService::get_user_by_id(&mut client, uid).await?;

        let mut paths: Vec<String> = Vec::new();
        let mut new_avatar: Option<String> = None;
        let mut new_nickname: Option<String> = None;

        if let Some(incoming_avatar) = avatar {
            let avatar_owned = incoming_avatar.to_string();
            entity.avatar = avatar_owned.clone();
            paths.push("avatar".to_string());
            new_avatar = Some(avatar_owned);
        }

        if let Some(g) = gender {
            let gender_enum = Gender::try_from(g).map_err(|_| anyhow!("gender.invalid"))?;
            entity.gender = gender_enum as i32;
            paths.push("gender".to_string());
        }

        if let Some(c) = country {
            entity.country = Some(c.to_string());
            paths.push("country".to_string());
        }

        if let Some(l) = language {
            entity.language = Some(l.to_string());
            paths.push("language".to_string());
        }

        if let Some(al) = nickname {
            let nickname_owned = al.to_string();
            entity.nickname = Some(nickname_owned.clone());
            paths.push("nickname".to_string());
            new_nickname = Some(nickname_owned);
        }

        if paths.is_empty() {
            return Ok(());
        }

        let mask = FieldMask { paths };

        client
            .update_user(UpdateUserReq {
                patch: Some(entity),
                update_mask: Some(mask),
            })
            .await?;

        let updated_at = common::support::util::date_util::now();
        self.dispatch_profile_update(
            uid,
            new_nickname.as_deref(),
            new_avatar.as_deref(),
            None,
            Some(updated_at),
        )
        .await?;

        Ok(())
    }

    async fn update_name(&self, session_token: &str, name: &str) -> anyhow::Result<()> {
        let normalized = name.trim();
        if normalized.is_empty() {
            return Err(anyhow!("name.required"));
        }

        common::support::util::validate::validate_username(normalized).map_err(|err| {
            let message = err
                .message
                .clone()
                .map(|m| m.into_owned())
                .unwrap_or_else(|| err.code.to_string());
            anyhow!(message)
        })?;

        let (uid, _) = UserService::validate_session_token(session_token).await?;

        let mut client = user_gateway::get_user_rpc_client().await?;
        if let Some(existing) =
            UserService::fetch_user_by_reg_type(&mut client, UserRegType::LoginName, normalized)
                .await?
        {
            if existing.id != uid {
                return Err(anyhow!("username.exists"));
            }
        }

        let mut entity = UserService::get_user_by_id(&mut client, uid).await?;
        if entity.name == normalized {
            return Ok(());
        }
        entity.name = normalized.to_string();

        client
            .update_user(UpdateUserReq {
                patch: Some(entity),
                update_mask: Some(FieldMask {
                    paths: vec!["name".to_string()],
                }),
            })
            .await?;

        Ok(())
    }
}
