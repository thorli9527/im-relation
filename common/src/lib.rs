pub mod config;
pub mod errors;
pub mod grpc;
pub mod kafka;
pub mod node_util;
pub mod redis;
pub mod result;
pub mod util;
// note: message.proto moved to service crates
use thiserror::Error;
pub type RedisPool = deadpool_redis::Pool;

pub type UserId = i64;
pub type GroupId = i64;
#[derive(Debug, Error)]
pub enum RelationError {
    #[error("invalid user id")]
    InvalidUserId,
    #[error("retry")]
    Retry,
    #[error("internal: {0}")]
    Internal(&'static str),
}

/// 统一结果别名
pub type MResult<T> = Result<T, MemberListError>;

#[derive(Debug, Error)]
pub enum MemberListError {
    // ===== 参数类 =====
    /// 无效的用户 ID（负数、零等非法值）
    #[error("invalid user id")]
    InvalidUserId,

    /// 无效的群组 ID
    #[error("invalid group id")]
    InvalidGroupId,

    /// 参数不合法（通用）
    #[error("invalid argument: {0}")]
    InvalidArgument(String),

    // ===== 状态类 =====
    /// 指定成员不存在
    #[error("member not found")]
    NotFound,

    /// 群组不存在
    #[error("group not found")]
    GroupNotFound,

    /// 业务前置条件不满足（如不能修改群主角色等）
    #[error("failed precondition: {0}")]
    PreconditionFailed(String),

    /// 权限不足
    #[error("permission denied: {0}")]
    PermissionDenied(String),

    // ===== 冲突类 =====
    /// 成员已存在（重复插入）
    #[error("member already exists")]
    AlreadyExists,

    /// 群成员已达上限
    #[error("too many members in group")]
    TooManyMembers,

    // ===== 系统类 =====
    /// 数据库错误
    #[error("database error: {0}")]
    DatabaseError(String),

    /// 序列化 / 反序列化错误
    #[error("serialization error: {0}")]
    SerializationError(String),

    /// 内部错误（不对外细化原因）
    #[error("internal error: {0}")]
    Internal(String),

    /// 其它未分类错误
    #[error("internal error: {0}")]
    Other(String),
}

impl MemberListError {
    #[inline]
    pub fn db<E: std::fmt::Display>(e: E) -> Self {
        MemberListError::DatabaseError(e.to_string())
    }
    #[inline]
    pub fn ser<E: std::fmt::Display>(e: E) -> Self {
        MemberListError::SerializationError(e.to_string())
    }
    #[inline]
    pub fn internal<E: std::fmt::Display>(e: E) -> Self {
        MemberListError::Internal(e.to_string())
    }
}

// ---- 常见错误类型到 MemberListError 的转换 ----

impl From<sqlx::Error> for MemberListError {
    fn from(e: sqlx::Error) -> Self {
        MemberListError::DatabaseError(e.to_string())
    }
}

impl From<serde_json::Error> for MemberListError {
    fn from(e: serde_json::Error) -> Self {
        MemberListError::SerializationError(e.to_string())
    }
}

impl From<anyhow::Error> for MemberListError {
    fn from(e: anyhow::Error) -> Self {
        MemberListError::Other(e.to_string())
    }
}

// ---- gRPC 映射（tonic::Status）便捷转换 ----

impl From<MemberListError> for tonic::Status {
    fn from(err: MemberListError) -> Self {
        use MemberListError::*;
        match err {
            InvalidUserId | InvalidGroupId | InvalidArgument(_) => {
                tonic::Status::invalid_argument(err.to_string())
            }
            NotFound | GroupNotFound => tonic::Status::not_found(err.to_string()),
            PreconditionFailed(_) => tonic::Status::failed_precondition(err.to_string()),
            PermissionDenied(_) => tonic::Status::permission_denied(err.to_string()),
            AlreadyExists => tonic::Status::already_exists(err.to_string()),
            TooManyMembers => tonic::Status::resource_exhausted(err.to_string()),
            DatabaseError(_) | SerializationError(_) | Internal(_) | Other(_) => {
                tonic::Status::internal(err.to_string())
            }
        }
    }
}
