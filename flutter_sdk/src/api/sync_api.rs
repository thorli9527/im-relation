use serde::{Deserialize, Serialize};

use crate::api::utils;

#[derive(Debug, Serialize)]
pub struct SyncRequest {
    pub session_token: String,
    #[serde(rename = "friend_last_seq", skip_serializing_if = "Option::is_none")]
    pub friend_last_seq: Option<i64>,
    #[serde(rename = "group_last_seq", skip_serializing_if = "Option::is_none")]
    pub group_last_seq: Option<i64>,
    #[serde(rename = "system_last_seq", skip_serializing_if = "Option::is_none")]
    pub system_last_seq: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub limit: Option<u32>,
}

#[derive(Debug, Deserialize)]
pub struct SyncResponse {
    pub friend_messages: Vec<String>,
    pub group_messages: Vec<String>,
    pub system_messages: Vec<String>,
}

pub fn sync_messages(req: &SyncRequest) -> Result<SyncResponse, String> {
    utils::post_request("/api/sync/messages", req)
}
