//! Kafka → 分片队列 → 会话分发 的端到端链路
//!
//! 作用：从 Kafka 拉取需要下发到终端的消息，转换为 `ServerMsg` 并进入分片调度器。
//!
//! 关键点：
//! - 主题列表：好友单聊、群聊、系统消息；
//! - 载荷结构 `KafkaSocketMsg` 与 `ServerMsg` 映射；
//! - 入队成功才确认消费（在 common 的 consumer 封装内处理），保证至少一次投递；
//! - `id` 缺省使用当前毫秒时间戳，便于追踪与客户端 ACK 对齐。

use std::time::Duration;

use anyhow::anyhow;
use log::{error, info};
use rdkafka::message::Message;
use prost::Message as _;

use crate::service::dispatcher::ShardedDispatcher;
use crate::service::types::{SendOpts, ServerMsg, UserId};
use crate::proto::{KafkaSocketMsg, MsgKind as PbMsgKind};
use std::convert::TryFrom;
use common::kafka::start_consumer;
use common::kafka::topic_info::{MSG_SEND_FRIEND_TOPIC, MSG_SEND_GROUP_TOPIC, SYS_MSG_TOPIC_INFO, TopicInfo};

fn default_true() -> bool { true }

/// 启动消费与分发流水线（参数来自配置文件 socket.*）
///
/// 流程：
/// 1) 初始化分片调度器（分片数与队列容量来自配置或默认值）；
/// 2) 启动 Kafka 消费任务，消费主题：好友单聊/群聊/系统消息；
/// 3) 解析 Kafka payload（`KafkaSocketMsg`），映射为 `ServerMsg` 与 `SendOpts`；
/// 4) 入队分片调度器（入队成功才确认消费，保证至少一次）；
/// 5) 分片任务再调用 `SessionManager::send_to_user` 完成扇出。
pub async fn start_socket_pipeline() -> anyhow::Result<()> {
    let sock_cfg = common::config::AppConfig::get().get_socket();
    let shard_count: usize = sock_cfg.dispatch_shards.unwrap_or_else(num_cpus::get).max(1);
    let shard_cap: usize = sock_cfg.dispatch_cap.unwrap_or(10_000);
    let broker = sock_cfg.kafka_broker.unwrap_or_else(|| "127.0.0.1:9092".to_string());
    let group_id = sock_cfg.kafka_group_id.unwrap_or_else(|| "socket-dispatcher".to_string());

    let dispatcher = ShardedDispatcher::new(shard_count, shard_cap);
    info!("socket pipeline: shards={}, cap={} broker={} group={}", shard_count, shard_cap, broker, group_id);

    let topics: Vec<TopicInfo> = vec![
        MSG_SEND_FRIEND_TOPIC.clone(),
        MSG_SEND_GROUP_TOPIC.clone(),
        SYS_MSG_TOPIC_INFO.clone(),
    ];

    let dispatcher_cloned = dispatcher.clone();
    tokio::spawn(async move {
        let _ = start_consumer(&broker, &group_id, &topics, move |owned| {
            let dispatcher = dispatcher_cloned.clone();
            async move {
                // 入队成功才提交 offset（common 实现里）
                if let Some(payload) = owned.payload() {
                    match KafkaSocketMsg::decode(payload) {
                        Ok(kmsg) => {
                            let id = kmsg.id.unwrap_or_else(|| {
                                use std::time::{SystemTime, UNIX_EPOCH};
                                SystemTime::now().duration_since(UNIX_EPOCH).map(|d| d.as_millis() as i64).unwrap_or(0)
                            });
                            let kind = PbMsgKind::try_from(kmsg.kind).unwrap_or(PbMsgKind::MkUnknown);
                            let msg = ServerMsg { id, kind, payload: kmsg.payload, ts_ms: kmsg.ts_ms.unwrap_or(id) };
                            let opts = SendOpts { require_ack: kmsg.require_ack.unwrap_or(true), expire: Duration::from_millis(kmsg.expire_ms.unwrap_or(10_000)), max_retry: kmsg.max_retry.unwrap_or(2) };
                            if dispatcher.enqueue(kmsg.to as UserId, msg, opts) { Ok(()) } else { Err(anyhow!("dispatch queue full")) }
                        }
                        Err(e) => { error!("kafka payload decode error: {:?}", e); Err(anyhow!("decode")) }
                    }
                } else { Err(anyhow!("empty payload")) }
            }
        }).await; // never returns
    });

    Ok(())
}
