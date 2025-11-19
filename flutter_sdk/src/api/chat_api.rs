use flutter_rust_bridge::frb;

use crate::api::{ConversationPageResult, FriendPageResult, GroupPageResult, MessagePageResult};
use crate::service::{
    conversation_service::ConversationService, friend_service::FriendService,
    group_service::GroupService, message_service::MessageService,
};

/// 分页获取好友列表（按创建时间倒序）。
#[frb]
pub fn get_friend_page(page: u32, page_size: u32) -> Result<FriendPageResult, String> {
    FriendService::get()
        .list(&[], page, page_size)
        .map(FriendPageResult::from)
}

/// 分页获取最近会话（按最后消息时间倒序）。
#[frb]
pub fn get_recent_conversations(
    page: u32,
    page_size: u32,
) -> Result<ConversationPageResult, String> {
    ConversationService::get()
        .list(&[], page, page_size)
        .map(ConversationPageResult::from)
}

/// 分页获取群信息（按创建时间倒序）。
#[frb]
pub fn get_group_page(page: u32, page_size: u32) -> Result<GroupPageResult, String> {
    GroupService::get()
        .list(&[], page, page_size)
        .map(GroupPageResult::from)
}

/// 按会话分页拉取消息，可选按消息类型过滤（按时间倒序）。
#[frb]
pub fn get_message_page(
    conversation_id: i64,
    page: u32,
    page_size: u32,
    message_type: Option<i32>,
) -> Result<MessagePageResult, String> {
    MessageService::get()
        .list_by_conversation(conversation_id, message_type, page, page_size)
        .map(MessagePageResult::from)
}
