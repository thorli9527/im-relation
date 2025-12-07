use base64::engine::general_purpose::STANDARD as BASE64;
use base64::Engine as _;
use log::warn;
use prost::Message as ProstMessage;
use serde::Deserialize;

use crate::{
    api::{
        app_api_types::SearchUserQuery,
        friend_api,
        sync_api::{build_sync_request_from_state, sync_messages},
    },
    domain::{ConversationEntity, MessageEntity, MessageScene, MessageSource},
    generated::message::{friend_business_content::Action as FriendAction, Content},
    generated::message as msgpb,
    service::{
        conversation_service::ConversationService,
        friend_request_service::FriendRequestService, friend_service::FriendService,
        group_request_service::GroupRequestService,
        message_service::MessageService, sync_state_service::SyncStateService,
        user_service::UserService,
    },
};

/// 增量同步好友/群/系统消息并落库、更新游标。
pub fn sync_incremental() -> Result<(), String> {
    // 依据本地游标和 session_token 构造同步请求；若缺失 token 则直接返回。
    let (req, state) = build_sync_request_from_state(Some(200))?;
    let resp = sync_messages(&req)?;
    let mut friend_max = state.friend_last_seq;
    let mut group_max = state.group_last_seq;
    let mut system_max = state.system_last_seq;
    // 当前用户 UID（判定会话方向与未读）
    let current_uid = UserService::get()
        .latest_user()
        .ok()
        .flatten()
        .map(|u| u.uid);

    for raw in resp.friend_messages {
        if let Some(content) = decode_content(&raw) {
            if let Some(ack) = &content.ack {
                if let Some(ref_id) = ack.ref_message_id {
                    let _ = MessageService::get().mark_ack(ref_id as i64);
                }
            }
            // 先处理业务，再落库
            handle_friend_business(&content, current_uid);
            handle_group_business(&content);
            handle_system_business(&content, current_uid);
            friend_max = friend_max.max(content.timestamp);
            let _ = persist_message(&content, current_uid);
            let _ = update_conversation_snapshot(&content, current_uid);
        }
    }
    for raw in resp.group_messages {
        if let Some(content) = decode_content(&raw) {
            if let Some(ack) = &content.ack {
                if let Some(ref_id) = ack.ref_message_id {
                    let _ = MessageService::get().mark_ack(ref_id as i64);
                }
            }
            // 先处理业务，再落库
            handle_friend_business(&content, current_uid);
            handle_group_business(&content);
            handle_system_business(&content, current_uid);
            group_max = group_max.max(content.timestamp);
            let _ = persist_message(&content, current_uid);
            let _ = update_conversation_snapshot(&content, current_uid);
        }
    }
    for raw in resp.system_messages {
        if let Some(content) = decode_content(&raw) {
            if let Some(ack) = &content.ack {
                if let Some(ref_id) = ack.ref_message_id {
                    let _ = MessageService::get().mark_ack(ref_id as i64);
                }
            }
            // 先处理业务，再落库
            handle_friend_business(&content, current_uid);
            handle_group_business(&content);
            handle_system_business(&content, current_uid);
            if let Some(mid) = content.message_id {
                system_max = system_max.max(mid as i64);
            }
            let _ = persist_message(&content, current_uid);
            let _ = update_conversation_snapshot(&content, current_uid);
        }
    }

    let _ = SyncStateService::update_seqs(friend_max, group_max, system_max);
    Ok(())
}

fn decode_content(raw: &str) -> Option<Content> {
    let bytes = BASE64.decode(raw.as_bytes()).ok()?;
    Content::decode(bytes.as_slice()).ok()
}

fn update_conversation_snapshot(
    content: &Content,
    current_uid: Option<i64>,
) -> Result<(), String> {
    // 根据会话场景确定会话 key
    let scene = MessageScene::from(content.scene as i64);
    let target_id = resolve_conversation_target(content, current_uid);
    let conv_type = scene as i32;
    let svc = ConversationService::get();
    let owner_uid = match current_uid {
        Some(uid) => uid,
        None => return Ok(()), // 无当前用户上下文，不记录会话，避免混入其他账号数据。
    };
    let mut entity = svc
        .get_by_type_and_target(owner_uid, conv_type, target_id)?
        .unwrap_or_else(|| ConversationEntity::new(owner_uid, conv_type, target_id));

    let should_increase_unread = current_uid
        .map(|uid| uid != content.sender_id)
        .unwrap_or(false)
        && !content.contents.is_empty()
        && scene != MessageScene::System;

    if should_increase_unread {
        entity.unread_count = entity.unread_count.saturating_add(1);
    }
    entity.last_message_time = content.timestamp;
    entity.last_message_content = summarize_content(content);
    svc.upsert(entity)
}

