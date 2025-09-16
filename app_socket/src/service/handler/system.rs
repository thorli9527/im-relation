use log::info;

use crate::service::types::{ClientMsg, UserId};
use super::Handler;

/// 系统消息处理器（900..1000）
pub struct SystemHandler;

impl Handler for SystemHandler {
    fn handle(&self, user: UserId, msg: &ClientMsg) {
        info!(
            "SystemHandler: uid={} kind={} payload_len={}",
            user,
            msg.kind as i32,
            msg.payload.len()
        );
        // TODO: 解析 payload（protobuf），落库/路由业务逻辑
    }
}

