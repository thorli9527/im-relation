//! 业务上行消息处理器
//!
//! 职责：根据上行 `ClientMsg.kind` 归类到好友/群/系统三类处理器。
//! 具体处理逻辑分布在子模块 `friend`、`group`、`system`。

use crate::service::types::{ClientMsg, UserId};

/// 通用处理器接口（同步处理）。
///
/// `handle` 的实现通常为轻量逻辑：解析 `ClientMsg`、调用远端 gRPC 并在成功时
/// 触发 ACK。为了避免阻塞网络线程，上层调用会在独立任务中执行繁重工作。
pub trait Handler {
    fn handle(&self, user: UserId, msg: &ClientMsg);
}

pub mod friend;
pub mod group;
pub mod system;

// 统一对外导出，保持上层使用路径不变
pub use friend::{FriendHandler, FriendMsgHandler};
pub use group::GroupHandler;
pub use system::SystemHandler;
