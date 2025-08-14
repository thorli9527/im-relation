pub mod config;
mod errors;

use serde::{Serialize, Deserialize};

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



#[derive(Debug)]
pub enum MemberListError {
    /// 底层在操作过程中被升级/降级了，请重试
    Retry,
}
