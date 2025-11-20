use crate::{
    domain::{proto_adapter::content_to_json, MessageEntity, MessageScene, MessageSource},
    generated::message as msgpb,
    service::{message_service::MessageService, socket_client::SocketClient},
};

pub fn enqueue_outbound(mut content: msgpb::Content, conversation_id: i64) -> Result<i64, String> {
    let entity = MessageEntity {
        id: None,
        conversation_id,
        scene: MessageScene::from(content.scene as i64),
        sender_type: 1,
        sender_id: content.sender_id,
        is_session_message: content.scene != msgpb::ChatScene::Profile as i32,
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
