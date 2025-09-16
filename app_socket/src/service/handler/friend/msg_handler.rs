use log::{info, warn};
use prost::Message;
use tonic::transport::Channel;

use crate::grpc_msg_friend::msg_friend_service as msgpb;
use crate::service::types::MsgKind;

type FriendMsgClient = msgpb::friend_msg_service_client::FriendMsgServiceClient<Channel>;

/// 处理好友消息类枚举，返回是否成功（`None` 表示此枚举不由本模块处理）。
pub async fn handle(kind: MsgKind, payload: &[u8], client: &mut FriendMsgClient) -> Option<bool> {
    match kind {
        MsgKind::MkFriend => Some(handle_send_message(payload, client).await),
        MsgKind::MkFriendMsgRead => Some(handle_msg_read(payload, client).await),
        MsgKind::MkFriendMsgDeliveredAck => Some(handle_delivered_ack(payload, client).await),
        MsgKind::MkFriendMsgReadAck => Some(handle_read_ack(payload, client).await),
        MsgKind::MkFriendMsgRecall => Some(handle_msg_recall(payload, client).await),
        MsgKind::MkFriendMsgForward => Some(handle_msg_forward(payload, client).await),
        MsgKind::MkFriendMsgDelivered => Some(true),
        MsgKind::MkFriendMsgEdit => {
            info!("FriendHandler: MkFriendMsgEdit not implemented yet");
            Some(true)
        }
        MsgKind::MkFriendMsgReaction => {
            info!("FriendHandler: MkFriendMsgReaction not implemented yet");
            Some(true)
        }
        MsgKind::MkFriendTyping => Some(true),
        _ => None,
    }
}

async fn handle_send_message(payload: &[u8], client: &mut FriendMsgClient) -> bool {
    match msgpb::Content::decode(payload) {
        Ok(content) => client.send_message(content).await.is_ok(),
        Err(e) => {
            // 解码失败多半是客户端协议版本不一致，记录日志便于排查。
            warn!("decode Content failed: {}", e);
            false
        }
    }
}

async fn handle_msg_read(payload: &[u8], client: &mut FriendMsgClient) -> bool {
    match msgpb::MsgRead::decode(payload) {
        Ok(req) => client.report_msg_read(req).await.is_ok(),
        Err(e) => {
            warn!("decode MsgRead failed: {}", e);
            false
        }
    }
}

async fn handle_delivered_ack(payload: &[u8], client: &mut FriendMsgClient) -> bool {
    match msgpb::MsgDeliveredAck::decode(payload) {
        Ok(req) => client.ack_msg_delivered(req).await.is_ok(),
        Err(e) => {
            warn!("decode MsgDeliveredAck failed: {}", e);
            false
        }
    }
}

async fn handle_read_ack(payload: &[u8], client: &mut FriendMsgClient) -> bool {
    match msgpb::MsgReadAck::decode(payload) {
        Ok(req) => client.ack_msg_read(req).await.is_ok(),
        Err(e) => {
            warn!("decode MsgReadAck failed: {}", e);
            false
        }
    }
}

async fn handle_msg_recall(payload: &[u8], client: &mut FriendMsgClient) -> bool {
    match msgpb::MsgRecall::decode(payload) {
        Ok(req) => client.recall_msg(req).await.is_ok(),
        Err(e) => {
            warn!("decode MsgRecall failed: {}", e);
            false
        }
    }
}

async fn handle_msg_forward(payload: &[u8], client: &mut FriendMsgClient) -> bool {
    match msgpb::MsgForward::decode(payload) {
        Ok(req) => client.forward_msg(req).await.is_ok(),
        Err(e) => {
            warn!("decode MsgForward failed: {}", e);
            false
        }
    }
}
