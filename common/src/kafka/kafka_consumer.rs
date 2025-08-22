use std::future::Future;
use anyhow::{Result};
use log::{ warn};
use std::sync::Arc;

use rdkafka::config::ClientConfig;
use rdkafka::consumer::{Consumer, StreamConsumer};
use rdkafka::message::OwnedMessage;
use crate::kafka::topic_info::TopicInfo;
use crate::util::common_utils::build_md5;

/// 启动 Kafka 消费循环
pub async fn start_consumer<F, Fut>(
    broker: &str,
    group_id: &str,
    topic_list: &Vec<TopicInfo>,
    handler: F,
) -> Result<()>
where
    F: Fn(&OwnedMessage) -> Fut + Send + Sync + 'static,
    Fut: Future<Output = Result<()>> + Send,
{
    let consumer: StreamConsumer = ClientConfig::new()
        .set("group.id", group_id)
        .set("bootstrap.servers", broker)
        // 开启 SASL 认证
        .set("security.protocol", "SASL_PLAINTEXT") // 或 SASL_SSL
        .set("sasl.mechanism", "PLAIN")             // 常见机制还有 SCRAM-SHA-256/512
        .set("sasl.username", "admin")
        .set("sasl.password", build_md5(&broker))
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
                match handler(&owned).await {
                    Ok(_) => {
                        arc_consumer.commit_message(&msg, rdkafka::consumer::CommitMode::Async)?;
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
