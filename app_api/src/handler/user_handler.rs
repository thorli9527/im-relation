use axum::{extract::Path, routing::post, Json, Router};
use common::config::AppConfig;
use common::core::errors::AppError;
use common::core::result::ApiResponse;
use common::infra::grpc::grpc_group::group_service::GroupInfo;
use common::infra::grpc::grpc_user::online_service::{FindByContentReq, GetUserReq, UserEntity};
use common::support::util::common_utils::hash_index;
use serde::{Deserialize, Serialize};
use tonic::Code;
use utoipa::ToSchema;
use validator::Validate;

pub use crate::handler::user_handler_types::*;
use crate::handler::utils::{map_internal_error, map_session_error, success, HandlerResult};
use crate::service::{
    auth_models::{
        ChangeEmailRequestDto, ChangePasswordRequestDto, ChangePhoneRequestDto,
        UpdateProfileRequestDto,
    },
    friend_gateway, group_gateway, message_gateway, user_gateway,
    user_service::{self, UserService, UserServiceAuthOpt},
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

const SCENE_UNSPECIFIED: i32 = 0;
const SCENE_FRIEND: i32 = 1;
const SCENE_GROUP: i32 = 2;

pub fn router() -> Router {
    Router::new()
        .route("/password/change", post(change_password))
        .route("/phone/change", post(change_phone))
        .route("/email/change", post(change_email))
        .route("/profile/update", post(update_profile))
        .route("/profile/name", post(update_name))
        .route("/friends", post(get_friend_list))
        .route("/friends/add", post(add_friend))
        .route("/friends/requests", post(list_friend_requests))
        .route("/groups/{group_id}/members", post(get_group_members))
        .route(
            "/groups/{group_id}/members/{member_id}",
            post(get_group_member_detail),
        )
        .route("/users/search", post(search_user))
        .route("/groups/search", post(search_group))
        .route("/groups/join", post(add_group))
        .route("/conversations/recent", post(get_recent_conversations))
}

#[utoipa::path(
    post,
    path = "/password/change",
    request_body = ChangePasswordRequestDto,
    responses(
        (status = 200, description = "修改密码", body = ApiResponse<VerifyRegisterResult>)
    ),
    tag = "app_api/user"
)]
async fn change_password(
    Json(payload): Json<ChangePasswordRequestDto>,
) -> HandlerResult<VerifyRegisterResult> {
    payload.validate()?;
    UserService::get()
        .change_password(
            &payload.session_token,
            &payload.old_password,
            &payload.new_password,
        )
        .await
        .map_err(map_internal_error)?;

    success(VerifyRegisterResult { ok: true })
}

#[utoipa::path(
    post,
    path = "/phone/change",
    request_body = ChangePhoneRequestDto,
    responses(
        (status = 200, description = "更新手机号", body = ApiResponse<ChangePhoneResult>)
    ),
    tag = "app_api/user"
)]
async fn change_phone(
    Json(payload): Json<ChangePhoneRequestDto>,
) -> HandlerResult<ChangePhoneResult> {
    payload.validate()?;
    let phone = UserService::get()
        .change_phone(
            &payload.session_token,
            payload.old_phone_code.as_deref(),
            &payload.new_phone,
            &payload.new_phone_code,
        )
        .await
        .map_err(map_internal_error)?;

    success(ChangePhoneResult { ok: true, phone })
}

#[utoipa::path(
    post,
    path = "/email/change",
    request_body = ChangeEmailRequestDto,
    responses(
        (status = 200, description = "更新邮箱", body = ApiResponse<ChangeEmailResult>)
    ),
    tag = "app_api/user"
)]
async fn change_email(
    Json(payload): Json<ChangeEmailRequestDto>,
) -> HandlerResult<ChangeEmailResult> {
    payload.validate()?;
    let email = UserService::get()
        .change_email(
            &payload.session_token,
            payload.old_email_code.as_deref(),
            &payload.new_email,
            &payload.new_email_code,
        )
        .await
        .map_err(map_internal_error)?;

    success(ChangeEmailResult { ok: true, email })
}

#[utoipa::path(
    post,
    path = "/profile/update",
    request_body = UpdateProfileRequestDto,
    responses(
        (status = 200, description = "更新用户资料", body = ApiResponse<VerifyRegisterResult>)
    ),
    tag = "app_api/user"
)]
async fn update_profile(
    Json(payload): Json<UpdateProfileRequestDto>,
) -> HandlerResult<VerifyRegisterResult> {
    payload.validate()?;
    UserService::get()
        .update_profile(
            &payload.session_token,
            payload.gender,
            payload.avatar.as_deref(),
            payload.country.as_deref(),
            payload.language.as_deref(),
            payload.nickname.as_deref(),
        )
        .await
        .map_err(map_internal_error)?;

    success(VerifyRegisterResult { ok: true })
}

