use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_GROUP_TOPIC;
use common::message_bus::{DeliveryOptions, DomainMessage};
use common::util::common_utils::build_snow_id;
use prost::Message;
use tonic::Status;

use crate::socket::MsgKind;

/// 向 socket 分发通道推送消息。
/// 若未配置 Kafka，则静默忽略（返回 Ok）。
pub async fn push_socket_message<M: Message>(
    kafka: Option<&Arc<KafkaInstanceService>>,
    to: i64,
    group_id: Option<i64>,
    kind: MsgKind,
    message: &M,
    require_ack: bool,
) -> Result<(), Status> {
    let Some(kafka) = kafka else {
        return Ok(());
    };

    let mut payload = Vec::with_capacity(message.encoded_len());
    message
        .encode(&mut payload)
        .map_err(|e| Status::internal(format!("encode payload failed: {e}")))?;

    let msg_id = build_snow_id();
    let ts_ms = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as i64;
    let delivery = if require_ack {
        DeliveryOptions::require_ack_defaults()
    } else {
        DeliveryOptions::fire_and_forget()
    };
    let domain = DomainMessage::group(
        to,
        Some(msg_id),
        kind,
        payload,
        ts_ms,
        delivery,
        group_id,
        None,
    );
    let socket_msg = domain.to_kafka_msg();

    kafka
        .send_message(
            &socket_msg,
            &domain.message_id().unwrap_or(msg_id).to_string(),
            &MSG_SEND_GROUP_TOPIC.topic_name,
        )
        .await
        .map_err(|e| Status::internal(format!("send kafka message failed: {e}")))?;

    Ok(())
}
