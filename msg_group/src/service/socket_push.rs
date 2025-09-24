use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_GROUP_TOPIC;
use common::util::common_utils::build_snow_id;
use prost::Message;
use tonic::Status;

use crate::socket::{KafkaMsg, MsgKind};

/// 向 socket 分发通道推送消息。
/// 若未配置 Kafka，则静默忽略（返回 Ok）。
pub async fn push_socket_message<M: Message>(
    kafka: Option<&Arc<KafkaInstanceService>>,
    to: i64,
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
    let socket_msg = KafkaMsg {
        to,
        id: Some(msg_id),
        kind: kind as i32,
        payload,
        require_ack: Some(require_ack),
        expire_ms: Some(10_000),
        max_retry: Some(2),
        ts_ms: Some(ts_ms),
    };

    kafka
        .send_message(
            &socket_msg,
            &msg_id.to_string(),
            &MSG_SEND_GROUP_TOPIC.topic_name,
        )
        .await
        .map_err(|e| Status::internal(format!("send kafka message failed: {e}")))?;

    Ok(())
}
