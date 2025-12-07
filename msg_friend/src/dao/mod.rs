//! 好友消息相关的数据访问模块。

pub mod conversation_snapshot;
pub mod friend_requests;
pub mod messages;

#[allow(unused_imports)]
pub use messages::{
    copy_message_as_forward, get_message_by_id, insert_encrypted_message,
    list_conversation_messages, mark_delivered, mark_read, recall_message, EncryptedMessageRecord,
};

pub use friend_requests::{
    get_friend_request_by_id, increment_friend_request_notify_retry,
    list_friend_requests_pending_notify, mark_friend_request_decision,
    mark_friend_request_notified, upsert_friend_request, FriendRequestRow,
};

pub use conversation_snapshot::{
    delete_friend_conversation_snapshot, list_friend_conversation_snapshots,
    upsert_friend_conversation_snapshot, FriendConversationSnapshot,
};
