pub mod config;
mod errors;
pub mod util;

use serde::{ Deserialize};

pub type UserId = i64;
pub type GroupId = i64;
#[derive(thiserror::Error, Debug)]
pub enum RelationError {
    #[error("invalid user id")]
    InvalidUserId,
    #[error("retry")]
    Retry,
    #[error("internal: {0}")]
    Internal(&'static str),
}



use thiserror::Error;

/// 群成员管理相关错误
#[derive(Debug, Error)]
pub enum MemberListError {
    // ===== 参数类 =====

    /// 无效的用户 ID（负数、零等非法值）
    #[error("invalid user id")]
    InvalidUserId,

    /// 无效的群组 ID
    #[error("invalid group id")]
    InvalidGroupId,

    /// 参数不合法（通用版，附带原因）
    #[error("invalid argument: {0}")]
    InvalidArgument(String),

    // ===== 状态类 =====

    /// 指定成员不存在
    #[error("member not found")]
    NotFound,

    /// 群组不存在
    #[error("group not found")]
    GroupNotFound,

    /// 不满足业务前置条件（如不能修改群主角色、越权等）
    #[error("precondition failed: {0}")]
    PreconditionFailed(String),

    /// 操作不被允许（权限不足）
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

    /// 其它未分类错误
    #[error("internal error: {0}")]
    Other(String),
}
