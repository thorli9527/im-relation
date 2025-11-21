use std::{
    thread,
    time::{Duration, Instant},
};

use flutter_rust_bridge::frb;
use log::{error, info};
use serde::de::DeserializeOwned;
use serde::Serialize;

use crate::api::config_api;
use crate::api::errors::ApiError;
use crate::service::{
    auth_service, message_service::MessageService, socket_client::SocketClient,
};
use crate::{common::db, domain, service};
use crate::common::client;

include!("app_api_types.rs");

#[frb(init)]
/// 初始化应用：启动数据库、领域服务，并准备必要的配置（设备 ID、接口地址、重连限制）。
pub fn init_app() -> Result<(), String> {
    crate::common::init_logging();
    db::init().map_err(|err| err.to_string())?;
    domain::init();
    service::init();
    config_api::get_device_id()?;
    config_api::ensure_app_api_base_url_initialized()?;
    let limit = config_api::ensure_socket_reconnect_limit()?;
    let _ = config_api::ensure_attempts(limit)?;
    Ok(())
}

fn post_request<TReq, TResp>(path: &str, body: &TReq) -> Result<TResp, String>
where
    TReq: Serialize + ?Sized,
    TResp: DeserializeOwned,
{
    client::with_app_api_client(|client| client.post_json(path, body))
}

/// 通用 GET 请求封装，自动附带 app_api 客户端和 JSON 解析。
fn get_request<TReq, TResp>(path: &str, params: &TReq) -> Result<TResp, String>
where
    TReq: Serialize + ?Sized,
    TResp: DeserializeOwned,
{
    client::with_app_api_client(|client| client.get_json(path, params))
}

#[frb]
/// 拉取注册验证码（邮箱/手机号）。
pub fn build_register_code(
    payload: BuildRegisterCodeRequest,
) -> Result<BuildRegisterCodeResponse, String> {
    post_request("/register/code", &payload)
}

#[frb]
/// 校验注册验证码。
pub fn verify_register_code(payload: VerifyRegisterCodeRequest) -> Result<OperationStatus, String> {
    post_request("/register/verify", &payload)
}

#[frb]
/// 登录并等待 socket 连接及鉴权完成，超时可配置。
pub fn login(payload: LoginRequest, timeout_secs: Option<u64>) -> Result<LoginResult, String> {
    let (result, auth_message_id) = perform_login(&payload).map_err(|err| {
        error!("login_and_wait_for_socket: login failed: {}", err);
        err
    })?;
    let receiver = SocketClient::get().subscribe_connection_success();
    let duration = Duration::from_secs(timeout_secs.unwrap_or(30));
    receiver
        .recv_timeout(duration)
        .map_err(|_| ApiError::timeout("socket connection timeout").into_string())?;
    info!("socket 连接成功，正在等待鉴权...");
    wait_for_auth_ack(auth_message_id, Duration::from_secs(30))?;
    info!("基础鉴权已完成");
    Ok(result)
}

#[frb]
/// 登出并清理登录态。
pub fn logout() -> Result<(), String> {
    if let Some(token) = config_api::get_token()? {
        if !token.trim().is_empty() {
            let resp: LogoutResult = post_request(
                "/logout",
                &LogoutRequest {
                    session_token: token,
                },
            )?;
            if !resp.ok {
                return Err("logout failed on server".into());
            }
            // 若服务端返回吊销的 token，可按需记录/调试；此处不额外处理。
        }
    }

    auth_service::logout().map_err(|err| ApiError::system(err).into_string())
}

#[frb]
/// 校验会话 token 是否有效。
pub fn validate_session(
    payload: SessionValidateRequest,
) -> Result<SessionValidationResult, String> {
    post_request("/session/validate", &payload)
}

#[frb]
/// 修改密码。
pub fn change_password(payload: ChangePasswordRequest) -> Result<OperationStatus, String> {
    post_request("/password/change", &payload)
}

#[frb]
/// 更换绑定手机号。
pub fn change_phone(payload: ChangePhoneRequest) -> Result<ChangePhoneResult, String> {
    post_request("/phone/change", &payload)
}

#[frb]
/// 更换绑定邮箱。
pub fn change_email(payload: ChangeEmailRequest) -> Result<ChangeEmailResult, String> {
    post_request("/email/change", &payload)
}

#[frb]
/// 更新个人资料（头像、性别）。
pub fn update_profile(payload: UpdateProfileRequest) -> Result<OperationStatus, String> {
    post_request("/profile/update", &payload)
}

#[frb]
/// 拉取好友列表。
pub fn get_friend_list(query: FriendListQuery) -> Result<FriendListResult, String> {
    get_request("/friends", &query)
}

#[frb]
/// 分页拉取群成员列表。
pub fn get_group_members(query: GroupMembersQuery) -> Result<GroupMembersResult, String> {
    let path = format!("/groups/{}/members", query.group_id);
    let params = GroupMembersQueryParams {
        session_token: query.session_token,
        page: query.page,
        page_size: query.page_size,
    };
    get_request(&path, &params)
}

#[frb]
/// 获取群成员详情并判断是否为好友关系。
pub fn get_group_member_detail(
    query: GroupMemberDetailQuery,
) -> Result<GroupMemberDetailResult, String> {
    let path = format!("/groups/{}/members/{}", query.group_id, query.member_id);
    let params = SessionTokenQuery {
        session_token: query.session_token,
    };
    get_request(&path, &params)
}

#[frb]
/// 搜索用户（支持多种 search_type）。
pub fn search_user(query: SearchUserQuery) -> Result<SearchUserResult, String> {
    get_request("/users/search", &query)
}

#[frb]
/// 获取最近会话列表（带游标）。
pub fn get_recent_conversations(
    query: RecentConversationsQuery,
) -> Result<RecentConversationsResult, String> {
    get_request("/conversations/recent", &query)
}

/// 调用登录接口并写入本地登录状态。
fn perform_login(payload: &LoginRequest) -> Result<(LoginResult, i64), String> {
    let login_result = post_request::<LoginRequest, LoginResult>("/login", payload)?;
    let auth_message_id = auth_service::handle_login(payload, &login_result)
        .map_err(|err| ApiError::system(err).into_string())?;
    Ok((login_result, auth_message_id))
}

/// 等待 socket 鉴权应答完成，轮询数据库消息的 ack 状态。
fn wait_for_auth_ack(message_id: i64, timeout: Duration) -> Result<(), String> {
    let deadline = Instant::now() + timeout;
    while Instant::now() < deadline {
        if let Some(entity) = MessageService::get()
            .find_by_id(message_id)
            .map_err(|err| ApiError::system(err).into_string())?
        {
            if entity.ack_status {
                return Ok(());
            }
        }
        thread::sleep(Duration::from_millis(200));
    }
    Err(ApiError::timeout("socket 鉴权应答超时").into_string())
}
#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct GroupMembersQueryParams {
    session_token: String,
    page: Option<u32>,
    page_size: Option<u32>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct SessionTokenQuery {
    session_token: String,
}

pub(crate) fn reload_http_client(base_url: String) -> Result<(), String> {
    client::reload_app_api_client(base_url)
}
