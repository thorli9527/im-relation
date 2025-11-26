use anyhow::Result;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

use common::config::MySqlPool;

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct SystemMessageRecord {
    pub msg_id: i64,
    pub sender_id: i64,
    pub receiver_id: i64,
    pub created_at: i64,
    pub content: Vec<u8>,
}

pub async fn insert_system_message(
    pool: &MySqlPool,
    sender_id: i64,
    receiver_id: i64,
    msg_id: i64,
    created_at: i64,
    content: Vec<u8>,
) -> Result<()> {
    sqlx::query(
        "INSERT INTO system_messages (msg_id, sender_id, receiver_id, created_at, content)
         VALUES (?, ?, ?, ?, ?)",
    )
    .bind(msg_id)
    .bind(sender_id)
    .bind(receiver_id)
    .bind(created_at)
    .bind(content)
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn list_system_messages(
    pool: &MySqlPool,
    uid: i64,
    before_message_id: Option<i64>,
    before_timestamp: Option<i64>,
    limit: usize,
) -> Result<Vec<SystemMessageRecord>> {
    let mut query = String::from(
        "SELECT msg_id, sender_id, receiver_id, created_at, content
         FROM system_messages WHERE receiver_id = ?",
    );
    if before_message_id.is_some() {
        query.push_str(" AND msg_id < ?");
    }
    if before_timestamp.is_some() {
        query.push_str(" AND created_at < ?");
    }
    query.push_str(" ORDER BY msg_id DESC LIMIT ?");

    let mut q = sqlx::query_as::<_, SystemMessageRecord>(&query).bind(uid);
    if let Some(mid) = before_message_id {
        q = q.bind(mid);
    }
    if let Some(ts) = before_timestamp {
        q = q.bind(ts);
    }
    q = q.bind(limit as i64);

    let rows = q.fetch_all(pool).await?;
    Ok(rows)
}