fn summarize_content(content: &Content) -> String {
    for item in &content.contents {
        match &item.content {
            Some(crate::generated::message::message_content::Content::Text(text)) => {
                return text.text.clone();
            }
            Some(crate::generated::message::message_content::Content::Image(_)) => {
                return "[image]".into();
            }
            Some(crate::generated::message::message_content::Content::Audio(_)) => {
                return "[audio]".into();
            }
            Some(crate::generated::message::message_content::Content::Video(_)) => {
                return "[video]".into();
            }
            Some(crate::generated::message::message_content::Content::FriendEvent(_)) => {
                return "[friend event]".into();
            }
            Some(crate::generated::message::message_content::Content::GroupEvent(_)) => {
                return "[group event]".into();
            }
            _ => {}
        }
    }
    if content.friend_business.is_some() {
        return "[friend business]".into();
    }
    if content.group_business.is_some() {
        return "[group business]".into();
    }
    if content.ack.is_some() {
        return "[ACK]".into();
    }
    if let Some(system) = content.system_business.as_ref() {
        if system.business_type == msgpb::SystemBusinessType::SystemFriendAdd as i32 {
            return "[friend added]".into();
        }
        return "[system]".into();
    }
    "[message]".into()
}

fn resolve_conversation_target(content: &Content, current_uid: Option<i64>) -> i64 {
    let scene = MessageScene::from(content.scene as i64);
    match scene {
        MessageScene::Group => content.receiver_id,
        MessageScene::System => content.receiver_id,
        _ => {
            if let Some(uid) = current_uid {
                if content.receiver_id == uid {
                    content.sender_id
                } else {
                    content.receiver_id
                }
            } else {
                content.receiver_id
            }
        }
    }
}

/// 处理好友业务载体：申请/决策，落库并触发通知。
fn handle_friend_business(content: &Content, current_uid: Option<i64>) {
    let Some(biz) = content.friend_business.as_ref() else {
        return;
    };
    match &biz.action {
        Some(FriendAction::Request(payload)) => {
            if let Err(err) = FriendRequestService::get().upsert_request(payload) {
                warn!("store friend request {} failed: {}", payload.request_id, err);
            }
            crate::api::socket_api::notify_friend_request(payload);
        }
        Some(FriendAction::Decision(payload)) => {
            let decided_at = if payload.decided_at > 0 {
                payload.decided_at
            } else {
                content.timestamp
            };
            if let Err(err) = FriendRequestService::get().apply_decision(
                payload,
                content.sender_id,
                content.receiver_id,
                decided_at,
            ) {
                warn!(
                    "apply friend decision {} failed: {}",
                    payload.request_id, err
                );
            }
            if payload.accepted {
                if let Err(err) =
                    apply_friend_acceptance(current_uid, content, payload, decided_at)
                {
                    warn!(
                        "apply friend acceptance for {} failed: {}",
                        payload.request_id, err
                    );
                }
            }
        }
        Some(FriendAction::Established(payload)) => {
            handle_friend_established(current_uid, content, payload);
        }
        _ => {}
    }
}

fn handle_friend_established(
    current_uid: Option<i64>,
    content: &Content,
    payload: &crate::generated::message::FriendEstablishedPayload,
) {
    let uid = match current_uid {
        Some(id) => id,
        None => return,
    };
    let friend_id = if uid == payload.uid_a {
        payload.uid_b
    } else if uid == payload.uid_b {
        payload.uid_a
    } else {
        return;
    };
    let established_at = if payload.at_ms > 0 {
        payload.at_ms
    } else {
        content.timestamp
    };
    let svc = FriendService::get();
    match svc.get_by_friend_id(friend_id) {
        Ok(Some(_)) => return,
        Ok(None) => {}
        Err(err) => {
            warn!(
                "query friend {} from established message failed: {}",
                friend_id, err
            );
        }
    }

    let mut nickname = None;
    let mut avatar = None;
    match friend_api::search_user(SearchUserQuery {
        query: friend_id.to_string(),
    }) {
        Ok(resp) => {
            if let Some(user) = resp.user {
                if !user.nickname.trim().is_empty() {
                    nickname = Some(user.nickname.clone());
                }
                if !user.avatar.trim().is_empty() {
                    avatar = Some(user.avatar.clone());
                }
            }
        }
        Err(err) => {
            warn!(
                "fetch profile for established friend {} failed: {}",
                friend_id, err
            );
        }
    }

    if let Err(err) = svc.ensure_friend(friend_id, None, nickname.clone(), established_at) {
        warn!(
            "ensure_friend {} from established message failed: {}",
            friend_id, err
        );
    }
    if avatar.is_some() || nickname.is_some() {
        if let Err(err) = svc.apply_profile_update(friend_id, nickname, avatar, established_at) {
            warn!(
                "apply_profile_update {} from established message failed: {}",
                friend_id, err
            );
        }
    }
}

