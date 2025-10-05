use anyhow::Result;
use sqlx::{MySql, Pool, QueryBuilder, Row};

/// 群消息持久化记录，对应 `message_info` 表。
#[derive(Debug, Clone)]
pub struct GroupMessageRecord {
    /// 消息唯一 ID（雪花或外部传入）。
    pub msg_id: i64,
    /// 群 ID。
    pub group_id: i64,
    /// 发送者用户 ID。
    pub sender_id: i64,
    /// 消息类型（参照 proto 定义）。
    pub content_type: i32,
    /// 发送时间戳（客户端上报或服务端生成）。
    pub timestamp_ms: i64,
    /// 数据写入时间戳（毫秒）。
    pub created_at_ms: i64,
    /// 消息序号（用于客户端去重）。
    pub msg_no: i64,
    /// 原始 Protobuf 序列化内容。
    pub content: Vec<u8>,
}

/// 将消息记录写入 `message_info` 表。
pub async fn insert_group_message(pool: &Pool<MySql>, record: &GroupMessageRecord) -> Result<()> {
    // 使用预编译 SQL 避免拼装字符串注入风险。
    sqlx::query(
        r#"
        INSERT INTO message_info
            (msg_id, group_id, sender_id, content_type, timestamp_ms, created_at_ms, msg_no, content)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        "#,
    )
    .bind(record.msg_id)
    .bind(record.group_id)
    .bind(record.sender_id)
    .bind(record.content_type)
    .bind(record.timestamp_ms)
    .bind(record.created_at_ms)
    .bind(record.msg_no)
    .bind(&record.content)
    .execute(pool)
    .await?;
    Ok(())
}

/// 分页查询群聊历史消息，按照时间倒序返回。
pub async fn list_group_messages(
    pool: &Pool<MySql>,
    group_id: i64,
    before_msg_id: Option<i64>,
    before_timestamp: Option<i64>,
    limit: usize,
) -> Result<Vec<GroupMessageRecord>> {
    let limit = limit.max(1);

    let mut qb = QueryBuilder::new(
        r#"
        SELECT
            msg_id,
            group_id,
            sender_id,
            content_type,
            timestamp_ms,
            created_at_ms,
            msg_no,
            content
        FROM message_info
        WHERE group_id = 
        "#,
    );

    qb.push_bind(group_id);

    if let Some(ts) = before_timestamp {
        qb.push(" AND timestamp_ms < ");
        qb.push_bind(ts);
    }
    if let Some(msg_id) = before_msg_id {
        qb.push(" AND msg_id < ");
        qb.push_bind(msg_id);
    }

    qb.push(" ORDER BY timestamp_ms DESC, msg_id DESC LIMIT ");
    qb.push_bind(limit as i64);

    let rows = qb.build().fetch_all(pool).await?;

    Ok(rows
        .into_iter()
        .map(|row| GroupMessageRecord {
            msg_id: row.get("msg_id"),
            group_id: row.get("group_id"),
            sender_id: row.get("sender_id"),
            content_type: row.get("content_type"),
            timestamp_ms: row.get("timestamp_ms"),
            created_at_ms: row.get("created_at_ms"),
            msg_no: row.get("msg_no"),
            content: row.get("content"),
        })
        .collect())
}
