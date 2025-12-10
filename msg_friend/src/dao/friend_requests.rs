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
    pub from_uid: i64,
    /// 接收申请的用户。
    pub to_uid: i64,
    /// 申请理由。
    pub from_reason: String,
    /// 来源枚举（例如扫码、手机号等）。
    pub source: i32,
    /// 申请人填写的备注（非空字符串，默认空）。
    pub from_remark: String,
    /// 申请人展示给对方的昵称（非空字符串，默认空）。
    pub from_nickname: String,
    /// 审批方填写的备注（非空字符串，默认空）。
    pub to_remark: String,
    /// 审批方展示给申请人的昵称（非空字符串，默认空）。
    pub to_nickname: String,
    /// 创建时间戳（毫秒）。
    pub created_at: i64,
    /// 审批时间（毫秒）。
    pub decided_at: Option<i64>,
    /// 审批结果。
    pub accepted: Option<bool>,
    /// 最近一次系统通知时间（毫秒）。
    pub notified_at: i64,
    /// 系统通知重试次数。
    pub notify_retry: i32,
}

// 表结构迁移已移动至 migrations/mysql_schema.sql。

/// 插入或更新好友申请记录。
pub async fn upsert_friend_request(pool: &Pool<MySql>, row: &FriendRequestRow) -> Result<u64> {
    let r = sqlx::query(
        r#"REPLACE INTO friend_requests
        (id, from_uid, to_uid, from_reason, source, from_remark, from_nickname, to_remark, to_nickname, created_at, decided_at, accepted, notified_at, notify_retry)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"#,
    )
    .bind(row.id)
    .bind(row.from_uid)
    .bind(row.to_uid)
    .bind(&row.from_reason)
    .bind(row.source)
    .bind(&row.from_remark)
    .bind(&row.from_nickname)
    .bind(&row.to_remark)
    .bind(&row.to_nickname)
    .bind(row.created_at)
    .bind(row.decided_at)
    .bind(row.accepted)
    .bind(row.notified_at)
    .bind(row.notify_retry)
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
        r#"SELECT id, from_uid, to_uid, from_reason, source, from_remark, from_nickname, to_remark, to_nickname, created_at, decided_at, accepted, notified_at, notify_retry
           FROM friend_requests WHERE id = ?"#,
    )
    .bind(req_id)
    .fetch_optional(pool)
    .await?;
    Ok(row.map(|r| FriendRequestRow {
        id: r.get("id"),
        from_uid: r.get("from_uid"),
        to_uid: r.get("to_uid"),
        from_reason: r.get("from_reason"),
        source: r.get("source"),
        from_remark: r.get("from_remark"),
        from_nickname: r.get("from_nickname"),
        to_remark: r.get("to_remark"),
        to_nickname: r.get("to_nickname"),
        created_at: r.get("created_at"),
        decided_at: r.get("decided_at"),
        accepted: r.get("accepted"),
        notified_at: r.get("notified_at"),
        notify_retry: r.get("notify_retry"),
    }))
}

/// 记录审批结果（接受/拒绝）。
pub async fn mark_friend_request_decision(
    pool: &Pool<MySql>,
    req_id: i64,
    decided_at: i64,
    accepted: bool,
    from_remark: String,
    to_remark: String,
    to_nickname: String,
) -> Result<u64> {
    let r = sqlx::query(
        r#"UPDATE friend_requests SET decided_at = ?, accepted = ?, to_remark = ?, to_nickname = ?, from_remark = ? WHERE id = ?"#,
    )
    .bind(decided_at)
    .bind(accepted)
    .bind(to_remark)
    .bind(to_nickname)
    .bind(from_remark)
    .bind(req_id)
    .execute(pool)
    .await?;
    Ok(r.rows_affected())
}

/// 标记系统通知成功，重置重试次数。
pub async fn mark_friend_request_notified(
    pool: &Pool<MySql>,
    req_id: i64,
    notified_at: i64,
) -> Result<u64> {
    let r =
        sqlx::query(r#"UPDATE friend_requests SET notified_at = ?, notify_retry = 0 WHERE id = ?"#)
            .bind(notified_at)
            .bind(req_id)
            .execute(pool)
            .await?;
    Ok(r.rows_affected())
}

/// 系统通知失败时记录重试次数。
pub async fn increment_friend_request_notify_retry(pool: &Pool<MySql>, req_id: i64) -> Result<u64> {
    let r =
        sqlx::query(r#"UPDATE friend_requests SET notify_retry = notify_retry + 1 WHERE id = ?"#)
            .bind(req_id)
            .execute(pool)
            .await?;
    Ok(r.rows_affected())
}

/// 获取需要重试系统通知的好友业务记录。
pub async fn list_friend_requests_pending_notify(
    pool: &Pool<MySql>,
    max_retry: i32,
    limit: u32,
) -> Result<Vec<FriendRequestRow>> {
    let rows = sqlx::query(
        r#"SELECT id,
                  from_uid,
                  to_uid,
                  from_reason,
                  source,
                  from_remark,
                  from_nickname,
                  to_remark,
                  to_nickname,
                  created_at,
                  decided_at,
                  accepted,
                  notified_at,
                  notify_retry
           FROM friend_requests
           WHERE notify_retry < ?
             AND notified_at = 0
           ORDER BY notify_retry ASC, created_at ASC
           LIMIT ?"#,
    )
    .bind(max_retry)
    .bind(limit as i64)
    .fetch_all(pool)
    .await?;

    Ok(rows
        .into_iter()
        .map(|r| FriendRequestRow {
            id: r.get("id"),
            from_uid: r.get("from_uid"),
            to_uid: r.get("to_uid"),
            from_reason: r.get("from_reason"),
            source: r.get("source"),
            from_remark: r.get("from_remark"),
            from_nickname: r.get("from_nickname"),
            to_remark: r.get("to_remark"),
            to_nickname: r.get("to_nickname"),
            created_at: r.get("created_at"),
            decided_at: r.get("decided_at"),
            accepted: r.get("accepted"),
            notified_at: r.get("notified_at"),
            notify_retry: r.get("notify_retry"),
        })
        .collect())
}