fn handle_group_business(content: &Content) {
    let Some(biz) = content.group_business.as_ref() else {
        return;
    };
    use crate::generated::message::group_business_content::Action as GroupAction;
    match &biz.action {
        Some(GroupAction::JoinRequest(payload)) => {
            if let Err(err) = GroupRequestService::get().upsert_request(payload) {
                warn!(
                    "store group join request {} failed: {}",
                    payload.request_id, err
                );
            }
        }
        Some(GroupAction::JoinDecision(payload)) => {
            let decided_at = if payload.decided_at > 0 {
                payload.decided_at
            } else {
                content.timestamp
            };
            if let Err(err) = GroupRequestService::get().apply_decision(payload, decided_at) {
                warn!(
                    "apply group join decision {} failed: {}",
                    payload.request_id, err
                );
            }
        }
        _ => {}
    }
}

#[derive(Debug, Deserialize)]
struct FriendAddDetail {
    from_uid: i64,
    to_uid: i64,
}

/// 处理系统业务：当前仅关注好友添加成功的系统通知。
fn handle_system_business(content: &Content, current_uid: Option<i64>) {
    let Some(system) = content.system_business.as_ref() else {
        return;
    };
    if system.business_type != msgpb::SystemBusinessType::SystemFriendAdd as i32 {
        return;
    }
    let detail: FriendAddDetail = match serde_json::from_str(&system.detail) {
        Ok(value) => value,
        Err(err) => {
            warn!("parse friend add detail failed: {}", err);
            return;
        }
    };
    // 落库好友关系，确保本地 friend 表同步。
    if let Some(uid) = current_uid {
        let friend_id = if uid == detail.from_uid {
            detail.to_uid
        } else if uid == detail.to_uid {
            detail.from_uid
        } else {
            0
        };
        if friend_id > 0 {
            if let Err(err) =
                FriendService::get().ensure_friend(friend_id, None, None, content.timestamp)
            {
                warn!("ensure_friend on system business failed: {}", err);
            }
        }
    }
    if let Err(err) = persist_friend_add_message(content, &detail, current_uid) {
        warn!("persist friend add message failed: {}", err);
    }
}

fn persist_friend_add_message(
    content: &Content,
    detail: &FriendAddDetail,
    current_uid: Option<i64>,
) -> Result<(), String> {
    let uid = match current_uid {
        Some(id) => id,
        None => return Ok(()),
    };
    let friend_id = if uid == detail.from_uid {
        detail.to_uid
    } else if uid == detail.to_uid {
        detail.from_uid
    } else {
        return Ok(());
    };
    let mut synthetic = content.clone();
    synthetic.scene = msgpb::ChatScene::Single as i32;
    synthetic.receiver_id = uid;
    synthetic.sender_id = friend_id;
    persist_message(&synthetic, current_uid)?;
    update_conversation_snapshot(&synthetic, current_uid)
}

fn apply_friend_acceptance(
    current_uid: Option<i64>,
    content: &Content,
    payload: &crate::generated::message::FriendRequestDecisionPayload,
    decided_at: i64,
) -> Result<(), String> {
    let uid = match current_uid {
        Some(id) => id,
        None => return Ok(()),
    };
    // 确认本地用户参与了该好友申请，避免错误落库。
    let counterpart = if uid == content.sender_id {
        content.receiver_id
    } else if uid == content.receiver_id {
        content.sender_id
    } else {
        return Ok(());
    };

    FriendService::get().ensure_friend(
        counterpart,
        normalize_optional(&payload.remark),
        normalize_optional(&payload.nickname),
        decided_at,
    )
}

fn normalize_optional(value: &str) -> Option<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

fn persist_message(content: &Content, current_uid: Option<i64>) -> Result<(), String> {
    let svc = MessageService::get();
    let target_id = resolve_conversation_target(content, current_uid);
    let entity = MessageEntity {
        id: None,
        conversation_id: target_id,
        scene: MessageScene::from(content.scene as i64),
        receiver_id: Some(content.receiver_id),
        sender_type: 1,
        sender_id: content.sender_id,
        is_session_message: true,
        is_chat_message: true,
        content: serde_json::json!({
            "protobuf": BASE64.encode({
                let mut b = Vec::new();
                let _ = content.encode(&mut b);
                b
            })
        }),
        extra: String::new(),
        created_at: content.timestamp,
        data_source: MessageSource::Server,
        sending_status: true,
        ack_status: true,
        send_count: 0,
    };
    svc.insert(&entity)?;
    Ok(())
}
