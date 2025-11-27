use flutter_rust_bridge::frb;

use crate::{
    api::FriendRequestPageResult,
    service::friend_request_service::FriendRequestService,
};

/// 分页获取本地已同步的好友申请记录。
#[frb]
pub fn get_friend_request_page(
    page: u32,
    page_size: u32,
) -> Result<FriendRequestPageResult, String> {
    FriendRequestService::get()
        .list(page, page_size)
        .map(FriendRequestPageResult::from)
}
