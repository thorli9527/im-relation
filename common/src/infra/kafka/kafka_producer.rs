//! Kafka producer 单例封装与消息发送辅助函数。

use crate::infra::kafka::topic_info::TopicInfo;
use anyhow::{anyhow, Result};
use once_cell::sync::OnceCell;
use prost::Message;
use rdkafka::admin::{AdminClient, AdminOptions, NewTopic, TopicReplication};
use rdkafka::producer::{FutureProducer, FutureRecord};
use rdkafka::ClientConfig;
use std::fmt;
use std::sync::Arc;
use std::time::Duration;

/// 管理 Kafka producer 的生命周期与常用发送逻辑。
#[derive(Clone)]
pub struct KafkaInstanceService {
    /// 实际的 Kafka producer 对象，使用 Arc 便于共享。
    pub producer: Arc<FutureProducer>,
    /// 关联的 broker 地址，便于日志记录。
    pub broker_addr: String,
}
impl fmt::Debug for KafkaInstanceService {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("KafkaGroupService")
            .field("producer", &"FutureProducer(...)")
            .finish()
    }
}
impl KafkaInstanceService {
    /// 返回当前绑定的 broker 地址。
    pub fn broker_address(&self) -> Option<&str> {
        Some(&self.broker_addr) // 假设有 broker 字段
    }
    /// 主动关闭 Kafka producer，释放连接资源
    pub async fn shutdown(&self) {
        use rdkafka::producer::Producer;

        // 提前记录关闭动作，方便排查连接状态。
        log::info!(
            "Shutting down KafkaInstanceService for broker [{}]",
            self.broker_addr
        );

        // producer 是线程安全的，flush 是 sync 的，可在 tokio 阻塞中调用
        let producer = self.producer.clone();
        let broker = self.broker_addr.clone();

        tokio::task::spawn_blocking(move || {
            let timeout = std::time::Duration::from_secs(2);
            match producer.flush(timeout) {
                _ => {
                    // flush 返回 Err 也视作完成，Kafka 会在日志中打印原因。
                    log::info!("✅ Kafka producer flushed for broker [{}]", broker);
                }
            }
        })
        .await
        .unwrap_or_else(|e| {
            log::warn!("⚠️ Kafka shutdown task panicked: {:?}", e);
        });
    }
    /// 初始化 producer，并提前确保 topic 已经存在。
    pub async fn new(broker_addr: &str, topic_list: &Vec<TopicInfo>) -> Result<Self> {
        // 启动前检查所有 topic 是否就绪。
        KafkaInstanceService::init(broker_addr, topic_list).await;
        let producer: FutureProducer = ClientConfig::new()
            .set("bootstrap.servers", broker_addr)
            .set("security.protocol", "PLAINTEXT")
            // ✅ 性能相关配置
            .set("acks", "all")
            .set("enable.idempotence", "true")
            .set("queue.buffering.max.kbytes", "10240") // 默认4000，提升内存 buffer
            .set("queue.buffering.max.ms", "5") // 延迟聚合
            .set("compression.type", "lz4") // 压缩提升吞吐
            .set("batch.num.messages", "1000")
            .set("linger.ms", "5")
            .set("message.timeout.ms", "30000")
            .create()
            .map_err(|e| anyhow!("Kafka producer create failed for {broker_addr}: {e}"))?;

        // 把 producer 包装到 Arc 中便于多处使用。
        Ok(Self {
            broker_addr: broker_addr.to_string(),
            producer: Arc::new(producer),
        })
    }

