//! 好友消息处理器（FriendHandler）
//!
//! 设计目标（入站 → 路由 → 回执）：
//! - 去重：仅使用“客户端消息ID”（client_id）为相同消息提供幂等保护；
//! - 动态路由：通过 NodeUtil 与 arb-service 动态发现 msg_friend 节点，按 userId 做一致性选择；
//! - 关系操作：201..205 通过 hot_friend_service 完成增删改（申请/受理/删除/备注）；
//! - 成功回执：业务处理成功后，向客户端下发简化 ACK（ServerMsg.kind= MkAck，ServerMsg.id = client_id）；
//! - 非阻塞：handler 内部使用 tokio::spawn，不阻塞接入线程。

use log::{info, warn};
use prost::Message;

use crate::service::types::{ClientMsg, UserId, MessageId};
use super::Handler;
use crate::util::node_util::fetch_msg_friend_addr;
use crate::util::node_util::NodeUtil;
use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_msg_friend::msg_friend_service as friend_biz;
use crate::grpc_msg_friend::client as friend_biz_client;
use std::hash::Hasher;
// 关系操作在 msg_friend 内部对接 hot_friend_service；app_socket 不直接依赖 HfFriendClient
use crate::grpc_msg_friend::msg_friend_service as msgpb;
use crate::service::session::SessionManager;
use crate::service::types::{MsgKind, ServerMsg, SendOpts};
use std::time::{SystemTime, UNIX_EPOCH, Duration};

