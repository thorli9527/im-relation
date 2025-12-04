//! 好友消息持久化操作。

use anyhow::Result;
use serde::{Deserialize, Serialize};
use sqlx::{MySql, Pool, QueryBuilder, Row};

/// 加密消息记录。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncryptedMessageRecord {
    pub msg_id: i64,
    pub sender_id: i64,
    pub receiver_id: i64,
    pub created_at: i64,
    pub scheme: String,
    pub key_id: String,
    pub nonce: Vec<u8>,
    pub msg_no: i64,
    pub aad: Option<Vec<u8>>,
    pub ciphertext: Vec<u8>,
    pub content: Vec<u8>,
}

/// 写入加密消息（message_info 表）。
pub async fn insert_encrypted_message(
    pool: &Pool<MySql>,
    rec: &EncryptedMessageRecord,
) -> Result<()> {
    // 使用单表分区（由数据库层通过分区键进行路由），应用侧始终写入同一逻辑表。
    sqlx::query(
        r#"INSERT INTO message_info
            (msg_id, sender_id, receiver_id, created_at,
             scheme, key_id, nonce, msg_no, aad, ciphertext, content)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"#,
    )
    .bind(rec.msg_id)
    .bind(rec.sender_id)
    .bind(rec.receiver_id)
    .bind(rec.created_at)
    .bind(&rec.scheme)
    .bind(&rec.key_id)
    .bind(&rec.nonce)
    .bind(rec.msg_no)
    .bind(rec.aad.as_deref())
    .bind(&rec.ciphertext)
    .bind(&rec.content)
    .execute(pool)
    .await?;
    Ok(())
}

/// 按好友会话查询历史消息，按照时间倒序返回。
pub async fn list_conversation_messages(
    pool: &Pool<MySql>,
    uid: i64,
    friend_id: i64,
    since_timestamp: Option<i64>,
    before_msg_id: Option<i64>,
    before_timestamp: Option<i64>,
    limit: usize,
) -> Result<Vec<EncryptedMessageRecord>> {
    let limit = limit.max(1);

    let mut qb = QueryBuilder::new(
        r#"
        SELECT
            msg_id,
            sender_id,
            receiver_id,
            created_at,
            scheme,
            key_id,
            nonce,
            msg_no,
            aad,
            ciphertext,
            content
        FROM message_info
        WHERE (
            sender_id = 
        "#,
    );

    qb.push_bind(uid);
    qb.push(" AND receiver_id = ");
    qb.push_bind(friend_id);
    qb.push(") OR (sender_id = ");
    qb.push_bind(friend_id);
    qb.push(" AND receiver_id = ");
    qb.push_bind(uid);
    qb.push(")");

    if let Some(ts) = since_timestamp {
        qb.push(" AND created_at > ");
        qb.push_bind(ts);
    }
    if let Some(ts) = before_timestamp {
        qb.push(" AND created_at < ");
        qb.push_bind(ts);
    }
    if let Some(msg_id) = before_msg_id {
        qb.push(" AND msg_id < ");
        qb.push_bind(msg_id);
    }

    qb.push(" ORDER BY created_at DESC, msg_id DESC LIMIT ");
    qb.push_bind(limit as i64);

    let rows = qb.build().fetch_all(pool).await?;

    Ok(rows
        .into_iter()
        .map(|row| EncryptedMessageRecord {
            msg_id: row.get("msg_id"),
            sender_id: row.get("sender_id"),
            receiver_id: row.get("receiver_id"),
            created_at: row.get("created_at"),
            scheme: row.get("scheme"),
            key_id: row.get("key_id"),
            nonce: row.get("nonce"),
            msg_no: row.get("msg_no"),
            aad: row.get("aad"),
            ciphertext: row.get("ciphertext"),
            content: row.get("content"),
        })
        .collect())
}

/// 根据消息 ID 查询加密消息。
pub async fn get_message_by_id(
    pool: &Pool<MySql>,
    msg_id: i64,
) -> Result<Option<EncryptedMessageRecord>> {
    let row = sqlx::query(
        r#"SELECT msg_id, sender_id, receiver_id, created_at,
                   scheme, key_id, nonce, msg_no, aad, ciphertext, content
            FROM message_info WHERE msg_id = ?"#,
    )
    .bind(msg_id)
    .fetch_optional(pool)
    .await?;
    Ok(row.map(|r| EncryptedMessageRecord {
        msg_id: r.get("msg_id"),
        sender_id: r.get("sender_id"),
        receiver_id: r.get("receiver_id"),
        created_at: r.get("created_at"),
        scheme: r.get("scheme"),
        key_id: r.get("key_id"),
        nonce: r.get("nonce"),
        msg_no: r.get("msg_no"),
        aad: r.get("aad"),
        ciphertext: r.get("ciphertext"),
        content: r.get("content"),
    }))
}

/// 标记消息已送达（占位）。
pub async fn mark_delivered(_pool: &Pool<MySql>, _msg_id: i64, _ts: i64) -> Result<u64> {
    Ok(0)
}

/// 标记消息已读（占位）。
pub async fn mark_read(_pool: &Pool<MySql>, _msg_id: i64, _ts: i64) -> Result<u64> {
    Ok(0)
}

/// 撤回消息（占位）。
pub async fn recall_message(
    _pool: &Pool<MySql>,
    _msg_id: i64,
    _ts: i64,
    _reason: Option<&str>,
) -> Result<u64> {
    Ok(0)
}

/// 将历史消息复制为新消息（用于转发）。
pub async fn copy_message_as_forward(
    pool: &Pool<MySql>,
    src_msg_id: i64,
    new_msg_id: i64,
    from_uid: i64,
    to_uid: i64,
    created_at: i64,
) -> Result<()> {
    if let Some(mut rec) = get_message_by_id(pool, src_msg_id).await? {
        rec.msg_id = new_msg_id;
        rec.sender_id = from_uid;
        rec.receiver_id = to_uid;
        rec.created_at = created_at;
        rec.scheme = rec.scheme.clone();
        rec.key_id = rec.key_id.clone();
        insert_encrypted_message(pool, &rec).await?;
    }
    Ok(())
}
