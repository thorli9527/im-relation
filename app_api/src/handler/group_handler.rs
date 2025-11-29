use axum::{extract::Path, routing::post, Json, Router};
use common::core::errors::AppError;
use common::core::result::ApiResponse;
use common::infra::grpc::grpc_group::group_service::GroupInfo;
use common::infra::grpc::grpc_user::online_service::GetUserReq;

use crate::handler::user_handler_types::{
    AddGroupRequest, AddGroupResult, GroupInfoResult, GroupMemberDetailResult, GroupMemberPath,
    GroupMemberResult, GroupMembersQuery, GroupMembersResult, GroupPath, SearchGroupQuery,
    SessionQuery,
};
use crate::handler::utils::{map_internal_error, map_session_error, success, HandlerResult};
use crate::service::{
    friend_gateway, group_gateway, user_gateway,
    user_service::{self, UserService},
};

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

pub fn router() -> Router {
    Router::new()
        .route("/groups/{group_id}/members", post(get_group_members))
        .route(
            "/groups/{group_id}/members/{member_id}",
            post(get_group_member_detail),
        )
        .route("/groups/search", post(search_group))
        .route("/groups/join", post(add_group))
}

#[utoipa::path(
    post,
    path = "/groups/{group_id}/members",
    params(
        ("group_id" = i64, Path, description = "Group id")
    ),
    request_body = GroupMembersQuery,
    responses(
        (status = 200, description = "群成员列表", body = ApiResponse<GroupMembersResult>)
    ),
    tag = "app_api/group"
)]
pub async fn get_group_members(
    Path(path): Path<GroupPath>,
    Json(query): Json<GroupMembersQuery>,
) -> HandlerResult<GroupMembersResult> {
    if query.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    if path.group_id <= 0 {
        return Err(AppError::Validation("group_id must be positive".into()));
    }

    let page = query.page.unwrap_or(1).max(1);
    let page_size = query.page_size.unwrap_or(20).max(1);

    user_service::ensure_active_session(&query.session_token)
        .await
        .map_err(map_session_error)?;

    let page_data = group_gateway::list_members(path.group_id, page, page_size)
        .await
        .map_err(map_internal_error)?;

    let mut user_client = user_gateway::get_user_rpc_client()
        .await
        .map_err(map_internal_error)?;

    let mut members = Vec::with_capacity(page_data.members.len());
    for member in page_data.members {
        let user = user_client
            .find_user_by_id(GetUserReq { id: member.id })
            .await
            .map_err(map_internal_error)?
            .into_inner();

        let nickname = member
            .nickname
            .and_then(normalize_optional_string)
            .unwrap_or_else(|| user.nickname.clone().unwrap_or(user.name.clone()));

        let summary = GroupMemberResult {
            group_id: path.group_id,
            member_id: member.id,
            nickname,
            avatar: user.avatar.clone(),
            role: member.role,
        };
        members.push(summary);
    }

    success(GroupMembersResult {
        members,
        page,
        page_size,
        has_more: page_data.has_more,
    })
}

#[utoipa::path(
    post,
    path = "/groups/{group_id}/members/{member_id}",
    params(
        ("group_id" = i64, Path, description = "Group id"),
        ("member_id" = i64, Path, description = "Member id")
    ),
    request_body = SessionQuery,
    responses(
        (status = 200, description = "群成员详情", body = ApiResponse<GroupMemberDetailResult>)
    ),
    tag = "app_api/group"
)]
pub async fn get_group_member_detail(
    Path(path): Path<GroupMemberPath>,
    Json(query): Json<SessionQuery>,
) -> HandlerResult<GroupMemberDetailResult> {
    if query.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    if path.group_id <= 0 || path.member_id <= 0 {
        return Err(AppError::Validation(
            "group_id/member_id must be positive".into(),
        ));
    }

    let active = user_service::ensure_active_session(&query.session_token)
        .await
        .map_err(map_session_error)?;

    let member = group_gateway::find_member(path.group_id, path.member_id)
        .await
        .map_err(map_internal_error)?
        .ok_or(AppError::NotFound)?;

    let is_friend = friend_gateway::is_friend(active.uid, member.id)
        .await
        .unwrap_or(false);

    let mut client = user_gateway::get_user_rpc_client()
        .await
        .map_err(map_internal_error)?;
    let user = client
        .find_user_by_id(GetUserReq { id: member.id })
        .await
        .map_err(map_internal_error)?
        .into_inner();

    let detail = GroupMemberResult {
        group_id: path.group_id,
        member_id: member.id,
        nickname: member
            .nickname
            .and_then(normalize_optional_string)
            .unwrap_or_else(|| user.nickname.clone().unwrap_or(user.name.clone())),
        avatar: user.avatar,
        role: member.role,
    };
    success(GroupMemberDetailResult {
        member: Some(detail),
        is_friend,
    })
}

#[utoipa::path(
    post,
    path = "/groups/search",
    request_body = SearchGroupQuery,
    responses(
        (status = 200, description = "查找群组", body = ApiResponse<GroupInfoResult>)
    ),
    tag = "app_api/group"
)]
pub async fn search_group(Json(payload): Json<SearchGroupQuery>) -> HandlerResult<GroupInfoResult> {
    let trimmed = payload.query.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("query is required".into()));
    }
    let group = match payload.search_type {
        1 => {
            let gid: i64 = trimmed
                .parse()
                .map_err(|_| AppError::Validation("invalid group_id".into()))?;
            group_gateway::get_group(gid).await
        }
        2 => group_gateway::find_group_by_name(trimmed).await,
        _ => unreachable!(),
    }
    .map_err(map_internal_error)?;

    success(group_info_to_result(group))
}

#[utoipa::path(
    post,
    path = "/groups/join",
    request_body = AddGroupRequest,
    responses(
        (status = 200, description = "加群（自动或申请）", body = ApiResponse<AddGroupResult>)
    ),
    tag = "app_api/group"
)]
pub async fn add_group(Json(payload): Json<AddGroupRequest>) -> HandlerResult<AddGroupResult> {
    if payload.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    if payload.group_id <= 0 {
        return Err(AppError::Validation("group_id must be positive".into()));
    }
    let svc = UserService::get();
    let applied = svc
        .add_group_http(
            &payload.session_token,
            payload.group_id,
            payload.reason.as_deref(),
        )
        .await
        .map_err(map_internal_error)?;
    success(AddGroupResult { ok: true, applied })
}

fn group_info_to_result(info: GroupInfo) -> GroupInfoResult {
    GroupInfoResult {
        id: info.id,
        name: info.name,
        avatar: info.avatar,
        description: info.description,
        notice: info.notice,
        join_permission: info.join_permission,
        owner_id: info.owner_id,
        member_cnt: info.member_cnt,
        allow_search: info.allow_search,
        enable: info.enable,
        group_type: info.group_type,
        create_time: info.create_time,
        update_time: info.update_time,
    }
}
