use anyhow::Result;
use sqlx::{MySql, Pool};

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
