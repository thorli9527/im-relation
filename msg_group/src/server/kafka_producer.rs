use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use common::config::AppConfig;
use common::kafka::{kafka_producer::KafkaInstanceService, topic_info::MSG_SEND_GROUP_TOPIC};

/// 初始化群聊消息模块使用的 Kafka 生产端。
///
/// 若配置文件中缺失 `kafka.broker`，直接返回错误以阻止服务启动。
pub async fn init_group_kafka(cfg: &AppConfig) -> Result<Arc<KafkaInstanceService>> {
    let kafka_cfg = cfg.kafka_cfg();
    let broker = kafka_cfg.broker.clone().ok_or_else(|| {
        anyhow!("kafka.broker not configured; please set it in config-msg-group.toml")
    })?;

    let replicas = kafka_cfg.replicas.unwrap_or(1).max(1);
    let topics = vec![MSG_SEND_GROUP_TOPIC.with_replicas(replicas)];
    let producer = KafkaInstanceService::new(&broker, &topics)
        .await
        .context("init kafka producer for msg_group")?;

    Ok(Arc::new(producer))
}
