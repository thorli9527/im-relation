//! 服务入口聚合：统一暴露 TCP/Web/Kafka 等启动函数。
//!
//! - `kafka_customer`：Kafka → dispatcher → SessionManager 的分发流水线；
//! - `server_tcp`：核心 TCP 接入层（长度前缀 + Protobuf）；
//! - `server_web`：预留 Web/HTTP 服务入口，并负责与仲裁服务对接。
pub mod kafka_customer;
pub mod server_tcp;
pub mod server_web;

// Re-export only the functions that are used by consumers to avoid unused import warnings
pub use kafka_customer::start_socket_pipeline;
pub use server_tcp::start_tcp_server;
