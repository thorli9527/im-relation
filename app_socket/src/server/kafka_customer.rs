//! Kafka 消费 → 分片调度 → SessionManager 下发的完整流水线。
//!
//! ### 模块职责
//! * 订阅好友/群/系统主题并解析 `DomainMessage` 结构体。
//! * 将消息映射为内部 `ServerMsg`，同时准备 ACK 策略（超时、重试次数、回调）。
//! * 调用 `ShardedDispatcher` 按用户分片入队，最终由 `SessionManager` 推送给在线会话。
//! * 在客户端返回 ACK 之后提交 Kafka offset；若超出 10 次重试仍未确认则放弃并记录日志。
//!
//! 该模块仅负责“消息下发”的数据通道，没有上行业务逻辑，便于单独测试和演进。

use std::convert::TryFrom;
use std::sync::Arc;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use anyhow::{anyhow, Context};
use log::{error, info, warn};
use prost::Message as _;
use rdkafka::consumer::{CommitMode, Consumer};
use rdkafka::message::Message as _;
use rdkafka::topic_partition_list::TopicPartitionList;
use rdkafka::Offset;

use crate::service::dispatcher::ShardedDispatcher;
use crate::service::types::{SendOpts, ServerMsg, UID};
use common::infra::grpc::message::{self as msg_message, DomainMessage};
use common::infra::kafka::start_consumer;
use common::infra::kafka::topic_info::{TopicInfo, MSG_SEND_FRIEND_TOPIC, MSG_SEND_GROUP_TOPIC};
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
        // SYS_MSG_TOPIC_INFO.clone(),
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
                let msg = ServerMsg {
                    id,
                    payload: content,
                    raw_payload: raw.clone(),
                    ts_ms,
                };

                // `SendOpts` 决定 ACK 行为：expire, max_retry 等都由生产端决定，默认更稳妥的 10 次最大重试。
                let proto_delivery = domain.delivery.unwrap_or(msg_message::DeliveryOptions {
                    require_ack: true,
                    expire_ms: Some(10_000),
                    max_retry: Some(10),
                });
                let require_ack = proto_delivery.require_ack;
                let mut opts = SendOpts {
                    require_ack,
                    expire: Duration::from_millis(proto_delivery.expire_ms.unwrap_or(10_000)),
                    max_retry: proto_delivery.max_retry.unwrap_or(10),
                    ack_hook: None,
                    drop_hook: None,
                };

                let owned = Arc::new(owned);

                if require_ack {
                    // 客户端确认后需要提交 Kafka offset，因此设置 ack/drop 两类回调。
                    let consumer_for_ack = consumer.clone();
                    let owned_for_ack = owned.clone();
                    let ack_cb = Arc::new(move |msg_id| {
                        let consumer = consumer_for_ack.clone();
                        let owned = owned_for_ack.clone();
                        tokio::spawn(async move {
                            let mut tpl = TopicPartitionList::new();
                            if let Err(err) = tpl.add_partition_offset(
                                owned.topic(),
                                owned.partition(),
                                Offset::Offset(owned.offset()),
                            ) {
                                warn!("prepare kafka commit failed: {} (msg_id={})", err, msg_id);
                                return;
                            }
                            if let Err(err) = consumer.commit(&tpl, CommitMode::Async) {
                                warn!(
                                    "commit kafka offset on ack failed: {} (msg_id={})",
                                    err, msg_id
                                );
                            }
                        });
                    });

                    let consumer_for_drop = consumer.clone();
                    let owned_for_drop = owned.clone();
                    // 当消息超过重试次数依旧未确认时，也提交 offset，避免永久阻塞进度，同时进行告警。
                    let drop_cb = Arc::new(move |msg_id| {
                        let consumer = consumer_for_drop.clone();
                        let owned = owned_for_drop.clone();
                        tokio::spawn(async move {
                            let mut tpl = TopicPartitionList::new();
                            if let Err(err) = tpl.add_partition_offset(
                                owned.topic(),
                                owned.partition(),
                                Offset::Offset(owned.offset()),
                            ) {
                                warn!("prepare kafka commit failed: {} (msg_id={})", err, msg_id);
                                return;
                            }
                            if let Err(err) = consumer.commit(&tpl, CommitMode::Async) {
                                warn!(
                                    "commit kafka offset on drop failed: {} (msg_id={})",
                                    err, msg_id
                                );
                            } else {
                                warn!(
                                    "message {:?} exceeded retry limit; committed offset",
                                    msg_id
                                );
                            }
                        });
                    });

                    opts.ack_hook = Some(ack_cb);
                    opts.drop_hook = Some(drop_cb);
                }

                let enqueue_ok = dispatcher.enqueue(domain.receiver_id as UID, msg, opts);
                if enqueue_ok {
                    // 返回值决定是否立即提交 offset。需要 ACK 的交由回调提交。
                    Ok(!require_ack)
                } else {
                    Err(anyhow!("dispatch queue full"))
                }
            }
        })
        .await; // never returns
    });

    Ok(())
}
