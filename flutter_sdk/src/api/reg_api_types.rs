use serde::Serialize;

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct BuildRegisterCodeRequest {
    /// 注册密码
    pub password: String,
    /// 目标（邮箱/手机号）
    pub target: String,
    /// 可选语言
    pub language: Option<String>,
    /// 可选国家
    pub country: Option<String>,
    /// 可选性别
    pub gender: Option<i32>,
    /// 可选昵称
    pub nickname: Option<String>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VerifyRegisterCodeRequest {
    /// 注册 ID（生成注册码时返回）
    pub reg_id: String,
    /// 验证码
    pub code: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct BuildRegisterCodeResponse {
    /// 注册 ID
    pub reg_id: String,
    /// 用户 UID
    pub uid: i64,
}
