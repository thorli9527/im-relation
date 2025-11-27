use serde::{Deserialize, Serialize};

use crate::{
    common::repository::PageResult,
    domain::{
        ConversationEntity, FriendEntity, FriendRequestEntity, GroupEntity, GroupRequestEntity,
        MessageEntity,
    },
};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FriendPageResult {
    pub items: Vec<FriendEntity>,
    pub has_next: bool,
    pub has_prev: bool,
}

impl From<PageResult<FriendEntity>> for FriendPageResult {
    fn from(value: PageResult<FriendEntity>) -> Self {
        Self {
            items: value.items,
            has_next: value.has_next,
            has_prev: value.has_prev,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConversationPageResult {
    pub items: Vec<ConversationEntity>,
    pub has_next: bool,
    pub has_prev: bool,
}

impl From<PageResult<ConversationEntity>> for ConversationPageResult {
    fn from(value: PageResult<ConversationEntity>) -> Self {
        Self {
            items: value.items,
            has_next: value.has_next,
            has_prev: value.has_prev,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupPageResult {
    pub items: Vec<GroupEntity>,
    pub has_next: bool,
    pub has_prev: bool,
}

impl From<PageResult<GroupEntity>> for GroupPageResult {
    fn from(value: PageResult<GroupEntity>) -> Self {
        Self {
            items: value.items,
            has_next: value.has_next,
            has_prev: value.has_prev,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MessagePageResult {
    pub items: Vec<MessageEntity>,
    pub has_next: bool,
    pub has_prev: bool,
}

impl From<PageResult<MessageEntity>> for MessagePageResult {
    fn from(value: PageResult<MessageEntity>) -> Self {
        Self {
            items: value.items,
            has_next: value.has_next,
            has_prev: value.has_prev,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupRequestPageResult {
    pub items: Vec<GroupRequestEntity>,
    pub has_next: bool,
    pub has_prev: bool,
}

impl From<PageResult<GroupRequestEntity>> for GroupRequestPageResult {
    fn from(value: PageResult<GroupRequestEntity>) -> Self {
        Self {
            items: value.items,
            has_next: value.has_next,
            has_prev: value.has_prev,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FriendRequestPageResult {
    pub items: Vec<FriendRequestEntity>,
    pub has_next: bool,
    pub has_prev: bool,
}

impl From<PageResult<FriendRequestEntity>> for FriendRequestPageResult {
    fn from(value: PageResult<FriendRequestEntity>) -> Self {
        Self {
            items: value.items,
            has_next: value.has_next,
            has_prev: value.has_prev,
        }
    }
}
