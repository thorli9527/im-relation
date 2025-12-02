use std::sync::Arc;

use base64::{engine::general_purpose, Engine as _};
use common::core::messaging::DeliveryOptions;
use common::infra::grpc::message::{
    self as msg_message, message_content::Content as MessageContentKind, CustomContent,
    MessageContent,
};
use common::infra::kafka::kafka_producer::KafkaInstanceService;
use common::infra::kafka::topic_info::MSG_SEND_GROUP_TOPIC;
use common::support::util::common_utils::build_snow_id;
use prost::Message;
use tonic::Status;

/// 向 socket 分发通道推送消息。
/// 若未配置 Kafka，则静默忽略（返回 Ok）。
pub async fn push_socket_message<M: Message>(
    kafka: Option<&Arc<KafkaInstanceService>>,
    to: i64,
    _group_id: Option<i64>,
    message_type: &str,
    sender_id: i64,
    event_ts: i64,
    message: &M,
    require_ack: bool,
) -> Result<(), Status> {
    let Some(kafka) = kafka else {
        return Ok(());
    };

    let mut raw_payload = Vec::with_capacity(message.encoded_len());
    message
        .encode(&mut raw_payload)
        .map_err(|e| Status::internal(format!("encode payload failed: {e}")))?;

    let encoded_payload = general_purpose::STANDARD.encode(&raw_payload);
    let msg_id = build_snow_id();
    let delivery = if require_ack {
        DeliveryOptions::require_ack_defaults()
    } else {
        DeliveryOptions::fire_and_forget()
    };

    let domain = msg_message::DomainMessage {
        message_id: Some(msg_id as u64),
        sender_id,
        receiver_id: to,
        timestamp: event_ts,
        ts_ms: event_ts,
        delivery: Some(msg_message::DeliveryOptions {
            require_ack: delivery.require_ack,
            expire_ms: delivery.expire_ms,
            max_retry: delivery.max_retry,
        }),
        scene: msg_message::ChatScene::Group as i32,
        category: msg_message::MsgCategory::Group as i32,
        contents: vec![MessageContent {
            content: Some(MessageContentKind::Custom(CustomContent {
                custom_type: message_type.to_string(),
                json_payload: encoded_payload,
            })),
        }],
        friend_business: None,
        group_business: None,
        system_business: None,
    };

    let mut domain_bytes = Vec::with_capacity(domain.encoded_len());
    domain
        .encode(&mut domain_bytes)
        .map_err(|e| Status::internal(format!("encode domain message failed: {e}")))?;

    kafka
        .send_message(
            &domain_bytes,
            &msg_id.to_string(),
            &MSG_SEND_GROUP_TOPIC.topic_name,
        )
        .await
        .map_err(|e| Status::internal(format!("send kafka message failed: {e}")))
}
