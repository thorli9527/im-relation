//! 好友申请相关的数据访问函数。

use anyhow::Result;
use serde::{Deserialize, Serialize};
use sqlx::{MySql, Pool, Row};

/// 好友申请记录结构。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FriendRequestRow {
    /// 申请 ID（雪花或外部生成）。
    pub id: i64,
    /// 发起申请的用户。
    pub from_user_id: i64,
    /// 接收申请的用户。
    pub to_user_id: i64,
    /// 申请理由。
    pub reason: String,
    /// 来源枚举（例如扫码、手机号等）。
    pub source: i32,
    /// 创建时间戳（毫秒）。
    pub created_at: i64,
    /// 审批时间（毫秒）。
    pub decided_at: Option<i64>,
    /// 审批结果。
    pub accepted: Option<bool>,
    /// 申请备注（可能由申请人填写）。
    pub remark: Option<String>,
}

// 表结构迁移已移动至 migrations/mysql_schema.sql。

/// 插入或更新好友申请记录。
pub async fn upsert_friend_request(pool: &Pool<MySql>, row: &FriendRequestRow) -> Result<u64> {
    let r = sqlx::query(
        r#"REPLACE INTO friend_requests
        (id, from_user_id, to_user_id, reason, source, created_at, decided_at, accepted, remark)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"#,
    )
    .bind(row.id)
    .bind(row.from_user_id)
    .bind(row.to_user_id)
    .bind(&row.reason)
    .bind(row.source)
    .bind(row.created_at)
    .bind(row.decided_at)
    .bind(row.accepted)
    .bind(&row.remark)
    .execute(pool)
    .await?;
    Ok(r.rows_affected())
}

/// 根据申请 ID 查询记录。
pub async fn get_friend_request_by_id(
    pool: &Pool<MySql>,
    req_id: i64,
) -> Result<Option<FriendRequestRow>> {
    let row = sqlx::query(
        r#"SELECT id, from_user_id, to_user_id, reason, source, created_at, decided_at, accepted, remark
            FROM friend_requests WHERE id = ?"#,
    )
    .bind(req_id)
    .fetch_optional(pool)
    .await?;
    Ok(row.map(|r| FriendRequestRow {
        id: r.get("id"),
        from_user_id: r.get("from_user_id"),
        to_user_id: r.get("to_user_id"),
        reason: r.get("reason"),
        source: r.get("source"),
        created_at: r.get("created_at"),
        decided_at: r.get("decided_at"),
        accepted: r.get("accepted"),
        remark: r.get("remark"),
    }))
}

/// 记录审批结果（接受/拒绝）。
pub async fn mark_friend_request_decision(
    pool: &Pool<MySql>,
    req_id: i64,
    decided_at: i64,
    accepted: bool,
    remark: Option<String>,
) -> Result<u64> {
    let r = sqlx::query(
        r#"UPDATE friend_requests SET decided_at = ?, accepted = ?, remark = ? WHERE id = ?"#,
    )
    .bind(decided_at)
    .bind(accepted)
    .bind(remark)
    .bind(req_id)
    .execute(pool)
    .await?;
    Ok(r.rows_affected())
}
