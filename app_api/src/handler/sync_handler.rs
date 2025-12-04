use axum::{routing::post, Json, Router};
use serde::Deserialize;
use utoipa::ToSchema;

use crate::service::{message_gateway, user_service};
use common::core::{errors::AppError, result::ApiResponse};

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SyncQuery {
    pub session_token: String,
    #[serde(default)]
    pub friend_last_seq: Option<i64>,
    #[serde(default)]
    pub group_last_seq: Option<i64>,
    #[serde(default)]
    pub system_last_seq: Option<u64>,
    #[serde(default)]
    pub limit: Option<u32>,
}

#[derive(Debug, serde::Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SyncPayload {
    pub friend_messages: Vec<String>,
    pub group_messages: Vec<String>,
    pub system_messages: Vec<String>,
}

pub fn router() -> Router {
    Router::new().route("/api/sync/messages", post(sync_messages))
}

#[utoipa::path(
    post,
    path = "/api/sync/messages",
    request_body = SyncQuery,
    responses(
        (status = 200, description = "增量同步好友/群/系统消息", body = ApiResponse<SyncPayload>)
    ),
    tag = "app_api/sync"
)]
async fn sync_messages(
    Json(q): Json<SyncQuery>,
) -> Result<Json<ApiResponse<SyncPayload>>, AppError> {
    if q.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    let limit = q.limit.unwrap_or(200);
    let active: user_service::ActiveSession = user_service::ensure_active_session(&q.session_token)
        .await
        .map_err(|e| AppError::Validation(e.to_string()))?;
    let uid = active.uid;

    // Friend incremental：使用 msg_friend 的 since_timestamp 能力，last_seq 按时间戳传入。
    let friend_msgs = if let Some(seq) = q.friend_last_seq {
        message_gateway::list_user_friend_messages(uid, Some(seq), limit)
            .await
            .unwrap_or_default()
    } else {
        Vec::new()
    };

    // Group incremental：当前接口不支持 after 拉取，退化为近期窗口过滤。
    let group_msgs = if let Some(seq) = q.group_last_seq {
        message_gateway::list_group_messages(uid, seq, limit)
            .await
            .unwrap_or_default()
    } else {
        Vec::new()
    };

    // System incremental：按 message_id 过滤，取较大的 window。
    let system_msgs = if let Some(seq) = q.system_last_seq {
        message_gateway::list_system_messages(uid, None, None, limit * 2)
            .await
            .unwrap_or_default()
            .messages
            .into_iter()
            .filter(|m| m.message_id.unwrap_or(0) > seq)
            .collect()
    } else {
        Vec::new()
    };

    Ok(Json(ApiResponse::success(SyncPayload {
        friend_messages: message_gateway::encode_messages(friend_msgs),
        group_messages: message_gateway::encode_messages(group_msgs),
        system_messages: message_gateway::encode_messages(system_msgs),
    })))
}
