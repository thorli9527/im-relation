use std::time::Duration;

use flutter_rust_bridge::frb;
use log::{error, info};
use serde::de::DeserializeOwned;
use serde::Serialize;

use crate::api::app_api_types::*;
use crate::api::errors::ApiError;
use crate::common::client;
use crate::service::{auth_service, socket_client::SocketClient, user_service::UserService};

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



pub fn build_register_code(
    payload: BuildRegisterCodeRequest,
) -> Result<BuildRegisterCodeResponse, String> {
    post_request("/register/code", &payload)
}

pub fn verify_register_code(payload: VerifyRegisterCodeRequest) -> Result<OperationStatus, String> {
    post_request("/register/verify", &payload)
}
#[frb]
pub fn login(payload: LoginRequest, timeout_secs: Option<u64>) -> Result<LoginResult, String> {
    let (result, _) = perform_login(&payload).map_err(|err| {
        error!("login_and_wait_for_socket: login failed: {}", err);
        err
    })?;
    let receiver = SocketClient::get().subscribe_connection_success();
    let duration = Duration::from_secs(timeout_secs.unwrap_or(30));
    receiver
        .recv_timeout(duration)
        .map_err(|_| ApiError::timeout("socket connection timeout").into_string())?;
    info!("socket 鉴权已完成");
    Ok(result)
}

pub fn logout() -> Result<(), String> {
    if let Some(user) = UserService::get().latest_user()? {
        if let Some(token) = user.session_token {
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
            }
        }
    }

    auth_service::logout().map_err(|err| ApiError::system(err).into_string())
}

pub fn validate_session(
    payload: SessionValidateRequest,
) -> Result<SessionValidationResult, String> {
    post_request("/session/validate", &payload)
}

pub fn change_password(payload: ChangePasswordRequest) -> Result<OperationStatus, String> {
    post_request("/password/change", &payload)
}

pub fn change_phone(payload: ChangePhoneRequest) -> Result<ChangePhoneResult, String> {
    post_request("/phone/change", &payload)
}

pub fn change_email(payload: ChangeEmailRequest) -> Result<ChangeEmailResult, String> {
    post_request("/email/change", &payload)
}

pub fn update_profile(payload: UpdateProfileRequest) -> Result<OperationStatus, String> {
    post_request("/profile/update", &payload)
}

pub fn get_friend_list(query: FriendListQuery) -> Result<FriendListResult, String> {
    get_request("/friends", &query)
}



pub fn search_user(query: SearchUserQuery) -> Result<SearchUserResult, String> {
    get_request("/users/search", &query)
}

pub fn get_recent_conversations(
    query: RecentConversationsQuery,
) -> Result<RecentConversationsResult, String> {
    get_request("/conversations/recent", &query)
}

pub fn fetch_random_nickname(gender: Option<String>) -> Result<String, String> {
    let query = RandomNicknameQuery { gender };
    get_request("/nickname/random", &query)
}

/// 调用登录接口并写入本地登录状态。
fn perform_login(payload: &LoginRequest) -> Result<(LoginResult, i64), String> {
    let login_result = post_request::<LoginRequest, LoginResult>("/login", payload)?;
    let auth_message_id = auth_service::handle_login(payload, &login_result)
        .map_err(|err| ApiError::system(err).into_string())?;
    Ok((login_result, auth_message_id))
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersQueryParams {
    pub session_token: String,
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SessionTokenQuery {
    pub session_token: String,
}

pub(crate) fn reload_http_client(base_url: String) -> Result<(), String> {
    client::reload_app_api_client(base_url)
}
/// 通用 POST 请求封装。
pub(crate) fn post_request<TReq, TResp>(path: &str, body: &TReq) -> Result<TResp, String>
where
    TReq: Serialize + ?Sized,
    TResp: DeserializeOwned,
{
    client::with_app_api_client(|client| client.post_json(path, body))
}

/// 通用 GET 请求封装。
pub(crate) fn get_request<TReq, TResp>(path: &str, params: &TReq) -> Result<TResp, String>
where
    TReq: Serialize + ?Sized,
    TResp: DeserializeOwned,
{
    client::with_app_api_client(|client| client.get_json(path, params))
}