//! 轻量封装的 Kafka 消费循环
//!
//! 特点：
//! - 采用 `StreamConsumer` 拉取消息，for-ever 循环
//! - handler 签名为 `Fn(OwnedMessage, Arc<StreamConsumer>) -> Future<Result<bool>>`
//!   - 传入 `OwnedMessage`（拥有所有权），避免生命周期问题
//!   - 带回 `StreamConsumer` 便于调用方在收到客户端 ACK 后再提交 offset
//! - 提交语义：handler 返回 `Ok(true)` 才异步提交 offset；`Ok(false)` 由业务自行提交
//! - 关闭自动提交，交由业务控制

use anyhow::Result;
use log::warn;
use std::future::Future;
use std::sync::Arc;

use crate::kafka::topic_info::TopicInfo;
use rdkafka::config::ClientConfig;
use rdkafka::consumer::{Consumer, StreamConsumer};
use rdkafka::message::OwnedMessage;

/// 启动 Kafka 消费循环
///
/// 参数：
/// - `broker`：Kafka broker 地址
/// - `group_id`：消费组 ID
/// - `topic_list`：订阅的主题集合
/// - `handler`：每条消息的处理函数，返回 Ok 表示可提交 offset
pub async fn start_consumer<F, Fut>(
    broker: &str,
    group_id: &str,
    topic_list: &Vec<TopicInfo>,
    handler: F,
) -> Result<()>
where
    F: Fn(OwnedMessage, Arc<StreamConsumer>) -> Fut + Send + Sync + 'static,
    Fut: Future<Output = Result<bool>> + Send,
{
    let consumer: StreamConsumer = ClientConfig::new()
        .set("group.id", group_id)
        .set("bootstrap.servers", broker)
        // 开启 SASL 认证（具体安全策略根据集群配置调整）
        .set("security.protocol", "SASL_PLAINTEXT") // 或 SASL_SSL
        .set("sasl.mechanism", "PLAIN") // 也可用 SCRAM-SHA-256/512
        // .set("sasl.username", "admin")
        // .set("sasl.password", "admin")
        // 关闭自动提交 offset
        .set("enable.auto.commit", "false")
        .create()?;
    for topic in topic_list {
        consumer.subscribe(&[&topic.topic_name])?;
        warn!("Kafka 消费者已启动，订阅主题： {}", topic.topic_name);
    }
    let arc_consumer = Arc::new(consumer);
    loop {
        match arc_consumer.recv().await {
            Ok(msg) => {
                let owned = msg.detach();
                match handler(owned, arc_consumer.clone()).await {
                    Ok(commit_now) => {
                        if commit_now {
                            arc_consumer
                                .commit_message(&msg, rdkafka::consumer::CommitMode::Async)?;
                        }
                    }
                    Err(e) => {
                        log::error!("❌ Kafka 消息处理失败: {:?}", e);
                    }
                }
            }
            Err(e) => {
                log::error!("❌ Kafka 消费错误: {:?}", e);
            }
        }
    }
}
