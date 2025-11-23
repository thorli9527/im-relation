use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(Debug, Serialize, ToSchema)]
pub struct VerifyRegisterResult {
    pub ok: bool,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct GenerateNicknamePayload {
    /// male / female / any
    pub gender: Option<String>,
    /// 数量，默认 10，最大 100
    pub count: Option<u32>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct GenerateNicknameResult {
    pub names: Vec<String>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct ChangePhoneResult {
    pub ok: bool,
    pub phone: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct ChangeEmailResult {
    pub ok: bool,
    pub email: String,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UpdateNameRequest {
    pub session_token: String,
    pub name: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct UpdateNameResult {
    pub ok: bool,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct FriendListQuery {
    pub session_token: String,
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct FriendListResult {
    pub friends: Vec<FriendSummaryResult>,
    pub page: u32,
    pub page_size: u32,
    pub has_more: bool,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct FriendSummaryResult {
    pub friend_id: i64,
    pub nickname: String,
    pub avatar: String,
    pub remark: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct GroupPath {
    pub group_id: i64,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersQuery {
    pub session_token: String,
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct GroupMembersResult {
    pub members: Vec<GroupMemberResult>,
    pub page: u32,
    pub page_size: u32,
    pub has_more: bool,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct GroupMemberResult {
    pub group_id: i64,
    pub member_id: i64,
    pub nickname: String,
    pub avatar: String,
    pub role: i32,
}

#[derive(Debug, Deserialize)]
pub struct GroupMemberPath {
    pub group_id: i64,
    pub member_id: i64,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct GroupMemberDetailResult {
    pub member: Option<GroupMemberResult>,
    pub is_friend: bool,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SessionQuery {
    pub session_token: String,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SearchUserQuery {
    pub search_type: i32,
    pub query: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct SearchUserResult {
    pub user: Option<UserProfileResult>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct UserProfileResult {
    pub uid: i64,
    pub username: String,
    pub avatar: String,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub signature: Option<String>,
    pub region: Option<String>,
    pub add_friend_policy: i32,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct RecentConversationsQuery {
    pub session_token: String,
    pub limit: Option<u32>,
    pub before_updated_at: Option<i64>,
    pub before_scene: Option<i32>,
    pub before_conversation_id: Option<i64>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct RecentConversationsResult {
    pub conversations: Vec<RecentConversationResult>,
    pub has_more: bool,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct RecentConversationResult {
    pub scene: i32,
    pub conversation_id: i64,
    pub target_id: i64,
    pub last_msg_id: i64,
    pub last_sender_id: i64,
    pub last_timestamp: i64,
    pub unread_count: u32,
    pub updated_at: i64,
}
