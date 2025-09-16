use log::info;

use crate::service::types::{ClientMsg, UserId};
use super::Handler;

/// 群消息处理器（300..500）
pub struct GroupHandler;

impl Handler for GroupHandler {
    fn handle(&self, user: UserId, msg: &ClientMsg) {
        info!(
            "GroupHandler: uid={} kind={} payload_len={}",
            user,
            msg.kind as i32,
            msg.payload.len()
        );
        // TODO: 解析 payload（protobuf），落库/路由业务逻辑
    }
}

