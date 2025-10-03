//! 业务域处理模块。
//!
//! - `friend`：好友相关上行业务，例如申请、删除、备注。
//! - `group`：群聊相关业务，例如群消息、成员管理。
//! - `system`：系统通知、会话级事件等。
//!
//! 这里统一定义处理器 Trait，避免上层关心具体业务实现细节。

use crate::service::types::{ClientMsg, UserId};

/// 通用处理器接口（同步流程）。
///
/// 实现者负责解析 `ClientMsg` 并执行后续业务逻辑，通常会在内部 spawn
/// 异步任务以避免阻塞调用侧网络线程。
pub trait Handler {
    fn handle(&self, user: UserId, msg: &ClientMsg);
}

pub mod friend;
pub mod group;
pub mod system;

pub use friend::{FriendHandler, FriendMsgHandler};
pub use group::GroupHandler;
pub use system::SystemHandler;
