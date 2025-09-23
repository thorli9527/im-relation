use anyhow::Result;
use serde::Serialize;
use sqlx::{MySql, Pool};

/// 群操作日志记录。
#[derive(Debug, Clone)]
pub struct GroupActionLogRow<T>
where
    T: Serialize,
{
    /// 日志 ID（雪花 ID）。
    pub id: i64,
    /// 群 ID。
    pub group_id: i64,
    /// 操作类型（字符串枚举）。
    pub event_type: String,
    /// 操作人 ID。
    pub operator_id: i64,
    /// 受影响的对象 ID（如成员），可能为空。
    pub target_id: Option<i64>,
    /// 操作 payload（JSON 序列化）。
    pub payload: Option<T>,
    /// 创建时间毫秒。
    pub created_at: i64,
}

/// 写入一条群操作日志。
pub async fn insert_group_action_log<T>(
    pool: &Pool<MySql>,
    row: &GroupActionLogRow<T>,
) -> Result<()>
where
    T: Serialize,
{
    // 若 payload 存在，提前序列化为 JSON；否则保持 NULL。
    let payload_json = if let Some(payload) = row.payload.as_ref() {
        Some(serde_json::to_string(payload)?)
    } else {
        None
    };

    sqlx::query(
        r#"
        INSERT INTO group_action_log
            (id, group_id, event_type, operator_id, target_id, payload, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        "#,
    )
    .bind(row.id)
    .bind(row.group_id)
    .bind(&row.event_type)
    .bind(row.operator_id)
    // target_id 存在时写入具体对象 ID，否则写入 0（表字段为 NOT NULL）。
    .bind(row.target_id.unwrap_or_default())
    .bind(payload_json)
    .bind(row.created_at)
    .execute(pool)
    .await?;
    Ok(())
}
