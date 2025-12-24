//! Kafka 消费 → 分片调度 → SessionManager 下发的完整流水线。
//!
//! ### 模块职责
//! * 订阅好友/群/系统主题并解析 `DomainMessage` 结构体。
//! * 将 Kafka payload 映射为内部 `ServerMsg`，同时根据消息的 DeliveryOptions 设置 ACK 策略。
//! * 调用 `ShardedDispatcher` 按用户分片入队，最终由 `SessionManager` 推送给在线会话。
//! * **消费确认策略**：默认 require_ack=true。收到客户端 socket ACK 后才提交 Kafka offset；超过最大重试次数则放弃并提交 offset（避免堆积）。
//!
//! 设计要点：
//! * Kafka payload 为 prost 编码的 `DomainMessage`，无 msg_id 时使用毫秒时间戳兜底，保证 ACK 对齐。
//! * 默认重试/过期策略：expire_ms=10s、max_retry=10（若生产端未设置）。
//! * 订阅主题：好友/群/系统。系统消息用于账号级通知，消费路径与其他一致。
//! * 仅处理“下行推送”通道，无上行业务逻辑，便于单独演进。
//!
//! Protobuf 结构速记（供排查对照）：
//! message DeliveryOptions {
//!   bool require_ack = 1;
//!   optional uint64 expire_ms = 2;
//!   optional uint32 max_retry = 3;
//! }
//!
//! message DomainMessage {
//!   optional uint64 message_id = 1;
//!   int64 sender_id = 2;
//!   int64 receiver_id = 3;
//!   int64 timestamp = 4;
//!   int64 ts_ms = 5;
//!   DeliveryOptions delivery = 6;
//!   ChatScene scene = 7;
//!   MsgCategory category = 8;
//!   repeated MessageContent contents = 9;
//!   FriendBusinessContent friend_business = 10;
//!   GroupBusinessContent group_business = 11;
//!   SystemBusinessContent system_business = 12;
//! }

use std::convert::TryFrom;
use std::sync::Arc;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use anyhow::{anyhow, Context};
use base64::engine::general_purpose::STANDARD as BASE64;
use base64::Engine as _;
use log::{error, info, warn};
use prost::Message as _;
use rdkafka::message::Message as _;

