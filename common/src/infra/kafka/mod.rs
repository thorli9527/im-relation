//! Kafka 生产、消费工具与 topic 元数据定义。

pub mod kafka_consumer;
pub mod kafka_producer;
pub mod topic_info;

/// 直接暴露消费入口，方便业务快速引入。
pub use kafka_consumer::start_consumer;