#[utoipa::path(
    post,
    path = "/profile/name",
    request_body = UpdateNameRequest,
    responses(
        (status = 200, description = "修改用户名", body = ApiResponse<UpdateNameResult>)
    ),
    tag = "app_api/user"
)]
async fn update_name(Json(payload): Json<UpdateNameRequest>) -> HandlerResult<UpdateNameResult> {
    if payload.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    let trimmed = payload.name.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("name is required".into()));
    }
    UserService::get()
        .update_name(&payload.session_token, trimmed)
        .await
        .map_err(map_internal_error)?;
    success(UpdateNameResult { ok: true })
}

#[utoipa::path(
    post,
    path = "/friends",
    request_body = FriendListQuery,
    responses(
        (status = 200, description = "好友列表", body = ApiResponse<FriendListResult>)
    ),
    tag = "app_api/user"
)]
async fn get_friend_list(Json(params): Json<FriendListQuery>) -> HandlerResult<FriendListResult> {
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
    path = "/groups/{group_id}/members",
    params(
        ("group_id" = i64, Path, description = "Group id")
    ),
    request_body = GroupMembersQuery,
    responses(
        (status = 200, description = "群成员列表", body = ApiResponse<GroupMembersResult>)
    ),
    tag = "app_api/user"
)]
async fn get_group_members(
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
    tag = "app_api/user"
)]
async fn get_group_member_detail(
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

    let mut user_client = user_gateway::get_user_rpc_client()
        .await
        .map_err(map_internal_error)?;
    let user = user_client
        .find_user_by_id(GetUserReq { id: member.id })
        .await
        .map_err(map_internal_error)?
        .into_inner();

    let nickname = member
        .nickname
        .and_then(normalize_optional_string)
        .unwrap_or(user.name.clone());

    let summary = GroupMemberResult {
        group_id: path.group_id,
        member_id: member.id,
        nickname,
        avatar: user.avatar,
        role: member.role,
    };

    let is_friend = friend_gateway::is_friend(active.uid, member.id)
        .await
        .map_err(map_internal_error)?;

    success(GroupMemberDetailResult {
        member: Some(summary),
        is_friend,
    })
}

#[utoipa::path(
    post,
    path = "/groups/search",
    request_body = SearchGroupQuery,
    responses(
        (status = 200, description = "搜索群（按 ID/名称）", body = ApiResponse<GroupInfoResult>)
    ),
    tag = "app_api/user"
)]
async fn search_group(Json(payload): Json<SearchGroupQuery>) -> HandlerResult<GroupInfoResult> {
    let trimmed = payload.query.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("query is required".into()));
    }
    if payload.search_type != 1 && payload.search_type != 2 {
        return Err(AppError::Validation("invalid search_type".into()));
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
    path = "/friends/add",
    request_body = AddFriendRequest,
    responses(
        (status = 200, description = "加好友（自动或申请）", body = ApiResponse<AddFriendResult>)
    ),
    tag = "app_api/user"
)]
async fn add_friend(Json(payload): Json<AddFriendRequest>) -> HandlerResult<AddFriendResult> {
    if payload.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }
    if payload.target_uid <= 0 {
        return Err(AppError::Validation("target_uid must be positive".into()));
    }
    let applied = UserService::get()
        .add_friend_http(
            &payload.session_token,
            payload.target_uid,
            payload.reason.as_deref(),
            payload.remark.as_deref(),
            payload.nickname.as_deref(),
        )
        .await
        .map_err(map_internal_error)?;
    success(AddFriendResult { ok: true, applied })
}

#[utoipa::path(
    post,
    path = "/groups/join",
    request_body = AddGroupRequest,
    responses(
        (status = 200, description = "加群（自动或申请）", body = ApiResponse<AddGroupResult>)
    ),
    tag = "app_api/user"
)]
async fn add_group(Json(payload): Json<AddGroupRequest>) -> HandlerResult<AddGroupResult> {
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

#[derive(Debug, Deserialize, ToSchema)]
struct FriendRequestQuery {
    pub session_token: String,
    #[serde(default)]
    pub since_ms: Option<i64>,
    #[serde(default)]
    pub limit: Option<u32>,
}

#[derive(Debug, Serialize, ToSchema)]
struct FriendRequestListResult {
    pub requests: Vec<String>,
    pub decisions: Vec<String>,
}

#[utoipa::path(
    post,
    path = "/friends/requests",
    request_body = FriendRequestQuery,
    responses(
        (status = 200, description = "好友申请增量", body = ApiResponse<FriendRequestListResult>)
    ),
    tag = "app_api/user"
)]
async fn list_friend_requests(
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
    path = "/users/search",
    request_body = SearchUserQuery,
    responses(
        (status = 200, description = "查找用户", body = ApiResponse<SearchUserResult>)
    ),
    tag = "app_api/user"
)]
async fn search_user(Json(query): Json<SearchUserQuery>) -> HandlerResult<SearchUserResult> {
    let trimmed = query.query.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation("query is required".into()));
    }
    let mut user_client = user_gateway::get_user_rpc_client()
        .await
        .map_err(map_internal_error)?;

    // 自动推断查询类型：邮箱 -> email；纯数字优先按 uid 查找，失败则按 phone；其它按用户名。
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
        // 先尝试按 uid。
        if let Ok(id) = trimmed.parse::<i64>() {
            match user_client.find_user_by_id(GetUserReq { id }).await {
                Ok(resp) => user_entity = Some(resp.into_inner()),
                Err(status) if status.code() == Code::NotFound => user_entity = None,
                Err(status) => return Err(map_internal_error(status)),
            }
        }
        // 如果未找到，再按 phone 查找。
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
        signature,
        region,
        add_friend_policy: entity.allow_add_friend,
    }
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

