use flutter_rust_bridge::frb;

use crate::{
    api::FriendRequestPageResult,
    api::app_api_types::{FriendRequestDecisionRequest, OperationStatus},
    api::utils::post_request,
    generated::message::FriendRequestDecisionPayload,
    service::{
        friend_request_service::FriendRequestService, socket_client::SocketClient,
        user_service::UserService,
    },
};
use std::time::{SystemTime, UNIX_EPOCH};

/// 分页获取本地已同步的好友申请记录。
#[frb]
pub fn get_friend_request_page(
    page: u32,
    page_size: u32,
) -> Result<FriendRequestPageResult, String> {
    FriendRequestService::get()
        .list(page, page_size)
        .map(FriendRequestPageResult::from)
}

#[frb]
/// 同意好友申请。
pub fn accept_friend_request(
    request_id: u64,
    from_uid: i64,
    remark: Option<String>,
    nickname: Option<String>,
) -> Result<OperationStatus, String> {
    decide_friend_request(request_id, from_uid, true, remark, nickname)
}

#[frb]
/// 拒绝好友申请。
pub fn reject_friend_request(
    request_id: u64,
    from_uid: i64,
    remark: Option<String>,
) -> Result<OperationStatus, String> {
    decide_friend_request(request_id, from_uid, false, remark, None)
}

fn decide_friend_request(
    request_id: u64,
    from_uid: i64,
    accepted: bool,
    remark: Option<String>,
    nickname: Option<String>,
) -> Result<OperationStatus, String> {
    let user = UserService::get()
        .latest_user()?
        .ok_or_else(|| "no cached user".to_string())?;
    let session_token = user
        .session_token
        .ok_or_else(|| "missing session_token".to_string())?;
    let body = FriendRequestDecisionRequest {
        session_token,
        request_id,
        from_uid,
        accepted,
        remark: remark.clone(),
        nickname: nickname.clone(),
    };
    let resp: OperationStatus = post_request("/friends/requests/decision", &body)?;

    // 本地更新申请状态，便于 UI 立即刷新。
    let decided_at = current_millis();
    let decision_payload = FriendRequestDecisionPayload {
        request_id,
        accepted,
        remark: remark.unwrap_or_default(),
        decided_at,
        send_default_message: accepted,
        default_message: String::new(),
        nickname: nickname.unwrap_or_default(),
    };
    FriendRequestService::get().apply_decision(
        &decision_payload,
        user.uid,
        from_uid,
        decision_payload.decided_at,
    )?;
    // 同步标记 socket 连接成功，避免等待心跳。
    let _ = SocketClient::get().status();
    Ok(resp)
}

fn current_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or_default()
}
