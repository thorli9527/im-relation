//! 入站数据通道。
//!
//! 目前仅包含 Kafka → dispatcher → SessionManager 的流水线，后续若接入
//! 其他来源（如队列或直连服务），可在此目录扩展独立模块。

mod kafka;

pub use kafka::start_socket_pipeline;
