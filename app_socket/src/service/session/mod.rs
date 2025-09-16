//! 会话管理与 ACK 跟踪模块。
//!
//! 子模块按职责拆分：
//! - `handle`: 单条会话的发送句柄封装；
//! - `ack`: ACK 分片追踪与延迟队列重试；
//! - `policy`: 多端登录策略与容量限制配置；
//! - `manager`: `SessionManager` 实现，协调会话注册/扇出/ACK 处理；
//! - `metrics`: 内部指标计数器，供各子模块共享。

mod ack;
mod handle;
mod manager;
mod metrics;
mod policy;

pub use handle::SessionHandle;
pub use manager::SessionManager;
pub use policy::{MultiLoginPolicy, SessionPolicy};
