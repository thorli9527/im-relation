//! Kafka 消费 → 分片调度 → SessionManager 下发的完整流水线。
//!
//! ### 模块职责
//! * 订阅好友/群/系统主题并解析 `KafkaMsg` 结构体。
//! * 将消息映射为内部 `ServerMsg`，同时准备 ACK 策略（超时、重试次数、回调）。
//! * 调用 `ShardedDispatcher` 按用户分片入队，最终由 `SessionManager` 推送给在线会话。
//! * 在客户端返回 ACK 之后提交 Kafka offset；若超出 10 次重试仍未确认则放弃并记录日志。
//!
//! 该模块仅负责“消息下发”的数据通道，没有上行业务逻辑，便于单独测试和演进。

use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context};
use log::{error, info, warn};
use prost::Message as _;
use rdkafka::consumer::{CommitMode, Consumer};
use rdkafka::message::Message;
use rdkafka::topic_partition_list::TopicPartitionList;
use rdkafka::Offset;

use crate::service::dispatcher::ShardedDispatcher;
use crate::service::types::{SendOpts, ServerMsg, UserId};
use common::grpc::grpc_socket::socket::{KafkaMsg, MsgKind as PbMsgKind};
use common::kafka::start_consumer;
use common::kafka::topic_info::{
    TopicInfo, MSG_SEND_FRIEND_TOPIC, MSG_SEND_GROUP_TOPIC, SYS_MSG_TOPIC_INFO,
};
use std::convert::TryFrom;

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
                // Kafka payload 是 prost 编码后的 `KafkaMsg`。OwnedMessage 仅提供引用，先复制为 Vec 便于 decode。
                let raw = owned
                    .payload()
                    .map(|p| p.to_vec())
                    .ok_or_else(|| anyhow!("empty payload"))?;

                // 解析失败时直接返回错误，交由 runner 重试。日志中仍保留详细原因，便于定位兼容性问题。
                let kmsg = KafkaMsg::decode(raw.as_slice()).map_err(|e| {
                    error!("kafka payload decode error: {:?}", e);
                    anyhow!("decode kafka msg failed")
                })?;

                // Kafka 允许消息不带 id，此时生成一个基于毫秒时间戳的唯一值，保证 ACK 对齐。
                let id = kmsg.id.unwrap_or_else(|| {
                    use std::time::{SystemTime, UNIX_EPOCH};
                    SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .map(|d| d.as_millis() as i64)
                        .unwrap_or(0)
                });
                let kind = PbMsgKind::try_from(kmsg.kind).unwrap_or(PbMsgKind::MkUnknown);
                let msg = ServerMsg {
                    id,
                    kind,
                    payload: kmsg.payload.clone(),
                    ts_ms: kmsg.ts_ms.unwrap_or(id),
                };

                // `SendOpts` 决定 ACK 行为：expire, max_retry 等都由生产端决定，默认更稳妥的 10 次最大重试。
                let require_ack = kmsg.require_ack.unwrap_or(true);
                let mut opts = SendOpts {
                    require_ack,
                    expire: Duration::from_millis(kmsg.expire_ms.unwrap_or(10_000)),
                    max_retry: kmsg.max_retry.unwrap_or(10),
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

                let enqueue_ok = dispatcher.enqueue(kmsg.to as UserId, msg, opts);
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
