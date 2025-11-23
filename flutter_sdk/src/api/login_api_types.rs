#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LoginRequest {
    pub password: String,
    pub target: String,
    pub device_type: i32,
    pub device_id: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LoginResult {
    pub token: String,
    pub expires_at: u64,
    pub socket_addr: String,
    pub avatar: String,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub name: String,
    pub uid: i64,
    pub language: Option<String>,
    pub country: Option<String>,
    pub nickname: Option<String>,
    pub gender: i32,
    pub version: i32,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SessionValidateRequest {
    pub session_token: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SessionValidationResult {
    pub ok: bool,
    pub uid: i64,
    pub expires_at: u64,
    pub token: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LogoutRequest {
    pub session_token: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct LogoutResult {
    pub ok: bool,
    pub revoked_token: Option<String>,
}