/// 好友消息处理器（100..300）
///
/// 主要职责：
/// - 解析上行 ClientMsg，并执行：
///   - 100..106 → 转发给 msg_friend（存储/转发/Kafka）；
///   - 201..205 → 调用 hot_friend_service 完成好友关系操作；
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
        info!("FriendHandler: uid={} kind={} payload_len={}", user, msg.kind as i32, msg.payload.len());
        // 1) 使用 client_id 进行去重
        let ref_id: Option<MessageId> = msg.client_id;
        if let Some(id) = ref_id {
            if SessionManager::get().seen_or_track_client_id(&user, id) {
                // 重复消息：直接忽略
                return;
            }
        }

        let payload = msg.payload.clone();
        let kind = msg.kind;
        // 2) 异步处理：避免阻塞接入线程
        tokio::spawn(async move {
            // 优先从 NodeUtil 读取并按用户做一致选择
            let nodes = NodeUtil::get().get_list(NodeType::MsgFriend);
            let addr = if !nodes.is_empty() {
                let mut h = twox_hash::XxHash64::with_seed(0);
                h.write(user.to_string().as_bytes());
                let idx = (h.finish() % (nodes.len() as u64)) as usize;
                nodes[idx].node_addr.clone()
            } else {
                match fetch_msg_friend_addr().await { Some(a)=>a, None=>"127.0.0.1:8090".to_string() }
            };
            let endpoint = format!("http://{}", addr);
            let mut client = match msgpb::friend_msg_service_client::FriendMsgServiceClient::connect(endpoint).await {
                Ok(c) => c,
                Err(e) => { warn!("friend-msg client connect failed: {}", e); return; }
            };
            // 调用是否成功（用于决定是否下发 ACK）
            let mut processed_ok = false;
            match kind {
                MsgKind::MkFriend => {
                    match msgpb::Content::decode(&*payload) {
                        Ok(c) => { if client.send_message(c).await.is_ok() { processed_ok = true; } }
                        Err(e) => warn!("decode Content failed: {}", e),
                    }
                }
                MsgKind::MkFriendMsgRead => {
                    match msgpb::MsgRead::decode(&*payload) {
                        Ok(r) => { if client.report_msg_read(r).await.is_ok() { processed_ok = true; } }
                        Err(e) => warn!("decode MsgRead failed: {}", e),
                    }
                }
                MsgKind::MkFriendMsgDeliveredAck => {
                    match msgpb::MsgDeliveredAck::decode(&*payload) {
                        Ok(r) => { if client.ack_msg_delivered(r).await.is_ok() { processed_ok = true; } }
                        Err(e) => warn!("decode MsgDeliveredAck failed: {}", e),
                    }
                }
                MsgKind::MkFriendMsgReadAck => {
                    match msgpb::MsgReadAck::decode(&*payload) {
                        Ok(r) => { if client.ack_msg_read(r).await.is_ok() { processed_ok = true; } }
                        Err(e) => warn!("decode MsgReadAck failed: {}", e),
                    }
                }
                MsgKind::MkFriendMsgRecall => {
                    match msgpb::MsgRecall::decode(&*payload) {
                        Ok(r) => { if client.recall_msg(r).await.is_ok() { processed_ok = true; } }
                        Err(e) => warn!("decode MsgRecall failed: {}", e),
                    }
                }
                MsgKind::MkFriendMsgForward => {
                    match msgpb::MsgForward::decode(&*payload) {
                        Ok(r) => { if client.forward_msg(r).await.is_ok() { processed_ok = true; } }
                        Err(e) => warn!("decode MsgForward failed: {}", e),
                    }
                }
                // 其它好友消息类型：目前后端未提供专门 RPC，先记录并返回成功 ACK
                MsgKind::MkFriendMsgDelivered => {
                    // 已送达通知（客户端→服务端），服务端当前不落库，仅 ACK
                    processed_ok = true;
                }
                MsgKind::MkFriendMsgEdit => {
                    // 消息编辑（暂未实现具体后端处理）
                    info!("FriendHandler: MkFriendMsgEdit not implemented yet");
                    processed_ok = true;
                }
                MsgKind::MkFriendMsgReaction => {
                    // 表态/Reaction（暂未实现具体后端处理）
                    info!("FriendHandler: MkFriendMsgReaction not implemented yet");
                    processed_ok = true;
                }
                MsgKind::MkFriendTyping => {
                    // 正在输入（仅作信令，不落库），直接 ACK
                    processed_ok = true;
                }
                // 通话相关（invite/cancel/reject/accept/hangup/modify/dtmf）：占位实现
                MsgKind::MkFriendCallInvite
                | MsgKind::MkFriendCallCancel
                | MsgKind::MkFriendCallReject
                | MsgKind::MkFriendCallAccept
                | MsgKind::MkFriendCallHangup
                | MsgKind::MkFriendCallModify
                | MsgKind::MkFriendCallDtmf => {
                    info!("FriendHandler: call signaling {:?} not implemented yet", kind);
                    processed_ok = true; // 返回 ACK，表示已接收信令
                }
                // 关系类 201..205：转发到 msg_friend 的 FriendBizService
                MsgKind::MkFriendRequest => {
                    match friend_biz::FriendRequest::decode(&*payload) {
                        Ok(r) => {
                            let mut biz = match friend_biz_client::connect(&addr).await { Ok(c)=>c, Err(e)=>{ warn!("friend-biz client connect failed: {}", e); return; } };
                            if biz.send_friend_request(r).await.is_ok() { processed_ok = true; }
                        }
                        Err(e) => warn!("decode FriendRequest failed: {}", e),
                    }
                }
                MsgKind::MkFriendRequestAck => {
                    match friend_biz::FriendRequestDecision::decode(&*payload) {
                        Ok(r) => {
                            let mut biz = match friend_biz_client::connect(&addr).await { Ok(c)=>c, Err(e)=>{ warn!("friend-biz client connect failed: {}", e); return; } };
                            if biz.handle_friend_request(r).await.is_ok() { processed_ok = true; }
                        }
                        Err(e) => warn!("decode FriendRequestDecision failed: {}", e),
                    }
                }
                MsgKind::MkFriendRequestReject => {
                    match friend_biz::FriendRequestDecision::decode(&*payload) {
                        Ok(r) => {
                            let mut biz = match friend_biz_client::connect(&addr).await { Ok(c)=>c, Err(e)=>{ warn!("friend-biz client connect failed: {}", e); return; } };
                            if biz.handle_friend_request(r).await.is_ok() { processed_ok = true; }
                        }
                        Err(e) => warn!("decode FriendRequestDecision failed: {}", e),
                    }
                }
                MsgKind::MkFriendDelete => {
                    match friend_biz::FriendDelete::decode(&*payload) {
                        Ok(r) => {
                            let mut biz = match friend_biz_client::connect(&addr).await { Ok(c)=>c, Err(e)=>{ warn!("friend-biz client connect failed: {}", e); return; } };
                            if biz.delete_friend(r).await.is_ok() { processed_ok = true; }
                        }
                        Err(e) => warn!("decode FriendDelete failed: {}", e),
                    }
                }
                MsgKind::MkFriendUpdateRemark => {
                    match friend_biz::FriendUpdateRemark::decode(&*payload) {
                        Ok(r) => {
                            let mut biz = match friend_biz_client::connect(&addr).await { Ok(c)=>c, Err(e)=>{ warn!("friend-biz client connect failed: {}", e); return; } };
                            if biz.update_friend_remark(r).await.is_ok() { processed_ok = true; }
                        }
                        Err(e) => warn!("decode FriendUpdateRemark failed: {}", e),
                    }
                }
                other => { info!("FriendHandler: unhandled kind={} for now", other as i32); }
            }

            // 4) 处理成功：下发简化 ACK（MkAck，id=client_id）
            if processed_ok {
                let now_ms = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_millis() as i64;
                if let Some(cid) = ref_id {
                    let ack_msg = ServerMsg { id: cid, kind: MsgKind::MkAck, payload: Vec::new(), ts_ms: now_ms };
                    let _ = SessionManager::get().send_to_user(user, ack_msg, SendOpts { require_ack: false, expire: Duration::from_millis(0), max_retry: 0 });
                }
            }
        });
    }
}

// 别名：满足“FriendMsgHandler”的命名需求
pub type FriendMsgHandler = FriendHandler;
