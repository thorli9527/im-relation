use serde::{Deserialize, Serialize};

use crate::api::utils;

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
