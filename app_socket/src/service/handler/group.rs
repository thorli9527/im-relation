use log::info;

use super::Handler;
use crate::service::types::{ClientMsg, UserId};

/// 群消息处理器（300..500）。
///
/// 当前仅记录日志，后续可以在此处解析具体业务载荷并转发到群聊服务。
pub struct GroupHandler;

impl Handler for GroupHandler {
    fn handle(&self, user: UserId, msg: &ClientMsg) {
        info!(
            "GroupHandler: uid={} kind={} payload_len={}",
            user,
            msg.kind as i32,
            msg.payload.len()
        );
        // 预留扩展点：可在此处解析 msg.payload（protobuf）并调用群聊后端服务。
    }
}
