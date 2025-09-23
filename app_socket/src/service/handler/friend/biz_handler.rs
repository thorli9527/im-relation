use log::warn;
use prost::Message;

use crate::service::grpc_clients;
use crate::service::types::MsgKind;
use common::grpc::grpc_msg_friend::msg_friend_service as friend_biz;

/// 处理好友关系类枚举。解码失败或网络异常会返回 `false`，以便上层不发送 ACK。
pub async fn handle(addr: &str, kind: MsgKind, payload: &[u8]) -> Option<bool> {
    match kind {
        MsgKind::MkFriendRequest => Some(handle_friend_request(addr, payload).await),
        MsgKind::MkFriendRequestAck | MsgKind::MkFriendRequestReject => {
            Some(handle_friend_request_decision(addr, payload).await)
        }
        MsgKind::MkFriendDelete => Some(handle_friend_delete(addr, payload).await),
        MsgKind::MkFriendUpdateRemark => Some(handle_friend_update_remark(addr, payload).await),
        _ => None,
    }
}

async fn handle_friend_request(addr: &str, payload: &[u8]) -> bool {
    match friend_biz::FriendRequest::decode(payload) {
        Ok(req) => match grpc_clients::friend_biz_client(addr).await {
            Ok(mut client) => client.send_friend_request(req).await.is_ok(),
            Err(e) => {
                // 连接失败需记录日志，方便排查节点不可达问题。
                warn!("friend-biz client connect failed: {}", e);
                false
            }
        },
        Err(e) => {
            warn!("decode FriendRequest failed: {}", e);
            false
        }
    }
}

async fn handle_friend_request_decision(addr: &str, payload: &[u8]) -> bool {
    match friend_biz::FriendRequestDecision::decode(payload) {
        Ok(req) => match grpc_clients::friend_biz_client(addr).await {
            Ok(mut client) => client.handle_friend_request(req).await.is_ok(),
            Err(e) => {
                warn!("friend-biz client connect failed: {}", e);
                false
            }
        },
        Err(e) => {
            warn!("decode FriendRequestDecision failed: {}", e);
            false
        }
    }
}

async fn handle_friend_delete(addr: &str, payload: &[u8]) -> bool {
    match friend_biz::FriendDelete::decode(payload) {
        Ok(req) => match grpc_clients::friend_biz_client(addr).await {
            Ok(mut client) => client.delete_friend(req).await.is_ok(),
            Err(e) => {
                warn!("friend-biz client connect failed: {}", e);
                false
            }
        },
        Err(e) => {
            warn!("decode FriendDelete failed: {}", e);
            false
        }
    }
}

async fn handle_friend_update_remark(addr: &str, payload: &[u8]) -> bool {
    match friend_biz::FriendUpdateRemark::decode(payload) {
        Ok(req) => match grpc_clients::friend_biz_client(addr).await {
            Ok(mut client) => client.update_friend_remark(req).await.is_ok(),
            Err(e) => {
                warn!("friend-biz client connect failed: {}", e);
                false
            }
        },
        Err(e) => {
            warn!("decode FriendUpdateRemark failed: {}", e);
            false
        }
    }
}
