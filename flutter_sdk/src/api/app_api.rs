use std::{
    thread,
    time::{Duration, Instant},
};

use flutter_rust_bridge::frb;
use log::{error, info};
use serde::de::DeserializeOwned;
use serde::Serialize;
use uuid::Uuid;

use crate::api::{client, config_api};
use crate::service::{
    auth_service, config_service::ConfigService, message_service::MessageService,
    socket_client::SocketClient,
};
use crate::{common::db, domain, service};

include!("app_api_types.rs");

#[frb(init)]
pub fn init_app() -> Result<(), String> {
    db::init().map_err(|err| err.to_string())?;
    domain::init();
    service::init();
    let config_service = ConfigService::get();
    let configs = config_service.list_all()?;
    let has_device_id = configs.iter().any(|cfg| cfg.code == "device_id");
    if !has_device_id {
        let device_id = Uuid::new_v4().to_string();
        config_service.upsert_value("device_id", &device_id)?;
    }
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
    // client::with_app_api_client(|client| client.post_json(path, body))
}

fn get_request<TReq, TResp>(path: &str, params: &TReq) -> Result<TResp, String>
where
    TReq: Serialize + ?Sized,
    TResp: DeserializeOwned,
{
    client::with_app_api_client(|client| client.get_json(path, params))
}

#[frb]
pub fn build_register_code(
    payload: BuildRegisterCodeRequest,
) -> Result<BuildRegisterCodeResponse, String> {
    post_request("/register/code", &payload)
}

#[frb]
pub fn verify_register_code(payload: VerifyRegisterCodeRequest) -> Result<OperationStatus, String> {
    post_request("/register/verify", &payload)
}

#[frb]
pub fn login(payload: LoginRequest, timeout_secs: Option<u64>) -> Result<LoginResult, String> {
    let (result, auth_message_id) = perform_login(&payload).map_err(|err| {
        error!("login_and_wait_for_socket: login failed: {}", err);
        err
    })?;
    let receiver = SocketClient::get().subscribe_connection_success();
    let duration = Duration::from_secs(timeout_secs.unwrap_or(30));
    receiver
        .recv_timeout(duration)
        .map_err(|_| "socket connection timeout".to_string())?;
    info!("socket 连接成功，正在等待鉴权...");
    wait_for_auth_ack(auth_message_id, Duration::from_secs(30))?;
    info!("基础鉴权已完成");
    Ok(result)
}

#[frb]
pub fn logout() -> Result<(), String> {
    auth_service::logout()
}

#[frb]
pub fn validate_session(
    payload: SessionValidateRequest,
) -> Result<SessionValidationResult, String> {
    post_request("/session/validate", &payload)
}

#[frb]
pub fn change_password(payload: ChangePasswordRequest) -> Result<OperationStatus, String> {
    post_request("/password/change", &payload)
}

#[frb]
pub fn change_phone(payload: ChangePhoneRequest) -> Result<ChangePhoneResult, String> {
    post_request("/phone/change", &payload)
}

#[frb]
pub fn change_email(payload: ChangeEmailRequest) -> Result<ChangeEmailResult, String> {
    post_request("/email/change", &payload)
}

#[frb]
pub fn update_profile(payload: UpdateProfileRequest) -> Result<OperationStatus, String> {
    post_request("/profile/update", &payload)
}

#[frb]
pub fn get_friend_list(query: FriendListQuery) -> Result<FriendListResult, String> {
    get_request("/friends", &query)
}

#[frb]
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
pub fn search_user(query: SearchUserQuery) -> Result<SearchUserResult, String> {
    get_request("/users/search", &query)
}

#[frb]
pub fn get_recent_conversations(
    query: RecentConversationsQuery,
) -> Result<RecentConversationsResult, String> {
    get_request("/conversations/recent", &query)
}

fn perform_login(payload: &LoginRequest) -> Result<(LoginResult, i64), String> {
    let login_result = post_request::<LoginRequest, LoginResult>("/login", payload)?;
    let auth_message_id = auth_service::handle_login(payload, &login_result)?;
    Ok((login_result, auth_message_id))
}

fn wait_for_auth_ack(message_id: i64, timeout: Duration) -> Result<(), String> {
    let deadline = Instant::now() + timeout;
    while Instant::now() < deadline {
        if let Some(entity) = MessageService::get().find_by_id(message_id)? {
            if entity.ack_status {
                return Ok(());
            }
        }
        thread::sleep(Duration::from_millis(200));
    }
    Err("socket 鉴权应答超时".to_string())
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
