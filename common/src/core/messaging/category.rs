//! 消息分类枚举与与 protobuf 枚举间的映射逻辑。

use crate::infra::grpc::grpc_socket::socket::MsgKind;

/// 领域层关心的消息类别划分。
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MsgCategory {
    Friend,
    Group,
    System,
    Unknown,
}

impl MsgKind {
    /// 根据 protobuf 枚举推导领域分类，方便做分支控制。
    pub fn category(&self) -> MsgCategory {
        use MsgKind::*;
        match self {
            // 好友相关枚举全部归为 Friend。
            MkFriend
            | MkFriendMsgReadAck
            | MkFriendMsgRecall
            | MkFriendMsgDeliveredAck
            | MkFriendMsgRead
            | MkFriendMsgDelivered
            | MkFriendMsgForward
            | MkFriendMsgEdit
            | MkFriendMsgReaction
            | MkFriendTyping
            | MkFriendCallInvite
            | MkFriendCallCancel
            | MkFriendCallReject
            | MkFriendCallAccept
            | MkFriendCallHangup
            | MkFriendCallModify
            | MkFriendCallDtmf
            | MkFriendRequest
            | MkFriendRequestAck
            | MkFriendRequestReject
            | MkFriendDelete
            | MkFriendUpdateRemark => MsgCategory::Friend,
            // 群聊相关枚举映射到 Group。
            MkGroup
            | MkGroupMsgReadAck
            | MkGroupMsgRecall
            | MkGroupAtAll
            | MkGroupAtUser
            | MkGroupMsgEdit
            | MkGroupMsgReaction
            | MkGroupMsgDelivered
            | MkGroupMsgDeliveredAck
            | MkGroupMsgRead
            | MkGroupTyping
            | MkGroupJoinRequest
            | MkGroupJoinRequestAck
            | MkGroupUpdateName
            | MkGroupUpdateAnnouncement
            | MkGroupUpdateAvatar
            | MkGroupMemberAdd
            | MkGroupMemberDelete
            | MkGroupMemberQuit
            | MkGroupMemberUpdate
            | MkGroupDismiss
            | MkGroupTransfer => MsgCategory::Group,
            // 其余通用/系统枚举归类到 System。
            MkSysNotice | MkUserPresence | MkUserProfileUpdate | MkUserPrivacyUpdate
            | MkUserAccountData | MkMsgRecall | MkAck | MkHeartbeat => MsgCategory::System,
            // 未识别的类型统一标记为 Unknown，后续上游可兜底处理。
            MkUnknown => MsgCategory::Unknown,
        }
    }
}
