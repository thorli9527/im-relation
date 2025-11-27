pub mod auth_service;
pub mod config_service;
pub mod conversation_service;
pub mod friend_service;
pub mod group_request_service;
pub mod friend_request_service;
pub mod group_member_service;
pub mod group_service;
pub mod message_service;
pub mod online_service;
pub mod read_cursor_service;
pub mod socket_client;
pub mod sync_service;
pub mod sync_state_service;
pub mod user_service;

pub fn init() {
    crate::common::init_logging();
    if let Err(err) = config_service::ConfigService::init() {
        eprintln!("ConfigService init failed: {err}");
    }
    if let Err(err) = friend_service::FriendService::init() {
        eprintln!("FriendService init failed: {err}");
    }
    if let Err(err) = group_request_service::GroupRequestService::init() {
        eprintln!("GroupRequestService init failed: {err}");
    }
    if let Err(err) = friend_request_service::FriendRequestService::init() {
        eprintln!("FriendRequestService init failed: {err}");
    }
    if let Err(err) = user_service::UserService::init() {
        eprintln!("UserService init failed: {err}");
    }
    if let Err(err) = group_service::GroupService::init() {
        eprintln!("GroupService init failed: {err}");
    }
    if let Err(err) = group_member_service::GroupMemberService::init() {
        eprintln!("GroupMemberService init failed: {err}");
    }
    if let Err(err) = conversation_service::ConversationService::init() {
        eprintln!("ConversationService init failed: {err}");
    }
    if let Err(err) = message_service::MessageService::init() {
        eprintln!("MessageService init failed: {err}");
    }
    if let Err(err) = read_cursor_service::ReadCursorService::init() {
        eprintln!("ReadCursorService init failed: {err}");
    }
    if let Err(err) = sync_state_service::SyncStateService::init() {
        eprintln!("SyncStateService init failed: {err}");
    } else if let Err(err) = sync_state_service::SyncStateService::ensure_row() {
        eprintln!("SyncStateService ensure_row failed: {err}");
    }
    if let Err(err) = online_service::OnlineService::init() {
        eprintln!("OnlineService init failed: {err}");
    }
    if let Err(err) = socket_client::SocketClient::init() {
        eprintln!("SocketClient init failed: {err}");
    }
}
