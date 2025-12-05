#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersQueryParams {
    /// 会话 token
    pub session_token: String,
    /// 页码
    pub page: Option<u32>,
    /// 每页大小
    pub page_size: Option<u32>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SessionTokenQuery {
    /// 会话 token
    pub session_token: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct AddFriendPayload {
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

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UserInfoResult {
    /// UID
    pub uid: i64,
    /// 用户名
    pub name: String,
    /// 头像
    pub avatar: String,
    /// 昵称
    pub nickname: Option<String>,
    /// 性别枚举
    pub gender: i32,
    /// 国家/地区
    pub country: Option<String>,
    /// 语言
    pub language: Option<String>,
    /// 邮箱
    pub email: Option<String>,
    /// 手机
    pub phone: Option<String>,
}
