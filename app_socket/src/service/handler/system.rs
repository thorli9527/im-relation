use log::info;

use super::Handler;
use crate::service::types::{ClientMsg, UserId};

/// 系统消息处理器（900..1000）。
///
/// 该分类通常用于公告、通知或平台级事件。当前实现仅记录日志，后续可在此处
/// 集成系统消息中心或推送逻辑。
pub struct SystemHandler;

impl Handler for SystemHandler {
    fn handle(&self, user: UserId, msg: &ClientMsg) {
        info!(
            "SystemHandler: uid={} kind={} payload_len={}",
            user,
            msg.kind as i32,
            msg.payload.len()
        );
        // TODO: 解析 payload 并根据业务需求写入数据库或广播。
    }
}
