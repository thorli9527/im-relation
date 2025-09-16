
#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(i32)]
pub enum UserLogType {
    Phone = 1,
    Email = 2,
    QRCode=3,
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
    // Nft = 3,
}
impl UserRegType {
    // 将i32转换为UserRegType，若数字不匹配任何变体体则返回None
    pub fn from_i32(value: i32) -> Option<Self> {
        match value {
            1 => Some(Self::Phone),
            2 => Some(Self::Email),
            _ => None, // 处理未知数值的情况
        }
    }
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
use common::UserId;
use once_cell::sync::OnceCell;
use std::sync::Arc;
use crate::grpc_hot_online::auth::{AuthType, DeviceType};
use crate::grpc_hot_online::client_service::ClientEntity;

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
        INSTANCE.set(Arc::new(instance)).expect("INSTANCE already initialized");
    }

    /// 获取全局实例（未初始化会 panic）
    pub fn get() -> Arc<Self> {
        INSTANCE.get().expect("UserManager is not initialized").clone()
    }
}

static INSTANCE: OnceCell<Arc<UserService>> = OnceCell::new();

#[async_trait]
pub trait UserServiceAuthOpt: Send + Sync {
    async fn login_by_type(&self, password: &str, reg_type: &UserRegType, target: &str, device_type: &DeviceType) -> anyhow::Result<String>;
    /// 登录用户，将用户标记为在线，并进行必要的缓存更新和事件通知
    async fn login(
        &self,
        message_id: &i64,
        auth_type: &AuthType,
        auth_content: &str,
        password: &str,
        device_type: &DeviceType,
    ) -> anyhow::Result<(String, ClientEntity)>;

    async fn logout(&self,  user_id: UserId, device_type: &DeviceType) -> anyhow::Result<()>;
    /// 注册新用户
    async fn build_register_code(
        &self,
        name: &str,
        password: &str,
        reg_type: &UserRegType, // 注册方式
        target: &str,           // 手机号或邮箱
    ) -> anyhow::Result<String>; // 返回注册时返回的uuid

    async fn register_verify_code(&self, uuid: &str, code: &str) -> anyhow::Result<()>;

}
