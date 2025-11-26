use crate::{
    domain::{
        proto_adapter::{content_to_json, json_to_content},
        MessageEntity, MessageScene, MessageSource,
    },
    generated::message as msgpb,
    service::{message_service::MessageService, socket_client::SocketClient},
};
use log::warn;

const MAX_SEND_ATTEMPTS: i32 = 10;

pub fn enqueue_outbound(mut content: msgpb::Content, conversation_id: i64) -> Result<i64, String> {
    let entity = MessageEntity {
        id: None,
        conversation_id,
        receiver_id: if content.scene == msgpb::ChatScene::Group as i32 {
            Some(content.receiver_id)
        } else {
            None
        },
        scene: MessageScene::from(content.scene as i64),
        sender_type: 1,
        sender_id: content.sender_id,
        is_session_message: content.scene != msgpb::ChatScene::Profile as i32,
        is_chat_message: true,
        content: content_to_json(&content),
        extra: String::new(),
        created_at: content.timestamp,
        data_source: MessageSource::Client,
        sending_status: false,
        ack_status: false,
        send_count: 0,
    };
    let message_id = MessageService::get().insert(&entity)?;
    MessageService::get().increment_send_count(message_id)?;
    content.message_id = Some(message_id as u64);
    SocketClient::get().send_content(content)?;
    Ok(message_id)
}

pub fn resend_pending() -> Result<(), String> {
    let pending = MessageService::get().list_pending_messages(MAX_SEND_ATTEMPTS)?;
    for entity in pending {
        if let Some(message_id) = entity.id {
            if let Err(err) = resend_single(&entity, message_id) {
                warn!("resend pending message {} failed: {}", message_id, err);
            }
        }
    }
    Ok(())
}

fn resend_single(entity: &MessageEntity, message_id: i64) -> Result<(), String> {
    let mut content = json_to_content(&entity.content)?;
    content.message_id = Some(message_id as u64);
    SocketClient::get().send_content(content)?;
    MessageService::get().increment_send_count(message_id)?;
    if entity.send_count + 1 >= MAX_SEND_ATTEMPTS {
        MessageService::get().mark_send_failed(message_id)?;
    }
    Ok(())
}
