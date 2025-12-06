use axum::{routing::post, Json, Router};
use common::config::AppConfig;
use common::core::errors::AppError;
use common::core::result::ApiResponse;
use common::infra::grpc::grpc_user::online_service::UserEntity;
use common::support::util::common_utils::hash_index;
use validator::Validate;

pub use crate::handler::user_handler_types::*;
use crate::handler::utils::{map_internal_error, map_session_error, success, HandlerResult};
use crate::service::{
    auth_models::{
        ChangeEmailRequestDto, ChangePasswordRequestDto, ChangePhoneRequestDto,
        UpdateProfileRequestDto,
    },
    message_gateway,
    user_service::{self, UserService, UserServiceAuthOpt},
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
