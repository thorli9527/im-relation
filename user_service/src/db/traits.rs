use common::infra::grpc::grpc_user::online_service::{DeviceType, UserEntity};
// user_service/src/member/traits.rs
use anyhow::Result;
use async_trait::async_trait;
use time::OffsetDateTime;

/// 只读：从分片主表 `client` 读取用户实体
#[async_trait]
pub trait ClientReadRepo: Clone + Send + Sync + 'static {
    /// 单条读取
    async fn get_by_id(&self, id: i64) -> Result<Option<UserEntity>>;

    async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<UserEntity>>;

    /// 存在性检查（等值点查）
    async fn exists(&self, id: i64) -> Result<bool>;

    /// 读取版本号（用于乐观锁；无则 None）
    async fn get_version(&self, id: i64) -> Result<Option<i32>>;
}
/// 目录只读接口：按规范化键（email/phone/name）定位唯一的 client.id
///
/// 约定：
/// - email_norm: lower + IDNA → ASCII 字节；
/// - phone_norm: E.164 → ASCII 字节；
/// - name_norm: 统一规范化后的用户名（如 lower + NFKC）。
#[async_trait]
pub trait DirectoryReadRepo: Clone + Send + Sync + 'static {
    /// 仅返回 ACTIVE（state=1）的绑定；未命中返回 None
    async fn get_id_by_email(&self, email_norm: &[u8]) -> Result<Option<i64>>;

    /// 仅返回 ACTIVE（state=1）的绑定；未命中返回 None
    async fn get_id_by_phone(&self, phone_norm: &[u8]) -> Result<Option<i64>>;

    /// 用户名目录（通常不含 state 列），未命中返回 None
    async fn get_id_by_name(&self, username_norm: &str) -> Result<Option<i64>>;
}

#[derive(Clone, Debug)]
pub struct SessionTokenUpsert {
    pub user_id: i64,
    pub device_type: DeviceType,
    pub device_id: String,
    pub login_ip: Option<Vec<u8>>,
    pub user_agent: Option<String>,
}

#[derive(Clone, Debug)]
pub struct SessionTokenRecord {
    pub user_id: i64,
    pub device_type: DeviceType,
    pub device_id: String,
    pub session_token: String,
    pub status: i32,
    pub expires_at: OffsetDateTime,
    pub last_seen_at: OffsetDateTime,
}

#[derive(Clone, Debug)]
pub struct SessionTokenUpsertResult {
    pub session_token: String,
    pub expires_at: OffsetDateTime,
    pub previous_token: Option<String>,
}

#[async_trait]
pub trait SessionTokenRepo: Clone + Send + Sync + 'static {
    async fn upsert_session_token(
        &self,
        payload: SessionTokenUpsert,
    ) -> Result<SessionTokenUpsertResult>;

    async fn validate_session_token(&self, token: &str) -> Result<Option<SessionTokenRecord>>;

    async fn revoke_session_token_by_token(&self, token: &str) -> Result<Option<String>>;

    async fn revoke_session_token_by_device(
        &self,
        user_id: i64,
        device_type: DeviceType,
        device_id: &str,
    ) -> Result<Option<String>>;

    async fn touch_tokens(&self, tokens: &[String]) -> Result<u64>;
}
