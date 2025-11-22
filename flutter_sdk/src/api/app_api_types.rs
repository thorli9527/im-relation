#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct OperationStatus {
    pub ok: bool,
}


#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdateProfileRequest {
    pub session_token: String,
    pub avatar: Option<String>,
    pub gender: Option<i32>,
    pub country: Option<String>,
    pub language: Option<String>,
    pub alias: Option<String>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct RandomNicknameQuery {
    /// gender 可选：male/female，其他值随机
    pub gender: Option<String>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangePasswordRequest {
    pub session_token: String,
    pub old_password: String,
    pub new_password: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangePhoneRequest {
    pub session_token: String,
    pub new_phone: String,
    pub old_phone_code: Option<String>,
    pub new_phone_code: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangePhoneResult {
    pub ok: bool,
    pub phone: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangeEmailRequest {
    pub session_token: String,
    pub new_email: String,
    pub old_email_code: Option<String>,
    pub new_email_code: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangeEmailResult {
    pub ok: bool,
    pub email: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UserProfile {
    pub uid: i64,
    pub username: String,
    pub avatar: String,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub signature: Option<String>,
    pub region: Option<String>,
    pub add_friend_policy: i32,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct FriendListQuery {
    pub session_token: String,
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct FriendSummary {
    pub friend_id: i64,
    pub nickname: String,
    pub avatar: String,
    pub remark: Option<String>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct FriendListResult {
    pub friends: Vec<FriendSummary>,
    pub page: u32,
    pub page_size: u32,
    pub has_more: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMember {
    pub group_id: i64,
    pub member_id: i64,
    pub nickname: String,
    pub avatar: String,
    pub role: i32,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMemberDetailQuery {
    pub session_token: String,
    pub group_id: i64,
    pub member_id: i64,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMemberDetailResult {
    pub member: Option<GroupMember>,
    pub is_friend: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersQuery {
    pub session_token: String,
    pub group_id: i64,
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersResult {
    pub members: Vec<GroupMember>,
    pub page: u32,
    pub page_size: u32,
    pub has_more: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SearchUserQuery {
    pub search_type: i32,
    pub query: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SearchUserResult {
    pub user: Option<UserProfile>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct RecentConversation {
    pub scene: i32,
    pub conversation_id: i64,
    pub target_id: i64,
    pub last_msg_id: i64,
    pub last_msg_kind: i32,
    pub last_sender_id: i64,
    pub last_timestamp: i64,
    pub unread_count: u32,
    pub updated_at: i64,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct RecentConversationsQuery {
    pub session_token: String,
    pub limit: Option<u32>,
    pub before_updated_at: Option<i64>,
    pub before_scene: Option<i32>,
    pub before_conversation_id: Option<i64>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct RecentConversationsResult {
    pub conversations: Vec<RecentConversation>,
    pub has_more: bool,
}
