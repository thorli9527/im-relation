use flutter_rust_bridge::frb;

use crate::{
    api::GroupRequestPageResult,
    service::group_request_service::GroupRequestService,
};

/// 分页获取加群申请/审批记录。
#[frb]
pub fn get_group_request_page(
    page: u32,
    page_size: u32,
) -> Result<GroupRequestPageResult, String> {
    GroupRequestService::get()
        .list(page, page_size)
        .map(GroupRequestPageResult::from)
}
