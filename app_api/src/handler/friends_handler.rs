use axum::{routing::post, Json, Router};
use common::core::errors::AppError;
use common::core::result::ApiResponse;
use common::infra::grpc::grpc_user::online_service::{FindByContentReq, GetUserReq, UserEntity};
use serde::{Deserialize, Serialize};
use std::convert::TryFrom;
use tonic::Code;
use utoipa::ToSchema;

use crate::handler::user_handler_types::{
    AddFriendRequest, AddFriendResult, FriendListQuery, FriendListResult, FriendSummaryResult,
    OperationStatus, SearchUserQuery, SearchUserResult, UserProfileResult,
};
use crate::handler::utils::{map_internal_error, map_session_error, success, HandlerResult};
use crate::service::{
    friend_gateway, message_gateway, user_gateway, user_service, user_service::UserService,
};
use common::infra::grpc::message as msgpb;

fn normalize_optional_string(value: String) -> Option<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        None
    } else if trimmed.len() == value.len() {
        Some(value)
    } else {
        Some(trimmed.to_string())
    }
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct FriendRequestQuery {
    pub session_token: String,
    #[serde(default)]
    pub since_ms: Option<i64>,
    #[serde(default)]
    pub limit: Option<u32>,
}

#[derive(Debug, Deserialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct FriendRequestDecisionDto {
    pub session_token: String,
    pub request_id: u64,
    pub from_uid: i64,
    pub accepted: bool,
    #[serde(default)]
    pub remark: Option<String>,
    #[serde(default)]
    pub nickname: Option<String>,
}

#[derive(Debug, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct FriendRequestListResult {
    pub requests: Vec<String>,
    pub decisions: Vec<String>,
}

pub fn router() -> Router {
    Router::new()
        .route("/friends", post(get_friend_list))
        .route("/friends/add", post(add_friend))
        .route("/friends/requests", post(list_friend_requests))
        .route("/friends/requests/decision", post(decide_friend_request))
        .route("/users/search", post(search_user))
}

#[utoipa::path(
    post,
    path = "/friends",
    request_body = FriendListQuery,
    responses(
        (status = 200, description = "好友列表", body = ApiResponse<FriendListResult>)
    ),
    tag = "app_api/friends"
)]
pub async fn get_friend_list(
    Json(params): Json<FriendListQuery>,
) -> HandlerResult<FriendListResult> {
    let page = params.page.unwrap_or(1).max(1);
    let page_size = params.page_size.unwrap_or(20).max(1);
    if params.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }

    let active_session = user_service::ensure_active_session(&params.session_token)
        .await
        .map_err(map_session_error)?;

    let entries = friend_gateway::get_friends_page_detailed(active_session.uid, page, page_size)
        .await
        .map_err(map_internal_error)?;

    if entries.is_empty() {
        return success(FriendListResult {
            friends: Vec::new(),
            page,
            page_size,
            has_more: false,
        });
    }

    let mut user_client = user_gateway::get_user_rpc_client()
        .await
        .map_err(map_internal_error)?;

    let mut friends = Vec::with_capacity(entries.len());
    for entry in entries {
        let friend_id = entry.friend_id;
        let user = user_client
            .find_user_by_id(GetUserReq { id: friend_id })
            .await
            .map_err(map_internal_error)?
            .into_inner();

        let nickname = user.name;
        let avatar = entry
            .avatar
            .and_then(normalize_optional_string)
            .unwrap_or_else(|| user.avatar.clone());

        let remark = entry.remark.and_then(normalize_optional_string);

        friends.push(FriendSummaryResult {
            friend_id,
            nickname,
            avatar,
            remark,
        });
    }

    let has_more = page_size > 0 && friends.len() as u32 == page_size;

    success(FriendListResult {
        friends,
        page,
        page_size,
        has_more,
    })
}

#[utoipa::path(
    post,
    path = "/friends/add",
    request_body = AddFriendRequest,
    responses(
        (status = 200, description = "添加好友", body = ApiResponse<AddFriendResult>)
    ),
    tag = "app_api/friends"
)]
pub async fn add_friend(Json(payload): Json<AddFriendRequest>) -> HandlerResult<AddFriendResult> {
    if payload.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    if payload.target_uid <= 0 {
        return Err(AppError::Validation("target_uid must be positive".into()));
    }
    let source = msgpb::FriendRequestSource::try_from(payload.source)
        .map_err(|_| AppError::Validation("invalid source".into()))?;
    let applied = UserService::get()
        .add_friend_http(
            &payload.session_token,
            payload.target_uid,
            payload.reason.as_deref(),
            payload.remark.as_deref(),
            payload.nickname.as_deref(),
            source as i32,
        )
        .await
        .map_err(|e| {
            // 记录堆栈，便于排查
            log::error!("add_friend error: {:?}", e);
            map_internal_error(e)
        })?;
    success(AddFriendResult { ok: true, applied })
}

