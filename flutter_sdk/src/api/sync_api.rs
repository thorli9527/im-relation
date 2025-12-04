use serde::{Deserialize, Serialize};

use crate::{
    api::utils,
    domain::sync_state_entity::SyncStateEntity,
    service::{sync_state_service::SyncStateService, user_service::UserService},
};

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SyncRequest {
    /// 会话 token，用于鉴权
    pub session_token: String,
    /// 好友消息游标（毫秒时间戳）
    pub friend_last_seq: Option<i64>,
    /// 群消息游标（毫秒时间戳）
    pub group_last_seq: Option<i64>,
    /// 系统消息游标（message_id）
    pub system_last_seq: Option<u64>,
    /// 拉取条数上限
    pub limit: Option<u32>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SyncResponse {
    /// Base64 编码的好友消息列表
    pub friend_messages: Vec<String>,
    /// Base64 编码的群消息列表
    pub group_messages: Vec<String>,
    /// Base64 编码的系统消息列表
    pub system_messages: Vec<String>,
}

/// 调用后端同步接口，返回增量消息（Base64 编码的 Content）。
pub fn sync_messages(req: &SyncRequest) -> Result<SyncResponse, String> {
    utils::post_request("/api/sync/messages", req)
}

/// 基于本地游标和当前用户 session 构造同步请求；返回请求体与游标状态。
pub fn build_sync_request_from_state(limit: Option<u32>) -> Result<(SyncRequest, SyncStateEntity), String> {
    let state = SyncStateService::fetch().unwrap_or_else(|_| {
        SyncStateService::ensure_row()
            .and_then(|_| SyncStateService::fetch())
            .unwrap_or_else(|_| SyncStateEntity::new())
    });
    let token = UserService::get()
        .latest_user()
        .map_err(|e| e.to_string())?
        .and_then(|u| u.session_token)
        .ok_or_else(|| "session_token missing".to_string())?;
    let req = SyncRequest {
        session_token: token,
        friend_last_seq: Some(state.friend_last_seq),
        group_last_seq: Some(state.group_last_seq),
        system_last_seq: Some(state.system_last_seq as u64),
        limit: limit.or(Some(200)),
    };
    Ok((req, state))
}
