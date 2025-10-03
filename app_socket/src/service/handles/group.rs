use log::{info, warn};
use prost::Message;
use std::convert::TryFrom;
use time::OffsetDateTime;

use super::Handler;
use crate::service::session::SessionManager;
use crate::service::types::{ClientMsg, MsgKind, UserId};
use common::grpc::message::{self as msg_message, typing::Target as TypingTarget, TypingState};

/// 群消息处理器（300..500）。
///
/// 当前仅记录日志，后续可以在此处解析具体业务载荷并转发到群聊服务。
pub struct GroupHandler;

impl Handler for GroupHandler {
    fn handle(&self, user: UserId, msg: &ClientMsg) {
        match msg.kind {
            MsgKind::MkGroupTyping => {
                if !handle_group_typing(user, &msg.payload) {
                    warn!(
                        "GroupHandler: typing handling failed uid={} len={}",
                        user,
                        msg.payload.len()
                    );
                }
            }
            other => {
                info!(
                    "GroupHandler: uid={} kind={} payload_len={}",
                    user,
                    other as i32,
                    msg.payload.len()
                );
                // 预留扩展点：可在此处解析 msg.payload（protobuf）并调用群聊后端服务。
            }
        }
    }
}

fn handle_group_typing(user: UserId, payload: &[u8]) -> bool {
    match msg_message::Typing::decode(payload) {
        Ok(typing) => {
            let state = TypingState::try_from(typing.state).unwrap_or(TypingState::TypingNone);
            let at_ms = if typing.at == 0 {
                (OffsetDateTime::now_utc().unix_timestamp_nanos() / 1_000_000) as i64
            } else {
                typing.at
            };
            match typing.target {
                Some(TypingTarget::GroupId(group_id)) => {
                    SessionManager::get().update_group_typing(
                        group_id,
                        user,
                        None,
                        state,
                        at_ms,
                        &typing.notify_user_ids,
                    );
                    true
                }
                Some(TypingTarget::ToUserId(_)) | None => {
                    warn!("GroupHandler: typing target missing group_id uid={}", user);
                    false
                }
            }
        }
        Err(err) => {
            warn!(
                "GroupHandler: decode Typing failed uid={} err={}",
                user, err
            );
            false
        }
    }
}
