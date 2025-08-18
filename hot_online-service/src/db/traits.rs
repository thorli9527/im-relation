use crate::grpc::client_service::ClientEntity;
// hot_online-service/src/member/traits.rs
use anyhow::Result;
use async_trait::async_trait;

/// 只读：从分片主表 `client` 读取用户实体
#[async_trait]
pub trait ClientReadRepo: Clone + Send + Sync + 'static {
    /// 单条读取
    async fn get_by_id(&self, id: i64) -> Result<Option<ClientEntity>>;

    async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<ClientEntity>>;

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