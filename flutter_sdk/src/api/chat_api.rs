use flutter_rust_bridge::frb;

use crate::api::{
    errors::ApiError, ConversationPageResult, FriendPageResult, GroupPageResult, MessagePageResult,
};
use crate::service::{
    conversation_service::ConversationService, friend_service::FriendService,
    group_service::GroupService, message_service::MessageService, user_service::UserService,
};
use crate::common::{repository::QueryCondition, QueryType};
use rusqlite::types::Value;

/// 分页获取好友列表（按创建时间倒序）。
#[frb]
pub fn get_friend_page(page: u32, page_size: u32) -> Result<FriendPageResult, String> {
    FriendService::get()
        .list(&[], page, page_size)
        .map(FriendPageResult::from)
        .map_err(|err| ApiError::system(err).into_string())
}

/// 分页获取最近会话（按最后消息时间倒序）。
#[frb]
pub fn get_recent_conversations(
    page: u32,
    page_size: u32,
) -> Result<ConversationPageResult, String> {
    let current_uid = UserService::get()
        .latest_user()
        .map_err(|err| ApiError::system(err.clone()).into_string())?;
    let Some(user) = current_uid else {
        return Ok(ConversationPageResult {
            items: Vec::new(),
            has_next: false,
            has_prev: false,
        });
    };
    let conditions = vec![QueryCondition::new(
        "owner_uid",
        QueryType::Equal,
        vec![Value::Integer(user.uid)],
    )];
    ConversationService::get()
        .list(&conditions, page, page_size)
        .map(ConversationPageResult::from)
        .map_err(|err| ApiError::system(err).into_string())
}

/// 分页获取群信息（按创建时间倒序）。
#[frb]
pub fn get_group_page(page: u32, page_size: u32) -> Result<GroupPageResult, String> {
    GroupService::get()
        .list(&[], page, page_size)
        .map(GroupPageResult::from)
        .map_err(|err| ApiError::system(err).into_string())
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
        .map_err(|err| ApiError::system(err).into_string())
}