#[utoipa::path(
    post,
    path = "/friends/requests",
    request_body = FriendRequestQuery,
    responses(
        (status = 200, description = "好友申请增量", body = ApiResponse<FriendRequestListResult>)
    ),
    tag = "app_api/friends"
)]
pub async fn list_friend_requests(
    Json(query): Json<FriendRequestQuery>,
) -> HandlerResult<FriendRequestListResult> {
    if query.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    let active = user_service::ensure_active_session(&query.session_token)
        .await
        .map_err(map_internal_error)?;
    let limit = query.limit.unwrap_or(200);
    let msgs = message_gateway::list_user_friend_messages(active.uid, query.since_ms, limit)
        .await
        .map_err(map_internal_error)?;

    let mut request_msgs = Vec::new();
    let mut decision_msgs = Vec::new();
    for m in msgs {
        if let Some(biz) = &m.friend_business {
            if let Some(action) = &biz.action {
                match action {
                    msgpb::friend_business_content::Action::Request(_) => {
                        request_msgs.push(m.clone())
                    }
                    msgpb::friend_business_content::Action::Decision(_) => {
                        decision_msgs.push(m.clone())
                    }
                }
            }
        }
    }

    let requests = message_gateway::encode_messages(request_msgs);
    let decisions = message_gateway::encode_messages(decision_msgs);

    success(FriendRequestListResult {
        requests,
        decisions,
    })
}

#[utoipa::path(
    post,
    path = "/friends/requests/decision",
    request_body = FriendRequestDecisionDto,
    responses(
        (status = 200, description = "处理好友申请", body = ApiResponse<OperationStatus>)
    ),
    tag = "app_api/friends"
)]
pub async fn decide_friend_request(
    Json(query): Json<FriendRequestDecisionDto>,
) -> HandlerResult<OperationStatus> {
    let active = user_service::ensure_active_session(&query.session_token)
        .await
        .map_err(map_session_error)?;
    if active.uid == query.from_uid {
        return Err(AppError::Validation("cannot decide self request".into()));
    }
    let nickname_opt = if let Some(nick) = query.nickname.as_deref() {
        Some(nick.to_string())
    } else {
        let mut client = user_gateway::get_user_rpc_client()
            .await
            .map_err(map_internal_error)?;
        let user = client
            .find_user_by_id(GetUserReq { id: query.from_uid })
            .await
            .map_err(map_internal_error)?
            .into_inner();
        let nick = user.nickname;
        (!nick.is_empty())
            .then_some(nick)
            .or_else(|| Some(user.name))
    };

    user_service::UserService::get()
        .decide_friend_request(
            active.uid,
            query.from_uid,
            query.request_id as i64,
            query.accepted,
            query.remark.as_deref(),
            nickname_opt.as_deref(),
        )
        .await
        .map_err(map_internal_error)?;
    success(OperationStatus { ok: true })
}

#[utoipa::path(
    post,
    path = "/users/search",
    request_body = SearchUserQuery,
    responses(
        (status = 200, description = "查找用户", body = ApiResponse<SearchUserResult>)
    ),
    tag = "app_api/friends"
)]
pub async fn search_user(Json(query): Json<SearchUserQuery>) -> HandlerResult<SearchUserResult> {
    let trimmed = query.query.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("query is required".into()));
    }
    let mut user_client = user_gateway::get_user_rpc_client()
        .await
        .map_err(map_internal_error)?;

    let mut user_entity: Option<UserEntity> = None;
    let is_email = trimmed.contains('@');
    let is_numeric = trimmed.chars().all(|c| c.is_ascii_digit());

    if is_email {
        let resp = user_client
            .find_by_email(FindByContentReq {
                content: trimmed.to_string(),
            })
            .await;
        match resp {
            Ok(resp) => user_entity = resp.into_inner().user,
            Err(status) if status.code() == Code::NotFound => user_entity = None,
            Err(status) => return Err(map_internal_error(status)),
        }
    } else if is_numeric {
        if let Ok(id) = trimmed.parse::<i64>() {
            match user_client.find_user_by_id(GetUserReq { id }).await {
                Ok(resp) => user_entity = Some(resp.into_inner()),
                Err(status) if status.code() == Code::NotFound => user_entity = None,
                Err(status) => return Err(map_internal_error(status)),
            }
        }
        if user_entity.is_none() {
            let resp = user_client
                .find_by_phone(FindByContentReq {
                    content: trimmed.to_string(),
                })
                .await;
            match resp {
                Ok(resp) => user_entity = resp.into_inner().user,
                Err(status) if status.code() == Code::NotFound => user_entity = None,
                Err(status) => return Err(map_internal_error(status)),
            }
        }
    } else {
        let resp = user_client
            .find_by_name(FindByContentReq {
                content: trimmed.to_string(),
            })
            .await;
        match resp {
            Ok(resp) => user_entity = resp.into_inner().user,
            Err(status) if status.code() == Code::NotFound => user_entity = None,
            Err(status) => return Err(map_internal_error(status)),
        }
    }

    let profile = user_entity.map(user_entity_to_profile);

    success(SearchUserResult { user: profile })
}

fn user_entity_to_profile(entity: UserEntity) -> UserProfileResult {
    let signature = entity
        .profile_fields
        .get("signature")
        .map(|s| s.to_string());
    let region = entity.profile_fields.get("region").map(|s| s.to_string());
    UserProfileResult {
        uid: entity.id,
        username: entity.name,
        avatar: entity.avatar,
        email: entity.email,
        phone: entity.phone,
        nickname: entity.nickname,
        signature,
        region,
        add_friend_policy: entity.allow_add_friend,
    }
}