    /// 初始化所有 group 相关 topics（幂等）
    async fn init(brokers: &str, topic_list: &Vec<TopicInfo>) {
        let mut dynamic_topics = Vec::new();
        topic_list.iter().for_each(|topic| {
            // 逐个收集 topic 的元信息。
            dynamic_topics.push((topic.topic_name.clone(), topic.partitions, topic.replicas));
        });
        // dynamic_topics.push(("group-node-msg".to_string(), 3, 1));
        if let Err(e) = Self::create_topics_or_exit(&brokers, &dynamic_topics).await {
            log::error!("❌ Kafka topic 创建失败: {e}");
        } else {
            log::info!(
                "✅ KafkaGroupService 初始化完成，topic 数量 = {}",
                dynamic_topics.len()
            );
        }
    }
    /// 异步创建多个 topic，如果已存在则退出程序
    pub async fn create_topics_or_exit(
        brokers: &str,
        topics: &Vec<(String, i32, i32)>,
    ) -> Result<()> {
        let admin: AdminClient<_> = ClientConfig::new()
            // 使用 AdminClient 管理 topic。
            .set("bootstrap.servers", brokers)
            .create()
            .expect("Failed to create Kafka AdminClient");

        let topic_defs: Vec<_> = topics
            .iter()
            // 将配置转换为 NewTopic 结构。
            .map(|(name, part, rep)| NewTopic::new(name, *part, TopicReplication::Fixed(*rep)))
            .collect();

        let results = admin
            .create_topics(&topic_defs, &AdminOptions::new())
            .await
            .expect("Kafka topic creation failed");

        for result in results {
            match result {
                Ok(name) => println!("✅ Created topic: {}", name),
                Err((name, err)) if err.to_string().contains("TopicAlreadyExists") => {
                    // 已存在时仅提示，不视为失败。
                    log::info!("Kafka topic '{}' already exists: {}", name, err);
                }
                Err((name, err)) => {
                    // 创建失败说明依赖不足，直接退出。
                    log::error!("Kafka topic '{}' creation failed: {}", name, err);
                    std::process::exit(1);
                }
            }
        }
        Ok(())
    }

    /// 带类型标识的 Protobuf 消息发送（首字节 + Protobuf）
    pub async fn send_proto<M: Message>(
        &self,
        msg_type: i32,
        message: &M,
        message_id: &i64,
        topic: &str,
    ) -> Result<()> {
        // 为 payload 预留首字节的类型码空间。
        let mut payload = Vec::with_capacity(1 + message.encoded_len());
        let message_id_str = &message_id.to_string();
        // 1️⃣ 插入类型码为首字节
        payload.push(msg_type as u8);
        // 2️⃣ 编码 Protobuf 数据到后续部分
        message.encode(&mut payload)?;
        // 3️⃣ 构造 Kafka Record
        let record = FutureRecord::to(topic)
            .payload(&payload)
            .key(message_id_str);
        // 控制发送超时时间为 50ms。
        let timeout = Duration::from_millis(50);

        match self.producer.send(record, timeout).await {
            Ok(delivery) => {
                // 输出分区与 offset，便于链路追踪。
                log::info!(
                    "✅ Kafka message sent to partition: {}, offset: {}",
                    delivery.partition,
                    delivery.offset
                );
                Ok(())
            }
            Err((err, _)) => {
                // 发送失败时返回 anyhow 错误给调用者处理。
                log::error!("❌ Kafka Protobuf 发送失败: {:?}", err);
                Err(anyhow!(err))
            }
        }
    }

    /// 发送不带类型前缀的纯 Protobuf 消息。
    pub async fn send_message<M: Message>(
        &self,
        message: &M,
        message_id: &str,
        topic: &str,
    ) -> Result<()> {
        // 直接把 Protobuf 编码为 payload。
        let mut payload = Vec::with_capacity(message.encoded_len());
        message.encode(&mut payload)?;
        let record = FutureRecord::to(topic).payload(&payload).key(message_id);
        let timeout = Duration::from_millis(50);

        match self.producer.send(record, timeout).await {
            Ok(delivery) => {
                // 返回发送成功的信息。
                log::info!(
                    "✅ Kafka message sent to partition: {}, offset: {}",
                    delivery.partition,
                    delivery.offset
                );
                Ok(())
            }
            Err((err, _)) => {
                // 同样将错误透出。
                log::error!("❌ Kafka Protobuf 发送失败: {:?}", err);
                Err(anyhow!(err))
            }
        }
    }

    /// 获取单例
    pub fn get() -> Arc<Self> {
        SERVICE
            .get()
            // 如果调用前未初始化会 panic，提醒开发者先调用 new。
            .expect("KafkaService is not initialized")
            .clone()
    }
}

/// 全局保持的 Kafka producer 单例。
static SERVICE: OnceCell<Arc<KafkaInstanceService>> = OnceCell::new();
