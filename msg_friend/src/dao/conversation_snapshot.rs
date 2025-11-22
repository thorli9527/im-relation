use anyhow::Result;
use sqlx::{MySql, Pool, QueryBuilder, Row};

/// 好友会话快照记录。
#[derive(Debug, Clone)]
#[allow(dead_code)]
pub struct FriendConversationSnapshot {
    pub owner_id: i64,
    pub peer_id: i64,
    pub conversation_id: i64,
    pub last_msg_id: i64,
    pub last_sender_id: i64,
    pub last_receiver_id: i64,
    pub last_timestamp: i64,
    pub unread_count: i32,
    pub created_at: i64,
    pub updated_at: i64,
}

/// 新增或更新好友会话快照。
pub async fn upsert_friend_conversation_snapshot(
    pool: &Pool<MySql>,
    snapshot: &FriendConversationSnapshot,
) -> Result<()> {
    sqlx::query(
        r#"
        INSERT INTO conversation_snapshot
            (owner_id, peer_id, conversation_id, last_msg_id,
             last_sender_id, last_receiver_id, last_timestamp, unread_count,
             created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            peer_id = VALUES(peer_id),
            last_msg_id = VALUES(last_msg_id),
            last_sender_id = VALUES(last_sender_id),
            last_receiver_id = VALUES(last_receiver_id),
            last_timestamp = VALUES(last_timestamp),
            unread_count = VALUES(unread_count),
            updated_at = VALUES(updated_at)
        "#,
    )
    .bind(snapshot.owner_id)
    .bind(snapshot.peer_id)
    .bind(snapshot.conversation_id)
    .bind(snapshot.last_msg_id)
    .bind(snapshot.last_sender_id)
    .bind(snapshot.last_receiver_id)
    .bind(snapshot.last_timestamp)
    .bind(snapshot.unread_count)
    .bind(snapshot.created_at)
    .bind(snapshot.updated_at)
    .execute(pool)
    .await?;
    Ok(())
}

/// 删除好友会话快照。
pub async fn delete_friend_conversation_snapshot(
    pool: &Pool<MySql>,
    owner_id: i64,
    conversation_id: i64,
) -> Result<u64> {
    let res = sqlx::query(
        r#"
        DELETE FROM conversation_snapshot
        WHERE owner_id = ? AND conversation_id = ?
        "#,
    )
    .bind(owner_id)
    .bind(conversation_id)
    .execute(pool)
    .await?;
    Ok(res.rows_affected())
}

/// 按用户分页查询好友会话快照。
pub async fn list_friend_conversation_snapshots(
    pool: &Pool<MySql>,
    owner_id: i64,
    before_updated_at: Option<i64>,
    before_conversation_id: Option<i64>,
    limit: usize,
) -> Result<Vec<FriendConversationSnapshot>> {
    let limit = limit.max(1);

    let mut qb = QueryBuilder::new(
        r#"
        SELECT
            owner_id,
            peer_id,
            conversation_id,
            last_msg_id,
            last_sender_id,
            last_receiver_id,
            last_timestamp,
            unread_count,
            created_at,
            updated_at
        FROM conversation_snapshot
        WHERE owner_id = 
        "#,
    );

    qb.push_bind(owner_id);

    if let Some(ts) = before_updated_at {
        qb.push(" AND (updated_at < ");
        qb.push_bind(ts);
        qb.push(" OR (updated_at = ");
        qb.push_bind(ts);
        if let Some(cid) = before_conversation_id {
            qb.push(" AND conversation_id < ");
            qb.push_bind(cid);
        } else {
            qb.push(" AND conversation_id < 9223372036854775807");
        }
        qb.push("))");
    }

    qb.push(" ORDER BY updated_at DESC, conversation_id DESC LIMIT ");
    qb.push_bind(limit as i64);

    let rows = qb.build().fetch_all(pool).await?;

    Ok(rows
        .into_iter()
        .map(|row| FriendConversationSnapshot {
            owner_id: row.get("owner_id"),
            peer_id: row.get("peer_id"),
            conversation_id: row.get("conversation_id"),
            last_msg_id: row.get("last_msg_id"),
            last_sender_id: row.get("last_sender_id"),
            last_receiver_id: row.get("last_receiver_id"),
            last_timestamp: row.get("last_timestamp"),
            unread_count: row.get::<i32, _>("unread_count"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
        })
        .collect())
}
