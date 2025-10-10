#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum UserLogType {
    Phone = 1,
    Email = 2,
    QRCode = 3,
    LoginName = 4,
}
impl UserLogType {
    pub fn from_i32(value: i32) -> Option<Self> {
        match value {
            1 => Some(Self::Phone),
            2 => Some(Self::Email),
            3 => Some(Self::QRCode),
            4 => Some(Self::LoginName),
            _ => None,
        }
    }
}
#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum UserAuthOpt {
    Register,
    Login,
    Logout,
    ChangePassword,
    ResetPassword,
}

#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum UserRegType {
    Phone = 1,
    Email = 2,
    LoginName = 3,
    // Nft = 3,
}
impl UserRegType {
    // 将i32转换为UserRegType，若数字不匹配任何变体体则返回None
    pub fn from_i32(value: i32) -> Option<Self> {
        match value {
            1 => Some(Self::Phone),
            2 => Some(Self::Email),
            3 => Some(Self::LoginName),
            _ => None, // 处理未知数值的情况
        }
    }
}

#[derive(Clone, Debug)]
pub struct SessionTokenInfo {
    pub token: String,
    pub expires_at: u64,
}
#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum ResetPasswordType {
    Phone = 1,
    Email = 2,
}

use async_trait::async_trait;
use common::infra::grpc::grpc_user::online_service::{AuthType, DeviceType, UserEntity};
use common::UserId;
use once_cell::sync::OnceCell;
use std::sync::Arc;

#[derive(Clone, Debug)]
pub struct UserService {}
impl UserService {
    /// 构造新的 UserManagerAuth 实例
    ///
    /// # 参数
    /// - `pool`: Redis 连接池
    pub fn new() -> Self {
        let manager = Self {};
        return manager;
    }
    pub fn init() {
        let instance = UserService::new();
        INSTANCE
            .set(Arc::new(instance))
            .expect("INSTANCE already initialized");
    }

    /// 获取全局实例（未初始化会 panic）
    pub fn get() -> Arc<Self> {
        INSTANCE
            .get()
            .expect("UserManager is not initialized")
            .clone()
    }
}

static INSTANCE: OnceCell<Arc<UserService>> = OnceCell::new();

#[async_trait]
pub trait UserServiceAuthOpt: Send + Sync {
    async fn login_by_type(
        &self,
        login_type: &UserLogType,
        target: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(UserEntity, SessionTokenInfo)>;
    /// 登录用户，将用户标记为在线，并进行必要的缓存更新和事件通知
    async fn login(
        &self,
        message_id: &i64,
        auth_type: &AuthType,
        auth_content: &str,
        password: &str,
        device_type: &DeviceType,
        device_id: &str,
    ) -> anyhow::Result<(SessionTokenInfo, UserEntity)>;

    async fn logout(&self, user_id: UserId, device_type: &DeviceType) -> anyhow::Result<()>;
    /// 注册新用户
    async fn build_register_code(
        &self,
        name: &str,
        password: &str,
        reg_type: &UserRegType, // 注册方式
        target: &str,           // 手机号或邮箱
    ) -> anyhow::Result<String>; // 返回注册时返回的uuid

    async fn register_verify_code(&self, uuid: &str, code: &str) -> anyhow::Result<()>;

    async fn register_login_name(&self, name: &str, password: &str) -> anyhow::Result<i64>;

    async fn change_password(
        &self,
        session_token: &str,
        old_password: &str,
        new_password: &str,
    ) -> anyhow::Result<()>;

    async fn change_phone(
        &self,
        session_token: &str,
        old_phone_code: Option<&str>,
        new_phone: &str,
        new_phone_code: &str,
    ) -> anyhow::Result<String>;

    async fn change_email(
        &self,
        session_token: &str,
        old_email_code: Option<&str>,
        new_email: &str,
        new_email_code: &str,
    ) -> anyhow::Result<String>;

    async fn update_profile(
        &self,
        session_token: &str,
        gender: Option<i32>,
        avatar: Option<&str>,
    ) -> anyhow::Result<()>;
}
