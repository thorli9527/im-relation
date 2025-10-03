use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use common::config::AppConfig;
use common::kafka::{kafka_producer::KafkaInstanceService, topic_info::MSG_SEND_GROUP_TOPIC};

/// 初始化群聊消息模块使用的 Kafka 生产端。
///
/// 若配置文件中缺失 `kafka.broker`，直接返回错误以阻止服务启动。
pub async fn init_group_kafka(cfg: &AppConfig) -> Result<Arc<KafkaInstanceService>> {
    let broker = cfg.kafka_cfg().broker.clone().ok_or_else(|| {
        anyhow!("kafka.broker not configured; please set it in config-msg-group.toml")
    })?;

    let topics = vec![MSG_SEND_GROUP_TOPIC.clone()];
    let producer = KafkaInstanceService::new(&broker, &topics)
        .await
        .context("init kafka producer for msg_group")?;

    Ok(Arc::new(producer))
}
