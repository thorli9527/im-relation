use serde::Serialize;

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct BuildRegisterCodeRequest {
    pub password: String,
    pub target: String,
    /// 可选语言
    pub language: Option<String>,
    /// 可选国家
    pub country: Option<String>,
    /// 可选性别
    pub gender: Option<i32>,
    /// 可选别名
    pub alias: Option<String>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VerifyRegisterCodeRequest {
    pub reg_id: String,
    pub code: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct BuildRegisterCodeResponse {
    pub reg_id: String,
    pub uid: i64,
}
