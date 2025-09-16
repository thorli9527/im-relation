use anyhow::Result;
use serde::{Deserialize, Serialize};
use sqlx::{MySql, Pool, Row};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncryptedMessageRecord {
    pub msg_id: i64,
    pub sender_id: i64,
    pub receiver_id: i64,
    pub content_type: i32,
    pub created_at: i64,

    pub scheme: String,
    pub key_id: String,
    pub nonce: Vec<u8>,
    pub msg_no: i64,
    pub aad: Option<Vec<u8>>,
    pub ciphertext: Vec<u8>,
    pub content: Vec<u8>,
}

pub async fn insert_encrypted_message(pool: &Pool<MySql>, rec: &EncryptedMessageRecord) -> Result<()> {
    // 使用单表分区（由数据库层通过分区键进行路由），应用侧始终写入同一逻辑表
    sqlx::query(
        r#"INSERT INTO message_info
            (msg_id, sender_id, receiver_id, content_type, created_at,
             scheme, key_id, nonce, msg_no, aad, ciphertext, content)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"#,
    )
    .bind(rec.msg_id)
    .bind(rec.sender_id)
    .bind(rec.receiver_id)
    .bind(rec.content_type)
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

pub async fn get_message_by_id(pool: &Pool<MySql>, msg_id: i64) -> Result<Option<EncryptedMessageRecord>> {
    let row = sqlx::query(
        r#"SELECT msg_id, sender_id, receiver_id, content_type, created_at,
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
        content_type: r.get("content_type"),
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

pub async fn mark_delivered(_pool: &Pool<MySql>, _msg_id: i64, _ts: i64) -> Result<u64> { Ok(0) }

pub async fn mark_read(_pool: &Pool<MySql>, _msg_id: i64, _ts: i64) -> Result<u64> { Ok(0) }

pub async fn recall_message(_pool: &Pool<MySql>, _msg_id: i64, _ts: i64, _reason: Option<&str>) -> Result<u64> { Ok(0) }

pub async fn copy_message_as_forward(
    pool: &Pool<MySql>,
    src_msg_id: i64,
    new_msg_id: i64,
    from_user_id: i64,
    to_user_id: i64,
    created_at: i64,
) -> Result<()> {
    if let Some(mut rec) = get_message_by_id(pool, src_msg_id).await? {
        rec.msg_id = new_msg_id;
        rec.sender_id = from_user_id;
        rec.receiver_id = to_user_id;
        rec.created_at = created_at;
        rec.scheme = rec.scheme.clone();
        rec.key_id = rec.key_id.clone();
        insert_encrypted_message(pool, &rec).await?;
    }
    Ok(())
}
