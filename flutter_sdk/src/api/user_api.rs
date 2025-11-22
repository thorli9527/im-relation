use flutter_rust_bridge::frb;
use crate::api::app_api_types::*;
use crate::api::utils::{get_request, post_request};
use crate::api::user_api_types::{GroupMembersQueryParams, SessionTokenQuery};

// 用户资料与列表相关接口，保留在 user_api。
#[frb]
pub fn change_password(payload: ChangePasswordRequest) -> Result<OperationStatus, String> {
    post_request("/password/change", &payload)
}
#[frb]
pub fn change_phone(payload: ChangePhoneRequest) -> Result<ChangePhoneResult, String> {
    post_request("/phone/change", &payload)
}
#[frb]
pub fn change_email(payload: ChangeEmailRequest) -> Result<ChangeEmailResult, String> {
    post_request("/email/change", &payload)
}
pub fn update_profile(payload: UpdateProfileRequest) -> Result<OperationStatus, String> {
    post_request("/profile/update", &payload)
}
#[frb]
pub fn get_friend_list(query: FriendListQuery) -> Result<FriendListResult, String> {
    get_request("/friends", &query)
}

#[frb]
pub fn search_user(query: SearchUserQuery) -> Result<SearchUserResult, String> {
    get_request("/users/search", &query)
}
#[frb]
pub fn get_recent_conversations(
    query: RecentConversationsQuery,
) -> Result<RecentConversationsResult, String> {
    get_request("/conversations/recent", &query)
}
#[frb]
pub fn random_nickname(gender: Option<String>) -> Result<String, String> {
    let query = RandomNicknameQuery { gender };
    get_request("/nickname/random", &query)
}

#[frb]
/// 分页拉取群成员列表。
pub fn get_group_members(query: GroupMembersQuery) -> Result<GroupMembersResult, String> {
    let path = format!("/groups/{}/members", query.group_id);
    let params = GroupMembersQueryParams {
        session_token: query.session_token,
        page: query.page,
        page_size: query.page_size,
    };
    get_request(&path, &params)
}

#[frb]
/// 获取群成员详情并判断是否为好友关系。
pub fn get_group_member_detail(
    query: GroupMemberDetailQuery,
) -> Result<GroupMemberDetailResult, String> {
    let path = format!("/groups/{}/members/{}", query.group_id, query.member_id);
    let params = SessionTokenQuery {
        session_token: query.session_token,
    };
    get_request(&path, &params)
}
