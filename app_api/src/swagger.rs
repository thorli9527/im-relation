use crate::handler::{common_handler, login_handler, register_handler, user_handler};
use crate::service::auth_models;
use utoipa::OpenApi;

#[derive(OpenApi)]
#[openapi(
    paths(
        register_handler::build_register_code,
        register_handler::verify_register_code,
        login_handler::login,
        login_handler::validate_session,
        user_handler::change_password,
        user_handler::change_phone,
        user_handler::change_email,
        user_handler::update_profile,
        user_handler::get_friend_list,
        user_handler::get_group_members,
        user_handler::get_group_member_detail,
        user_handler::search_user,
        user_handler::get_recent_conversations,
        user_handler::update_name,
        common_handler::status
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
            auth_models::UpdateProfileRequestDto
        )
    ),
    tags(
        (name = "app_api", description = "App HTTP 接口")
    )
)]
pub struct ApiDoc;