#[utoipa::path(
    post,
    path = "/conversations/recent",
    request_body = RecentConversationsQuery,
    responses(
        (status = 200, description = "最近会话", body = ApiResponse<RecentConversationsResult>)
    ),
    tag = "app_api/user"
)]
async fn get_recent_conversations(
    Json(query): Json<RecentConversationsQuery>,
) -> HandlerResult<RecentConversationsResult> {
    if query.session_token.trim().is_empty() {
        return Err(AppError::Validation("session_token is required".into()));
    }

    let active = user_service::ensure_active_session(&query.session_token)
        .await
        .map_err(map_session_error)?;

    let requested = query.limit.unwrap_or(20).max(1);
    let limit = requested.min(200);
    let fetch_limit = limit.saturating_add(1);

    let before_updated_at = query.before_updated_at.filter(|v| *v > 0);
    let before_scene = match query.before_scene {
        Some(value) if value == SCENE_FRIEND => SCENE_FRIEND,
        Some(value) if value == SCENE_GROUP => SCENE_GROUP,
        _ => SCENE_UNSPECIFIED,
    };

    let friend_before_id =
        if before_scene == SCENE_FRIEND && query.before_conversation_id.unwrap_or_default() > 0 {
            query.before_conversation_id
        } else {
            None
        };

    let group_before_id =
        if before_scene == SCENE_GROUP && query.before_conversation_id.unwrap_or_default() > 0 {
            query.before_conversation_id
        } else {
            None
        };

    let friend_page = message_gateway::list_friend_conversations(
        active.uid,
        fetch_limit,
        before_updated_at,
        friend_before_id,
    )
    .await
    .map_err(map_internal_error)?;

    let group_page = message_gateway::list_group_conversations(
        active.uid,
        fetch_limit,
        before_updated_at,
        group_before_id,
    )
    .await
    .map_err(map_internal_error)?;

    let mut conversations = Vec::with_capacity(
        friend_page
            .snapshots
            .len()
            .saturating_add(group_page.snapshots.len()),
    );

    for snap in friend_page.snapshots {
        conversations.push(RecentConversationResult {
            scene: SCENE_FRIEND,
            conversation_id: snap.conversation_id,
            target_id: snap.peer_id,
            last_msg_id: snap.last_msg_id,
            last_sender_id: snap.last_sender_id,
            last_timestamp: snap.last_timestamp,
            unread_count: snap.unread_count,
            updated_at: snap.updated_at,
        });
    }

    for snap in group_page.snapshots {
        conversations.push(RecentConversationResult {
            scene: SCENE_GROUP,
            conversation_id: snap.group_id,
            target_id: snap.group_id,
            last_msg_id: snap.last_msg_id,
            last_sender_id: snap.last_sender_id,
            last_timestamp: snap.last_timestamp,
            unread_count: snap.unread_count,
            updated_at: snap.updated_at,
        });
    }

    conversations.sort_by(|a, b| {
        b.updated_at
            .cmp(&a.updated_at)
            .then_with(|| b.last_msg_id.cmp(&a.last_msg_id))
            .then_with(|| b.scene.cmp(&a.scene))
            .then_with(|| b.conversation_id.cmp(&a.conversation_id))
    });

    let mut has_more = friend_page.has_more || group_page.has_more;
    if conversations.len() > limit as usize {
        has_more = true;
        conversations.truncate(limit as usize);
    }

    success(RecentConversationsResult {
        conversations,
        has_more,
    })
}

pub(crate) async fn resolve_socket_addr(uid: i64) -> Result<String, AppError> {
    let cfg = AppConfig::get();
    let nodes = cfg.app_socket_configs();

    if nodes.is_empty() {
        return Err(AppError::Internal("socket node list empty".into()));
    }
    let count = i32::try_from(nodes.len()).unwrap_or(0);
    if count <= 0 {
        return Err(AppError::Internal("socket node list empty".into()));
    }
    let index = hash_index(&uid, count) as usize;
    if let Some(node) = nodes.get(index) {
        if let Some(addr) = node.pub_addr() {
            return Ok(addr);
        }
    }
    Err(AppError::Internal(
        "socket node missing public address".into(),
    ))
}
