use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use common::config::AppConfig;
use common::kafka::{kafka_producer::KafkaInstanceService, topic_info::MSG_SEND_FRIEND_TOPIC};

/// 初始化好友消息模块使用的 Kafka 生产端。
///
/// 如果配置文件缺失 `kafka.broker` 项，则直接报错中止启动，避免静默丢失消息。
pub async fn init_friend_kafka(cfg: &AppConfig) -> Result<Arc<KafkaInstanceService>> {
    let kafka_cfg = cfg.kafka_cfg();
    let broker = kafka_cfg.broker.clone().ok_or_else(|| {
        anyhow!("kafka.broker not configured; please set it in config-msg-friend.toml")
    })?;

    let replicas = kafka_cfg.replicas.unwrap_or(1).max(1);
    let topics = vec![MSG_SEND_FRIEND_TOPIC.with_replicas(replicas)];
    let producer = KafkaInstanceService::new(&broker, &topics)
        .await
        .context("init kafka producer for msg_friend")?;

    Ok(Arc::new(producer))
}
