#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LoginRequest {
    /// 登录密码
    pub password: String,
    /// 目标（邮箱/手机号/用户名）
    pub target: String,
    /// 设备类型枚举值
    pub device_type: i32,
    /// 设备唯一 ID
    pub device_id: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LoginResult {
    /// 会话 token
    pub token: String,
    /// token 过期时间（秒）
    pub expires_at: u64,
    /// socket 服务地址
    pub socket_addr: String,
    /// 头像 URL
    pub avatar: String,
    /// 邮箱
    pub email: Option<String>,
    /// 手机号
    pub phone: Option<String>,
    /// 用户名
    pub name: String,
    /// UID
    pub uid: i64,
    /// 语言
    pub language: Option<String>,
    /// 国家/地区
    pub country: Option<String>,
    /// 昵称
    pub nickname: Option<String>,
    /// 性别枚举
    pub gender: i32,
    /// 资料版本
    pub version: i32,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SessionValidateRequest {
    /// 会话 token
    pub session_token: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SessionValidationResult {
    /// 是否有效
    pub ok: bool,
    /// UID
    pub uid: i64,
    /// 过期时间（秒）
    pub expires_at: u64,
    /// token（可能与入参一致）
    pub token: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LogoutRequest {
    /// 会话 token
    pub session_token: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LogoutResult {
    /// 是否成功
    pub ok: bool,
    /// 被吊销的 token
    pub revoked_token: Option<String>,
}
