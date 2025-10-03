use log::info;

use crate::service::types::MsgKind;

/// 通话信令占位处理：目前仅回 ACK，避免客户端重复上报。
pub fn handle(kind: MsgKind) -> Option<bool> {
    match kind {
        MsgKind::MkFriendCallInvite
        | MsgKind::MkFriendCallCancel
        | MsgKind::MkFriendCallReject
        | MsgKind::MkFriendCallAccept
        | MsgKind::MkFriendCallHangup
        | MsgKind::MkFriendCallModify
        | MsgKind::MkFriendCallDtmf => {
            info!(
                "FriendHandler: call signaling {:?} not implemented yet",
                kind
            );
            Some(true)
        }
        _ => None,
    }
}
