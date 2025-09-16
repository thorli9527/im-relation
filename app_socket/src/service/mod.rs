//! Socket 服务模块总览（按职责分层）
//!
//! 结构与职责：
//! - `types`：基础类型与消息模型（ServerMsg/ClientMsg/SendOpts 等）；
//! - `session`：会话注册、扇出下发、ACK 跟踪与重试（并发核心，内含分片定时器）；
//! - `dispatcher`：按用户一致性哈希做分片，有界 mpsc 背压，降低跨用户互相影响；
//! - `pipeline`：Kafka → 分片调度 → SessionManager 的端到端落地；
//! - `handler`：上行消息处理（解析 ClientMsg，转发到各业务 gRPC）。
//!
//! 线程模型与并发：
//! - 入口（TCP/WebSocket）负责解析与投递到 `SessionManager::on_client_msg`；
//! - 下行由 `dispatcher` 入队，分片任务从队列读取并调用 `SessionManager::send_to_user` 扇出；
//! - ACK 跟踪在 `session` 内分片管理，使用 DelayQueue 定时重试，避免全量扫描；
//! - 大部分共享结构使用 DashMap/Arc 包装，读多写少场景性能稳定。
//!
//! 可靠性：
//! - Kafka 侧“入队成功再确认”保证至少一次；
//! - 端到端 ACK + 超时重试保证“尽力送达”；
//! - 队列满/无在线会话等异常路径会有节流日志与指标（可对接监控）。

pub mod dispatcher;
pub mod grpc_clients;
pub mod handler;
pub mod pipeline;
pub mod session;
pub mod types;

// 对外再导出，维持原有对外 API
pub use pipeline::start_socket_pipeline;
pub use session::{MultiLoginPolicy, SessionManager, SessionPolicy};
pub use types::{ClientMsg, SendOpts, ServerMsg};
