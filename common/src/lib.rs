
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
#[derive(Clone, Copy, Debug, Serialize, Deserialize)]
#[serde(rename_all = "PascalCase")]
pub enum ApiGroupRole {
    Member,
    Owner,
    Admin,
}

#[derive(Clone, Copy, Debug, Serialize, Deserialize)]
#[repr(i32)]
pub enum GroupRoleType {
    Member = 0,
    Owner  = 1,
    Admin  = 2,
}
impl GroupRoleType {
    pub fn to_api(self) -> ApiGroupRole {
        match self {
            GroupRoleType::Member => ApiGroupRole::Member,
            GroupRoleType::Owner => ApiGroupRole::Owner,
            GroupRoleType::Admin => ApiGroupRole::Admin,
        }
    }
    pub fn from_api(a: ApiGroupRole) -> Self {
        match a {
            ApiGroupRole::Member => GroupRoleType::Member,
            ApiGroupRole::Owner => GroupRoleType::Owner,
            ApiGroupRole::Admin => GroupRoleType::Admin,
        }
    }
    pub fn from_i32(v: i32) -> Self {
        match v {
            1 => GroupRoleType::Owner,
            2 => GroupRoleType::Admin,
            _ => GroupRoleType::Member,
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct MemberRef {
    pub id: UserId,
    /// role as i32 to be compatible with attached code
    pub role: i32,
}


#[derive(Debug)]
pub enum MemberListError {
    /// 底层在操作过程中被升级/降级了，请重试
    Retry,
}
