use crate::api::app_api_types::*;
use crate::api::user_api_types::{
    AddFriendPayload, GroupMembersQueryParams, SessionTokenQuery, UserInfoResult,
};
use crate::api::utils::post_request;
use crate::service::online_service::OnlineService;
use crate::service::user_service::UserService;
use crate::service::{friend_service::FriendService, group_member_service::GroupMemberService};
use flutter_rust_bridge::frb;

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
    let token = if query.session_token.trim().is_empty() {
        UserService::get()
            .latest_user()?
            .and_then(|u| u.session_token)
            .filter(|t| !t.trim().is_empty())
            .ok_or_else(|| "missing session_token".to_string())?
    } else {
        query.session_token
    };
    let params = FriendListQuery {
        session_token: token,
        page: query.page,
        page_size: query.page_size,
    };
    post_request("/friends", &params)
}

#[frb]
pub fn search_user(query: SearchUserQuery) -> Result<SearchUserResult, String> {
    post_request("/users/search", &query)
}

#[frb]
pub fn add_friend(payload: AddFriendPayload) -> Result<AddFriendResult, String> {
    let user = UserService::get()
        .latest_user()?
        .ok_or_else(|| "no cached user".to_string())?;
    let token = user
        .session_token
        .as_ref()
        .filter(|token| !token.trim().is_empty())
        .ok_or_else(|| "missing session_token".to_string())?;
    let request = AddFriendRequest {
        session_token: token.clone(),
        target_uid: payload.target_uid,
        reason: payload.reason,
        remark: payload.remark,
        nickname: payload.nickname,
    };
    post_request("/friends/add", &request)
}
#[frb]
pub fn get_recent_conversations(
    query: RecentConversationsQuery,
) -> Result<RecentConversationsResult, String> {
    post_request("/conversations/recent", &query)
}
#[frb]
pub fn random_nickname(gender: Option<String>) -> Result<String, String> {
    let query = RandomNicknameQuery { gender };
    post_request("/nickname/random", &query)
}

#[frb]
/// 批量查询在线状态（转发到 app_api -> online_service）。
pub fn check_online_batch(query: CheckOnlineBatchQuery) -> Result<CheckOnlineBatchResult, String> {
    post_request("/online/check-batch", &query)
}

#[frb]
pub fn get_user_info() -> Result<UserInfoResult, String> {
    let user = UserService::get()
        .latest_user()?
        .ok_or_else(|| "no cached user".to_string())?;
    Ok(UserInfoResult {
        uid: user.uid,
        name: user.name,
        avatar: user.avatar,
        nickname: user.nickname,
        gender: user.gender,
        country: user.country,
        language: user.language,
        email: user.email,
        phone: user.phone,
    })
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
    post_request(&path, &params)
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
    post_request(&path, &params)
}

#[frb]
/// 获取本地好友的在线状态（带短期缓存，网络失败返回 stale=true）。
pub fn get_online_friends(force_refresh: bool) -> Result<OnlineStatusSnapshot, String> {
    let user = UserService::get()
        .latest_user()?
        .ok_or_else(|| "no cached user".to_string())?;
    let token = user
        .session_token
        .as_ref()
        .ok_or_else(|| "cached user missing session_token".to_string())?;
    // 若无好友直接返回空列表。
    if FriendService::get().list_ids()?.is_empty() {
        return Ok(OnlineStatusSnapshot {
            items: Vec::new(),
            stale: false,
        });
    }
    OnlineService::get().online_friends(token, force_refresh)
}

#[frb]
/// 刷新并缓存群成员列表；网络失败会回退缓存并标记 stale。
pub fn refresh_group_members(
    query: RefreshGroupMembersQuery,
) -> Result<GroupMembersSnapshot, String> {
    if query.session_token.trim().is_empty() {
        return Err("session_token is required".into());
    }
    if query.group_id <= 0 {
        return Err("group_id must be positive".into());
    }
    let (members, from_cache, stale) = GroupMemberService::get().refresh_group_members(
        &query.session_token,
        query.group_id,
        query.force_refresh,
    )?;
    Ok(GroupMembersSnapshot {
        members,
        from_cache,
        stale,
    })
}

#[frb]
/// 读取已缓存的群成员分页数据。
pub fn get_cached_group_members(
    query: CachedGroupMembersQuery,
) -> Result<GroupMembersResult, String> {
    if query.group_id <= 0 {
        return Err("group_id must be positive".into());
    }
    GroupMemberService::get().list_by_group(query)
}
