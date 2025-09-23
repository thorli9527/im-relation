use anyhow::Result;
use sqlx::{MySql, Pool, Row};

/// 加群申请状态。
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum JoinRequestStatus {
    Pending = 0,
    Approved = 1,
    Rejected = 2,
    Cancelled = 3,
}

impl JoinRequestStatus {
    /// 将数据库中的整型状态转换为枚举。
    pub fn from_i32(v: i32) -> Self {
        match v {
            1 => Self::Approved,
            2 => Self::Rejected,
            3 => Self::Cancelled,
            _ => Self::Pending,
        }
    }
}

/// `group_join_request` 表对应的行结构。
#[derive(Debug, Clone)]
pub struct GroupJoinRequestRow {
    pub id: i64,
    pub group_id: i64,
    pub applicant_id: i64,
    pub extra: Option<String>,
    pub join_source: Option<String>,
    pub inviter_id: Option<i64>,
    pub inviter_extra: Option<String>,
    pub inviter_join_source: Option<String>,
    pub join_time_ms: i64,
    pub status: JoinRequestStatus,
    pub remark: Option<String>,
    pub decided_by: Option<i64>,
    pub decided_at: Option<i64>,
    pub created_at: i64,
    pub updated_at: i64,
}

impl GroupJoinRequestRow {
    /// 从原始 SQL 行构造结构体。
    fn from_row(row: &sqlx::mysql::MySqlRow) -> Self {
        GroupJoinRequestRow {
            id: row.try_get::<i64, _>("id").unwrap_or_default(),
            group_id: row.try_get::<i64, _>("group_id").unwrap_or_default(),
            applicant_id: row.try_get::<i64, _>("applicant_id").unwrap_or_default(),
            extra: row.try_get::<Option<String>, _>("extra").unwrap_or(None),
            join_source: row
                .try_get::<Option<String>, _>("join_source")
                .unwrap_or(None),
            inviter_id: row.try_get::<Option<i64>, _>("inviter_id").unwrap_or(None),
            inviter_extra: row
                .try_get::<Option<String>, _>("inviter_extra")
                .unwrap_or(None),
            inviter_join_source: row
                .try_get::<Option<String>, _>("inviter_join_source")
                .unwrap_or(None),
            join_time_ms: row.try_get::<i64, _>("join_time_ms").unwrap_or_default(),
            status: JoinRequestStatus::from_i32(
                row.try_get::<i32, _>("status").unwrap_or_default(),
            ),
            remark: row.try_get::<Option<String>, _>("remark").unwrap_or(None),
            decided_by: row.try_get::<Option<i64>, _>("decided_by").unwrap_or(None),
            decided_at: row.try_get::<Option<i64>, _>("decided_at").unwrap_or(None),
            created_at: row.try_get::<i64, _>("created_at").unwrap_or_default(),
            updated_at: row.try_get::<i64, _>("updated_at").unwrap_or_default(),
        }
    }
}

/// upsert 一条加群申请记录。
pub async fn upsert_join_request(pool: &Pool<MySql>, row: &GroupJoinRequestRow) -> Result<()> {
    sqlx::query(
        r#"
        INSERT INTO group_join_request
            (id, group_id, applicant_id, extra, join_source, inviter_id, inviter_extra,
             inviter_join_source, join_time_ms, status, remark, decided_by, decided_at,
             created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
             extra = VALUES(extra),
             join_source = VALUES(join_source),
             inviter_id = VALUES(inviter_id),
             inviter_extra = VALUES(inviter_extra),
             inviter_join_source = VALUES(inviter_join_source),
             join_time_ms = VALUES(join_time_ms),
             status = VALUES(status),
             remark = VALUES(remark),
             decided_by = VALUES(decided_by),
             decided_at = VALUES(decided_at),
             updated_at = VALUES(updated_at)
        "#,
    )
    .bind(row.id)
    .bind(row.group_id)
    .bind(row.applicant_id)
    .bind(row.extra.as_ref())
    .bind(row.join_source.as_ref())
    .bind(row.inviter_id)
    .bind(row.inviter_extra.as_ref())
    .bind(row.inviter_join_source.as_ref())
    .bind(row.join_time_ms)
    .bind(row.status as i32)
    .bind(row.remark.as_ref())
    .bind(row.decided_by)
    .bind(row.decided_at)
    .bind(row.created_at)
    .bind(row.updated_at)
    .execute(pool)
    .await?;
    Ok(())
}

/// 查询某用户对指定群的加群申请。
pub async fn get_join_request(
    pool: &Pool<MySql>,
    group_id: i64,
    applicant_id: i64,
) -> Result<Option<GroupJoinRequestRow>> {
    let row = sqlx::query(
        r#"
        SELECT *
          FROM group_join_request
         WHERE group_id = ? AND applicant_id = ?
        "#,
    )
    .bind(group_id)
    .bind(applicant_id)
    .fetch_optional(pool)
    .await?;

    Ok(row.map(|r| GroupJoinRequestRow::from_row(&r)))
}

/// 更新加群申请状态（审批通过/拒绝等）。
pub async fn update_join_request_status(
    pool: &Pool<MySql>,
    group_id: i64,
    applicant_id: i64,
    status: JoinRequestStatus,
    decided_by: i64,
    decided_at: i64,
    remark: Option<String>,
) -> Result<u64> {
    let res = sqlx::query(
        r#"
        UPDATE group_join_request
           SET status = ?,
               decided_by = ?,
               decided_at = ?,
               remark = ?,
               updated_at = ?
         WHERE group_id = ? AND applicant_id = ?
        "#,
    )
    .bind(status as i32)
    .bind(decided_by)
    .bind(decided_at)
    .bind(remark.as_ref())
    .bind(decided_at)
    .bind(group_id)
    .bind(applicant_id)
    .execute(pool)
    .await?;
    Ok(res.rows_affected())
}
