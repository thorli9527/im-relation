//! 业务上行消息处理器
//!
//! 职责：根据上行 `ClientMsg.kind` 归类到好友/群/系统三类处理器。
//! 具体处理逻辑分布在子模块 `friend`、`group`、`system`。

use crate::service::types::{ClientMsg, UserId};

/// 通用处理器接口（同步处理）
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
