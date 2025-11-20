use anyhow::Result;
use sqlx::{MySql, Pool, QueryBuilder, Row};

/// 群会话快照记录。
#[derive(Debug, Clone)]
pub struct GroupConversationSnapshot {
    pub uid: i64,
    pub group_id: i64,
    pub last_msg_id: i64,
    pub last_sender_id: i64,
    pub last_timestamp: i64,
    pub unread_count: i32,
    pub created_at: i64,
    pub updated_at: i64,
}

/// 插入或更新群会话快照。
pub async fn upsert_group_conversation_snapshot(
    pool: &Pool<MySql>,
    snapshot: &GroupConversationSnapshot,
) -> Result<()> {
    sqlx::query(
        r#"
        INSERT INTO conversation_snapshot
            (uid, group_id, last_msg_id,
             last_sender_id, last_timestamp, unread_count,
             created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            last_msg_id = VALUES(last_msg_id),
            last_sender_id = VALUES(last_sender_id),
            last_timestamp = VALUES(last_timestamp),
            unread_count = VALUES(unread_count),
            updated_at = VALUES(updated_at)
        "#,
    )
    .bind(snapshot.uid)
    .bind(snapshot.group_id)
    .bind(snapshot.last_msg_id)
    .bind(snapshot.last_sender_id)
    .bind(snapshot.last_timestamp)
    .bind(snapshot.unread_count)
    .bind(snapshot.created_at)
    .bind(snapshot.updated_at)
    .execute(pool)
    .await?;
    Ok(())
}

/// 删除群会话快照。
pub async fn delete_group_conversation_snapshot(
    pool: &Pool<MySql>,
    uid: i64,
    group_id: i64,
) -> Result<u64> {
    let res = sqlx::query(
        r#"
        DELETE FROM conversation_snapshot
        WHERE uid = ? AND group_id = ?
        "#,
    )
    .bind(uid)
    .bind(group_id)
    .execute(pool)
    .await?;
    Ok(res.rows_affected())
}

/// 按用户分页列出群会话快照。
pub async fn list_group_conversation_snapshots(
    pool: &Pool<MySql>,
    uid: i64,
    before_updated_at: Option<i64>,
    before_group_id: Option<i64>,
    limit: usize,
) -> Result<Vec<GroupConversationSnapshot>> {
    let limit = limit.max(1);

    let mut qb = QueryBuilder::new(
        r#"
        SELECT
            uid,
            group_id,
            last_msg_id,
            last_sender_id,
            last_timestamp,
            unread_count,
            created_at,
            updated_at
        FROM conversation_snapshot
        WHERE uid = 
        "#,
    );

    qb.push_bind(uid);

    if let Some(ts) = before_updated_at {
        qb.push(" AND (updated_at < ");
        qb.push_bind(ts);
        qb.push(" OR (updated_at = ");
        qb.push_bind(ts);
        if let Some(gid) = before_group_id {
            qb.push(" AND group_id < ");
            qb.push_bind(gid);
        } else {
            qb.push(" AND group_id < 9223372036854775807");
        }
        qb.push("))");
    }

    qb.push(" ORDER BY updated_at DESC, group_id DESC LIMIT ");
    qb.push_bind(limit as i64);

    let rows = qb.build().fetch_all(pool).await?;

    Ok(rows
        .into_iter()
        .map(|row| GroupConversationSnapshot {
            uid: row.get("uid"),
            group_id: row.get("group_id"),
            last_msg_id: row.get("last_msg_id"),
            last_sender_id: row.get("last_sender_id"),
            last_timestamp: row.get("last_timestamp"),
            unread_count: row.get::<i32, _>("unread_count"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
        })
        .collect())
}