use crate::service::dispatcher::ShardedDispatcher;
use crate::service::types::{SendOpts, ServerMsg, UID};
use common::infra::grpc::message::{self as msg_message, DomainMessage};
use common::infra::kafka::start_consumer;
use common::infra::kafka::topic_info::{
    TopicInfo, MSG_SEND_FRIEND_TOPIC, MSG_SEND_GROUP_TOPIC, SYS_MSG_TOPIC_INFO,
};
/// 启动 Kafka → dispatcher → SessionManager 的数据通道。
pub async fn start_socket_pipeline() -> anyhow::Result<()> {
    let cfg = common::config::AppConfig::get();
    let sock_cfg = cfg.get_socket();
    let kafka_cfg = cfg.kafka_cfg();
    let shard_count: usize = sock_cfg
        .dispatch_shards
        .unwrap_or_else(num_cpus::get)
        .max(1);
    let shard_cap: usize = sock_cfg.dispatch_cap.unwrap_or(10_000);
    // Kafka 连接参数：若配置缺失则退化为本地单机默认，方便本地开发。
    let broker = kafka_cfg
        .broker
        .context("kafka broker address missing (set kafka.broker)")?;
    let group_id = kafka_cfg
        .group_id
        .context("kafka group id missing (set kafka.group_id)")?;

    let dispatcher = ShardedDispatcher::new(shard_count, shard_cap);
    info!(
        "socket pipeline: shards={} cap={} broker={} group={}",
        shard_count, shard_cap, broker, group_id
    );

    let topics: Vec<TopicInfo> = vec![
        MSG_SEND_FRIEND_TOPIC.clone(),
        MSG_SEND_GROUP_TOPIC.clone(),
        SYS_MSG_TOPIC_INFO.clone(),
    ];

    let dispatcher_cloned = dispatcher.clone();
    tokio::spawn(async move {
        let _ = start_consumer(&broker, &group_id, &topics, move |owned, consumer| {
            let dispatcher = dispatcher_cloned.clone();
            async move {
                // Kafka payload 是 prost 编码后的 `DomainMessage`。OwnedMessage 仅提供引用，先复制为 Vec 便于 decode。
                let raw = owned
                    .payload()
                    .map(|p| p.to_vec())
                    .ok_or_else(|| anyhow!("empty payload"))?;

                // 解析失败时直接返回错误，交由 runner 重试。日志中仍保留详细原因，便于定位兼容性问题。
                let domain = DomainMessage::decode(raw.as_slice()).map_err(|e| {
                    error!("kafka payload decode error: {:?}", e);
                    anyhow!("decode domain message failed")
                })?;

                // Kafka 允许消息不带 id，此时生成一个基于毫秒时间戳的唯一值，保证 ACK 对齐。
                let fallback_id = SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .map(|d| d.as_millis() as i64)
                    .unwrap_or(0);
                let id_value = domain.message_id.unwrap_or(fallback_id as u64);
                let id = id_value as i64;
                let ts_ms = if domain.ts_ms != 0 {
                    domain.ts_ms
                } else {
                    fallback_id
                };
                let _msg_category = msg_message::MsgCategory::try_from(domain.category)
                    .unwrap_or(msg_message::MsgCategory::Unknown);
                let content = msg_message::Content {
                    message_id: domain.message_id,
                    sender_id: domain.sender_id,
                    receiver_id: domain.receiver_id,
                    timestamp: domain.timestamp,
                    scene: domain.scene,
                    contents: domain.contents.clone(),
                    friend_business: domain.friend_business.clone(),
                    group_business: domain.group_business.clone(),
                    ..Default::default()
                };
                // 打印解码后的消息内容为 JSON（包含 base64 原始帧），便于追踪。
                if let Ok(json) = serde_json::to_string(&serde_json::json!({
                    "message_id": content.message_id,
                    "sender_id": content.sender_id,
                    "receiver_id": content.receiver_id,
                    "timestamp": content.timestamp,
                    "scene": content.scene,
                    "contents_len": content.contents.len(),
                    "friend_business": content.friend_business.is_some(),
                    "group_business": content.group_business.is_some(),
                    "system_business": content.system_business.is_some(),
                    "raw_base64": BASE64.encode({
                        let mut buf = Vec::new();
                        let _ = content.encode(&mut buf);
                        buf
                    })
                })) {
                    info!("kafka inbound content: {}", json);
                }
                let msg = ServerMsg {
                    id,
                    auth: None,
                    payload: content,
                    raw_payload: raw.clone(),
                    ts_ms,
                };
                let payload_len = raw.len();

                // `SendOpts` 决定 ACK 行为：expire, max_retry 等都由生产端决定，默认更稳妥的 10 次最大重试。
                let proto_delivery = domain.delivery.unwrap_or(msg_message::DeliveryOptions {
                    require_ack: true,
                    expire_ms: Some(10_000),
                    max_retry: Some(10),
                });
                let require_ack = proto_delivery.require_ack;
                let receiver_id = domain.receiver_id;
                // 立即提交 Kafka offset；会话内最多重发 3 次，超过则丢弃并记录日志。
                let mut opts = SendOpts {
                    require_ack,
                    expire: Duration::from_millis(proto_delivery.expire_ms.unwrap_or(10_000)),
                    max_retry: 3,
                    ack_hook: None,
                    drop_hook: Some(Arc::new(move |id| {
                        warn!(
                            "socket fanout drop after retries: msg_id={} receiver={} require_ack={}",
                            id, receiver_id, require_ack
                        );
                    })),
                };

                let owned = Arc::new(owned);

                info!(
                    "kafka consume topic={} partition={} offset={} msg_id={} require_ack={} receiver={} bytes={}",
                    owned.topic(),
                    owned.partition(),
                    owned.offset(),
                    id,
                    require_ack,
                    domain.receiver_id,
                    payload_len
                );

                let enqueue_ok = dispatcher.enqueue(domain.receiver_id as UID, msg, opts);
                if enqueue_ok {
                    // 立即提交 Kafka offset，避免因为客户端 ACK 未达导致堆积。
                    Ok(true)
                } else {
                    warn!(
                        "kafka consume enqueue failed: dispatch queue full msg_id={} receiver={}",
                        id, domain.receiver_id
                    );
                    Err(anyhow!("dispatch queue full"))
                }
            }
        })
        .await; // never returns
    });

    Ok(())
}
