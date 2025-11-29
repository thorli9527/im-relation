use crate::handler::{
    common_handler, friends_handler, group_handler, login_handler, register_handler, user_handler,
};
use crate::service::auth_models;
use utoipa::OpenApi;

#[derive(OpenApi)]
#[openapi(
    paths(
        register_handler::build_register_code,
        register_handler::verify_register_code,
        login_handler::login,
        login_handler::validate_session,
        login_handler::logout,
        friends_handler::get_friend_list,
        friends_handler::add_friend,
        friends_handler::list_friend_requests,
        friends_handler::decide_friend_request,
        friends_handler::search_user,
        group_handler::get_group_members,
        group_handler::get_group_member_detail,
        group_handler::search_group,
        group_handler::add_group,
        user_handler::change_password,
        user_handler::change_phone,
        user_handler::change_email,
        user_handler::update_profile,
        user_handler::get_recent_conversations,
        user_handler::update_name,
        common_handler::status,
        common_handler::random_nickname
    ),
    components(
        schemas(
            register_handler::BuildRegisterCodePayload,
            register_handler::BuildRegisterCodeResult,
            register_handler::VerifyRegisterPayload,
            register_handler::VerifyRegisterResult,
            login_handler::LoginPayload,
            login_handler::LoginResult,
            login_handler::SessionTokenPayload,
            login_handler::SessionValidationResult,
            user_handler::ChangePhoneResult,
            user_handler::ChangeEmailResult,
            user_handler::FriendListQuery,
            user_handler::FriendListResult,
            user_handler::FriendSummaryResult,
            friends_handler::FriendRequestQuery,
            friends_handler::FriendRequestListResult,
            friends_handler::FriendRequestDecisionDto,
            user_handler::AddFriendRequest,
            user_handler::AddFriendResult,
            user_handler::GroupMembersQuery,
            user_handler::GroupMembersResult,
            user_handler::GroupMemberResult,
            user_handler::GroupMemberDetailResult,
            user_handler::SessionQuery,
            user_handler::SearchUserQuery,
            user_handler::SearchUserResult,
            user_handler::UserProfileResult,
            user_handler::RecentConversationsQuery,
            user_handler::RecentConversationsResult,
            user_handler::RecentConversationResult,
            user_handler::UpdateNameRequest,
            user_handler::UpdateNameResult,
            auth_models::ChangePasswordRequestDto,
            auth_models::ChangePhoneRequestDto,
            auth_models::ChangeEmailRequestDto,
            auth_models::UpdateProfileRequestDto,
            common_handler::RandomNicknameQuery
        )
    ),
    tags(
        (name = "app_api", description = "App HTTP 接口")
    )
)]
pub struct ApiDoc;
