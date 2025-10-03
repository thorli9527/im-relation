//! 好友消息处理器（FriendHandler）
//!
//! 设计目标（入站 → 路由 → 回执）：
//! - 去重：仅使用“客户端消息ID”（client_id）为相同消息提供幂等保护；
//! - 动态路由：通过 NodeUtil 与 arb_service 动态发现 msg_friend 节点，按 userId 做一致性选择；
//! - 关系操作：201..205 通过 friend_service 完成增删改（申请/受理/删除/备注）；
//! - 成功回执：业务处理成功后，向客户端下发简化 ACK（ServerMsg.kind= MkAck，ServerMsg.id = client_id）；
//! - 非阻塞：handler 内部使用 tokio::spawn，不阻塞接入线程。

mod biz_handler;
mod call_handler;
mod msg_handler;

use std::hash::Hasher;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use log::{info, warn};
use prost::Message;
use std::convert::TryFrom;
use twox_hash::XxHash64;

use crate::service::grpc_clients;
use crate::service::node_discovery::fetch_msg_friend_addr;
use crate::service::session::SessionManager;
use crate::service::types::{ClientMsg, MessageId, MsgKind, SendOpts, ServerMsg, UserId};
use common::arb::NodeType;
use common::grpc::message::{self as msg_message, typing::Target as TypingTarget, TypingState};
use common::node_util::NodeUtil;
use time::OffsetDateTime;

use super::Handler;

/// 好友消息处理器（100..300）
///
/// 主要职责：
/// - 解析上行 ClientMsg，并执行：
///   - 100..106 → 转发给 msg_friend（存储/转发/Kafka）；
///   - 201..205 → 调用 friend_service 完成好友关系操作；
/// - 幂等：在处理前进行去重（最近 50 条）；
/// - 成功后发送 ACK（包含原请求 kind 与 ref_message_id）。
pub struct FriendHandler;

impl Handler for FriendHandler {
    /// 处理好友相关上行消息。
    ///
    /// 流程：
    /// 1) 使用 client_id 进行去重；
    /// 2) 依据 NodeUtil/arb 选择 msg_friend 节点；
    /// 3) 按 kind 调用目标 gRPC 服务；
    /// 4) 若成功（processed_ok），构造标准化 AckContent 并下发 ACK。
    fn handle(&self, user: UserId, msg: &ClientMsg) {
        info!(
            "FriendHandler: uid={} kind={} payload_len={}",
            user,
            msg.kind as i32,
            msg.payload.len()
        );

        let ref_id: Option<MessageId> = msg.client_id;
        if let Some(id) = ref_id {
            if SessionManager::get().seen_or_track_client_id(&user, id) {
                return;
            }
        }

        if msg.kind == MsgKind::MkFriendTyping {
            if handle_friend_typing(user, &msg.payload) {
                return;
            }
        }

        let payload = msg.payload.clone();
        let kind = msg.kind;

        tokio::spawn(async move {
            let nodes = NodeUtil::get().get_list(NodeType::MsgFriend as i32);
            let addr = if !nodes.is_empty() {
                let mut h = XxHash64::with_seed(0);
                h.write(user.to_string().as_bytes());
                let idx = (h.finish() % (nodes.len() as u64)) as usize;
                // 根据用户 ID 做一致性取模，保证同一用户优先访问固定节点。
                nodes[idx].clone()
            } else {
                match fetch_msg_friend_addr().await {
                    Ok(Some(a)) => a,
                    Ok(None) => return,
                    Err(e) => {
                        log::warn!("fetch_msg_friend_addr failed: {}", e);
                        return;
                    }
                }
            };

            let mut client = match grpc_clients::friend_msg_client(&addr).await {
                Ok(c) => c,
                Err(e) => {
                    log::warn!("friend-msg client connect failed: {}", e);
                    return;
                }
            };

            let mut processed_ok = false;
            if let Some(result) = msg_handler::handle(kind, &payload, &mut client).await {
                processed_ok = result;
            } else if let Some(result) = call_handler::handle(kind) {
                processed_ok = result;
            } else if let Some(result) = biz_handler::handle(&addr, kind, &payload).await {
                processed_ok = result;
            } else {
                info!("FriendHandler: unhandled kind={} for now", kind as i32);
            }

            if processed_ok {
                let now_ms = SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_millis() as i64;
                if let Some(cid) = ref_id {
                    let ack_msg = ServerMsg {
                        id: cid,
                        kind: MsgKind::MkAck,
                        payload: Vec::new(),
                        ts_ms: now_ms,
                    };
                    let _ = SessionManager::get().send_to_user(
                        user,
                        ack_msg,
                        SendOpts {
                            require_ack: false,
                            expire: Duration::from_millis(0),
                            max_retry: 0,
                            ack_hook: None,
                            drop_hook: None,
                        },
                    );
                }
            }
        });
    }
}

pub type FriendMsgHandler = FriendHandler;

fn handle_friend_typing(user: UserId, payload: &[u8]) -> bool {
    match msg_message::Typing::decode(payload) {
        Ok(typing) => {
            let state = TypingState::try_from(typing.state).unwrap_or(TypingState::TypingNone);
            let at_ms = if typing.at == 0 {
                (OffsetDateTime::now_utc().unix_timestamp_nanos() / 1_000_000) as i64
            } else {
                typing.at
            };
            match typing.target {
                Some(TypingTarget::ToUserId(peer)) => {
                    SessionManager::get().update_direct_typing(user, peer, None, state, at_ms);
                    true
                }
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
                None => {
                    warn!(
                        "FriendHandler: Typing missing target uid={} state={:?}",
                        user, state
                    );
                    false
                }
            }
        }
        Err(err) => {
            warn!(
                "FriendHandler: Typing decode failed uid={} err={}",
                user, err
            );
            false
        }
    }
}
