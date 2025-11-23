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

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SearchUserQuery {
    /// 1=uid, 2=username, 3=phone, 4=email
    pub search_type: i32,
    /// 查询内容（用户 id/用户名/手机号/邮箱）
    pub query: String,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct SearchGroupQuery {
    /// 1=group_id, 2=group_name
    pub search_type: i32,
    pub query: String,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct AddFriendRequest {
    pub session_token: String,
    /// 目标用户 id
    pub target_uid: i64,
    /// 附言/备注，可选
    pub reason: Option<String>,
    /// 对方的备注，可选
    pub remark: Option<String>,
}

#[derive(Debug, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct AddFriendResult {
    pub ok: bool,
    /// true 表示提交了申请，false 表示已直接成为好友
    pub applied: bool,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct AddGroupRequest {
    pub session_token: String,
    pub group_id: i64,
    /// 入群申请理由，可选
    pub reason: Option<String>,
}

#[derive(Debug, Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct AddGroupResult {
    pub ok: bool,
    /// true 表示提交了申请，false 表示已直接入群
    pub applied: bool,
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
pub struct SearchUserResult {
    pub user: Option<UserProfileResult>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct GroupInfoResult {
    pub id: i64,
    pub name: String,
    pub avatar: String,
    pub description: String,
    pub notice: String,
    pub join_permission: i32,
    pub owner_id: i64,
    pub member_cnt: u32,
    pub allow_search: bool,
    pub enable: bool,
    pub group_type: i32,
    pub create_time: u64,
    pub update_time: u64,
}

#[derive(Debug, Deserialize, Serialize, ToSchema)]
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
