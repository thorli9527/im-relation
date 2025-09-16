use anyhow::Result;
use serde::{Deserialize, Serialize};
use sqlx::{MySql, Pool, Row};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FriendRequestRow {
    pub id: i64,
    pub from_user_id: i64,
    pub to_user_id: i64,
    pub reason: String,
    pub source: i32,
    pub created_at: i64,
    pub decided_at: Option<i64>,
    pub accepted: Option<bool>,
    pub remark: Option<String>,
}

// 表结构迁移已移动至 migrations/mysql_schema.sql

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

pub async fn get_friend_request_by_id(pool: &Pool<MySql>, req_id: i64) -> Result<Option<FriendRequestRow>> {
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
