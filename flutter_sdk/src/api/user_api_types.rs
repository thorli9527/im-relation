#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct GroupMembersQueryParams {
    pub session_token: String,
    pub page: Option<u32>,
    pub page_size: Option<u32>,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SessionTokenQuery {
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
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct UserInfoResult {
    pub uid: i64,
    pub name: String,
    pub avatar: String,
    pub nickname: Option<String>,
    pub gender: i32,
    pub country: Option<String>,
    pub language: Option<String>,
    pub email: Option<String>,
    pub phone: Option<String>,
}
