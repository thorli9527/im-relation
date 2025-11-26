use base64::engine::general_purpose::STANDARD as BASE64;
use base64::Engine as _;
use prost::Message as ProstMessage;

use crate::{
    api::sync_api::{sync_messages, SyncRequest},
    domain::{MessageEntity, MessageScene, MessageSource},
    generated::message::Content,
    service::{message_service::MessageService, sync_state_service::SyncStateService},
};

/// 增量同步好友/群/系统消息并落库、更新游标。
pub fn sync_incremental(session_token: &str) -> Result<(), String> {
    let state = SyncStateService::fetch().unwrap_or_else(|_| {
        SyncStateService::ensure_row()
            .and_then(|_| SyncStateService::fetch())
            .unwrap_or_else(|_| crate::domain::sync_state_entity::SyncStateEntity::new())
    });

    let req = SyncRequest {
        session_token: session_token.to_string(),
        friend_last_seq: Some(state.friend_last_seq),
        group_last_seq: Some(state.group_last_seq),
        system_last_seq: Some(state.system_last_seq as u64),
        limit: Some(200),
    };

    let resp = sync_messages(&req)?;
    let mut friend_max = state.friend_last_seq;
    let mut group_max = state.group_last_seq;
    let mut system_max = state.system_last_seq;

    for raw in resp.friend_messages {
        if let Some(content) = decode_content(&raw) {
            friend_max = friend_max.max(content.timestamp);
            let _ = persist_message(&content);
        }
    }
    for raw in resp.group_messages {
        if let Some(content) = decode_content(&raw) {
            group_max = group_max.max(content.timestamp);
            let _ = persist_message(&content);
        }
    }
    for raw in resp.system_messages {
        if let Some(content) = decode_content(&raw) {
            if let Some(mid) = content.message_id {
                system_max = system_max.max(mid as i64);
            }
            let _ = persist_message(&content);
        }
    }

    let _ = SyncStateService::update_seqs(friend_max, group_max, system_max);
    Ok(())
}

fn decode_content(raw: &str) -> Option<Content> {
    let bytes = BASE64.decode(raw.as_bytes()).ok()?;
    Content::decode(bytes.as_slice()).ok()
}

fn persist_message(content: &Content) -> Result<(), String> {
    let svc = MessageService::get();
    let entity = MessageEntity {
        id: None,
        conversation_id: content.receiver_id,
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
