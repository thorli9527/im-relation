/// 通用操作结果。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct OperationStatus {
    /// 是否成功
    pub ok: bool,
}

/// 发起添加好友的请求。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct AddFriendRequest {
    /// 会话 token
    pub session_token: String,
    /// 目标用户 id
    pub target_uid: i64,
    /// 附言/备注，可选
    pub reason: Option<String>,
    /// 对方的备注，可选
    pub remark: Option<String>,
    /// 我方期望的好友昵称（可选）
    pub nickname: Option<String>,
    /// 好友来源（参考 FriendRequestSource 枚举），必传
    pub source: i32,
}

/// 添加好友的结果。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct AddFriendResult {
    /// 是否成功
    pub ok: bool,
    /// true 表示提交了申请，false 表示已直接成为好友
    pub applied: bool,
}

/// 受理好友请求的入参。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct FriendRequestDecisionRequest {
    /// 会话 token
    pub session_token: String,
    /// 申请 ID
    pub request_id: u64,
    /// 申请人 UID
    pub from_uid: i64,
    /// 是否接受
    pub accepted: bool,
    /// 备注（审批人填写）
    pub remark: Option<String>,
    /// 审批人希望展示给申请人的昵称
    pub nickname: Option<String>,
}

/// 更新个人资料请求。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UpdateProfileRequest {
    /// 会话 token
    pub session_token: String,
    /// 头像 URL
    pub avatar: Option<String>,
    /// 性别枚举值
    pub gender: Option<i32>,
    /// 国家/地区
    pub country: Option<String>,
    /// 语言
    pub language: Option<String>,
    /// 昵称
    pub nickname: Option<String>,
}

/// 随机昵称查询参数。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct RandomNicknameQuery {
    /// gender 可选：male/female，其他值随机
    pub gender: Option<String>,
}

/// 修改密码请求。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangePasswordRequest {
    /// 会话 token
    pub session_token: String,
    /// 旧密码
    pub old_password: String,
    /// 新密码
    pub new_password: String,
}

/// 修改手机号请求。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangePhoneRequest {
    /// 会话 token
    pub session_token: String,
    /// 新手机号
    pub new_phone: String,
    /// 旧手机号验证码
    pub old_phone_code: Option<String>,
    /// 新手机号验证码
    pub new_phone_code: String,
}

/// 修改手机号结果。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangePhoneResult {
    /// 是否成功
    pub ok: bool,
    /// 修改后的手机号
    pub phone: String,
}

/// 修改邮箱请求。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangeEmailRequest {
    /// 会话 token
    pub session_token: String,
    /// 新邮箱
    pub new_email: String,
    /// 旧邮箱验证码
    pub old_email_code: Option<String>,
    /// 新邮箱验证码
    pub new_email_code: String,
}

/// 修改邮箱结果。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ChangeEmailResult {
    /// 是否成功
    pub ok: bool,
    /// 修改后的邮箱
    pub email: String,
}

/// 用户资料视图。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UserProfile {
    /// UID
    pub uid: i64,
    /// 登录用户名
    pub username: String,
    /// 头像 URL
    pub avatar: String,
    /// 邮箱
    pub email: Option<String>,
    /// 手机
    pub phone: Option<String>,
    /// 昵称
    pub nickname: String,
    /// 个性签名
    pub signature: Option<String>,
    /// 地区
    pub region: Option<String>,
    /// 加好友策略枚举值
    pub add_friend_policy: i32,
}

/// 查询好友列表参数。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct FriendListQuery {
    /// 会话 token
    pub session_token: String,
    /// 页码
    pub page: Option<u32>,
    /// 每页大小
    pub page_size: Option<u32>,
}

/// 好友列表中的概要信息。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct FriendSummary {
    /// 好友 UID
    pub friend_id: i64,
    /// 昵称
    pub nickname: String,
    /// 头像 URL
    pub avatar: String,
    /// 备注
    pub remark: Option<String>,
}

/// 好友列表返回。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct FriendListResult {
    /// 好友列表
    pub friends: Vec<FriendSummary>,
    /// 页码
    pub page: u32,
    /// 每页大小
    pub page_size: u32,
    /// 是否有更多
    pub has_more: bool,
}

/// 群成员概要信息。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMember {
    /// 群 ID
    pub group_id: i64,
    /// 成员 UID
    pub member_id: i64,
    /// 昵称
    pub nickname: String,
    /// 头像
    pub avatar: String,
    /// 角色枚举值
    pub role: i32,
}

/// 查询群成员详情参数。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMemberDetailQuery {
    /// 会话 token
    pub session_token: String,
    /// 群 ID
    pub group_id: i64,
    /// 成员 UID
    pub member_id: i64,
}

/// 群成员详情结果。
#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMemberDetailResult {
    /// 成员信息（可能为空）
    pub member: Option<GroupMember>,
    /// 是否是我的好友
    pub is_friend: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersQuery {
    /// 会话 token
    pub session_token: String,
    /// 群 ID
    pub group_id: i64,
    /// 页码
    pub page: Option<u32>,
    /// 每页大小
    pub page_size: Option<u32>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct CachedGroupMembersQuery {
    /// 群 ID
    pub group_id: i64,
    /// 页码
    pub page: Option<u32>,
    /// 每页大小
    pub page_size: Option<u32>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersResult {
    /// 成员列表
    pub members: Vec<GroupMember>,
    /// 页码
    pub page: u32,
    /// 每页大小
    pub page_size: u32,
    /// 是否有更多
    pub has_more: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct RefreshGroupMembersQuery {
    /// 会话 token
    pub session_token: String,
    /// 群 ID
    pub group_id: i64,
    /// 是否强制刷新
    pub force_refresh: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersSnapshot {
    /// 成员快照
    pub members: Vec<GroupMember>,
    /// 是否直接使用了本地缓存
    pub from_cache: bool,
    /// 如果网络失败并回退缓存，则为 true
    pub stale: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct OnlineStatusEntry {
    /// 用户 UID
    pub uid: i64,
    /// 是否在线
    pub online: bool,
    /// 拉取时间（毫秒）
    pub fetched_at: i64,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct OnlineStatusSnapshot {
    /// 在线状态列表
    pub items: Vec<OnlineStatusEntry>,
    /// 是否可能存在过期（例如网络失败回退）
    pub stale: bool,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct CheckOnlineBatchQuery {
    /// 会话 token
    pub session_token: String,
    /// 待检查的 UID 列表
    pub uids: Vec<i64>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct CheckOnlineBatchResult {
    /// 在线状态结果
    pub items: Vec<OnlineStatusEntry>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SearchUserQuery {
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
