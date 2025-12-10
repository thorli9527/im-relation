// friend_service/src/store/mysql.rs
use anyhow::{Context, Result};
use async_trait::async_trait;
use common::config::{get_db, MySqlPool};
use common::UID;
use log::info;
use sqlx::{mysql::MySqlRow, MySql, QueryBuilder, Row, Transaction};
use std::sync::Arc;
// =============== 领域模型与接口 ===============

#[derive(Debug, Clone)]
pub struct FriendEntry {
    pub friend_id: UID,
    pub nickname: Option<String>,
    pub apply_source: i32,
    pub remark: Option<String>,
    pub blacklisted: bool,
    pub created_at: i64, // UNIX_TIMESTAMP 秒
    pub updated_at: i64,
}

#[async_trait]
pub trait FriendRepo: Send + Sync + 'static {
    /// 原子地为双方建立好友关系，并刷新两侧计数（以实时 COUNT(*) 为准）。
    async fn add_friend_both(
        &self,
        a: UID,
        b: UID,
        nickname_for_a: Option<&str>,
        nickname_for_b: Option<&str>,
        remark_for_a: Option<&str>,
        remark_for_b: Option<&str>,
        apply_source: i32,
    ) -> Result<()>;
    async fn remove_friend(&self, user: UID, friend: UID) -> Result<bool>;
    async fn set_nickname(&self, user: UID, friend: UID, nickname: Option<&str>) -> Result<bool>;
    async fn set_remark(&self, user: UID, friend: UID, remark: Option<&str>) -> Result<bool>;
    async fn set_blacklist(&self, user: UID, friend: UID, blocked: bool) -> Result<bool>;
    async fn is_friend(&self, user: UID, friend: UID) -> Result<bool>;
    async fn page_friends(
        &self,
        user: UID,
        cursor: Option<UID>,
        limit: u32,
    ) -> Result<(Vec<FriendEntry>, Option<UID>)>;
    async fn upsert_bulk(&self, user: UID, items: &[(UID, Option<&str>)]) -> Result<()>;
    async fn clear_all(&self, user: UID) -> Result<()>;
    async fn count(&self, user: UID) -> Result<u64>;
}

// =============== MySQL 实现（对齐 friend_edge / user_friends_meta） ===============

#[derive(Clone)]
pub struct FriendStorage {
    pool: Arc<MySqlPool>,
    chunk: usize,
}

impl FriendStorage {
    /// 使用全局连接池
    pub fn new() -> Self {
        Self {
            pool: get_db(),
            chunk: 1000,
        }
    }

    /// 自定义连接池
    pub fn from_pool(pool: Arc<MySqlPool>) -> Self {
        Self { pool, chunk: 1000 }
    }

    /// 批量写入分片大小（默认 1000）
    pub fn with_chunk(mut self, n: usize) -> Self {
        self.chunk = n.max(1);
        self
    }

    #[inline]
    fn db(&self) -> &MySqlPool {
        self.pool.as_ref()
    }

    // 单向插入好友关系并刷新计数，依赖外部事务保证双向一致
    async fn add_friend<'t>(
        &self,
        tx: Transaction<'t, MySql>,
        user: UID,
        friend: UID,
        nickname: Option<&str>,
        remark: Option<&str>,
        apply_source: i32,
    ) -> Result<Transaction<'t, MySql>> {
        let mut tx = tx;
        sqlx::query(
            r#"
            INSERT INTO friend_edge (uid, friend_id, nickname, apply_source, remark)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
              nickname = COALESCE(VALUES(nickname), nickname),
              apply_source = VALUES(apply_source),
              remark   = COALESCE(VALUES(remark), remark),
              updated_at=CURRENT_TIMESTAMP
            "#,
        )
        .bind(user as u64)
        .bind(friend as u64)
        .bind(nickname)
        .bind(apply_source)
        .bind(remark)
        .execute(&mut *tx)
        .await
        .with_context(|| format!("add_friend: upsert {user}->{friend} failed"))?;

        let cnt: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM friend_edge WHERE uid=?")
            .bind(user as u64)
            .fetch_one(&mut *tx)
            .await
            .with_context(|| format!("add_friend: count {user} failed"))?;
        sqlx::query(
            r#"
            INSERT INTO user_friends_meta (uid, friend_count)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE friend_count=VALUES(friend_count), updated_at=CURRENT_TIMESTAMP
            "#,
        )
        .bind(user as u64)
        .bind(cnt as u64)
        .execute(&mut *tx)
        .await
        .with_context(|| format!("add_friend: upsert meta {user} failed"))?;

        Ok(tx)
    }
}

#[async_trait]
impl FriendRepo for FriendStorage {
    async fn add_friend_both(
        &self,
        a: UID,
        b: UID,
        nickname_for_a: Option<&str>,
        nickname_for_b: Option<&str>,
        remark_for_a: Option<&str>,
        remark_for_b: Option<&str>,
        apply_source: i32,
    ) -> Result<()> {
        let tx = self
            .db()
            .begin()
            .await
            .with_context(|| "add_friend_both: begin tx")?;
        // 双向 UPSERT（幂等），别名按传入值覆盖
        let tx = self
            .add_friend(tx, a, b, nickname_for_a, remark_for_a, apply_source)
            .await
            .with_context(|| "add_friend_both: add A->B failed")?;

        let mut tx = self
            .add_friend(tx, b, a, nickname_for_b, remark_for_b, apply_source)
            .await
            .with_context(|| "add_friend_both: add B->A failed")?;

        tx.commit().await?;
        Ok(())
    }

    async fn remove_friend(&self, user: UID, friend: UID) -> Result<bool> {
        let mut tx = self
            .db()
            .begin()
            .await
            .with_context(|| "remove_friend: begin tx")?;

        let res = sqlx::query(r#"DELETE FROM friend_edge WHERE uid=? AND friend_id=? "#)
            .bind(user as u64)
            .bind(friend as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| "remove_friend: delete edge failed")?;

        if res.rows_affected() == 1 {
            let _ = sqlx::query(
                r#"
                INSERT INTO user_friends_meta (uid, friend_count)
                VALUES (?, 0)
                ON DUPLICATE KEY UPDATE
                  friend_count = GREATEST(friend_count - 1, 0),
                  updated_at   = CURRENT_TIMESTAMP
                "#,
            )
            .bind(user as u64)
            .execute(&mut *tx)
            .await;
            tx.commit().await?;
            return Ok(true);
        }

        tx.commit().await?;
        Ok(false)
    }

    async fn set_nickname(&self, user: UID, friend: UID, nickname: Option<&str>) -> Result<bool> {
        let res = if let Some(a) = nickname {
            sqlx::query(
                r#"
                UPDATE friend_edge
                SET nickname=?, updated_at=CURRENT_TIMESTAMP
                WHERE uid=? AND friend_id=? AND (nickname IS NULL OR nickname <> ?)
                "#,
            )
            .bind(a)
            .bind(user as u64)
            .bind(friend as u64)
            .bind(a)
            .execute(self.db())
            .await
            .with_context(|| "set_nickname: update nickname failed")?
        } else {
            sqlx::query(
                r#"
                UPDATE friend_edge
                SET nickname=NULL, updated_at=CURRENT_TIMESTAMP
                WHERE uid=? AND friend_id=? AND nickname IS NOT NULL
                "#,
            )
            .bind(user as u64)
            .bind(friend as u64)
            .execute(self.db())
            .await
            .with_context(|| "set_nickname: clear nickname failed")?
        };
        Ok(res.rows_affected() > 0)
    }

    async fn set_remark(&self, user: UID, friend: UID, remark: Option<&str>) -> Result<bool> {
        let res = if let Some(a) = remark {
            sqlx::query(
                r#"
                UPDATE friend_edge
                SET remark=?, updated_at=CURRENT_TIMESTAMP
                WHERE uid=? AND friend_id=? AND (remark IS NULL OR remark <> ?)
                "#,
            )
            .bind(a)
            .bind(user as u64)
            .bind(friend as u64)
            .bind(a)
            .execute(self.db())
            .await
            .with_context(|| "set_remark: update remark failed")?
        } else {
            sqlx::query(
                r#"
                UPDATE friend_edge
                SET remark=NULL, updated_at=CURRENT_TIMESTAMP
                WHERE uid=? AND friend_id=? AND remark IS NOT NULL
                "#,
            )
            .bind(user as u64)
            .bind(friend as u64)
            .execute(self.db())
            .await
            .with_context(|| "set_remark: clear remark failed")?
        };
        Ok(res.rows_affected() > 0)
    }

    async fn set_blacklist(&self, user: UID, friend: UID, blocked: bool) -> Result<bool> {
        let rows = sqlx::query(
            r#"
            UPDATE friend_edge
            SET blacklisted=?, updated_at=CURRENT_TIMESTAMP
            WHERE uid=? AND friend_id=?
            "#,
        )
        .bind(blocked as i32)
        .bind(user as u64)
        .bind(friend as u64)
        .execute(self.db())
        .await
        .with_context(|| "set_blacklist: update flag failed")?
        .rows_affected();
        Ok(rows > 0)
    }

    async fn is_friend(&self, user: UID, friend: UID) -> Result<bool> {
        let exists: Option<i64> =
            sqlx::query_scalar(r#"SELECT 1 FROM friend_edge WHERE uid=? AND friend_id=? LIMIT 1"#)
                .bind(user as u64)
                .bind(friend as u64)
                .fetch_optional(self.db())
                .await
                .with_context(|| "is_friend: select failed")?;
        Ok(exists.is_some())
    }

    async fn page_friends(
        &self,
        user: UID,
        cursor: Option<UID>,
        limit: u32,
    ) -> Result<(Vec<FriendEntry>, Option<UID>)> {
        let lim = limit.clamp(1, 5000) as i64;

        let rows: Vec<MySqlRow> = if let Some(cur) = cursor {
            sqlx::query(
                r#"
                SELECT friend_id, nickname, remark, blacklisted,
                       UNIX_TIMESTAMP(created_at), UNIX_TIMESTAMP(updated_at)
                FROM friend_edge
                WHERE uid=? AND friend_id > ?
                ORDER BY friend_id ASC
                LIMIT ?
                "#,
            )
            .bind(user as u64)
            .bind(cur as u64)
            .bind(lim)
            .fetch_all(self.db())
            .await
        } else {
            sqlx::query(
                r#"
                SELECT friend_id, nickname, apply_source, remark, blacklisted,
                       UNIX_TIMESTAMP(created_at), UNIX_TIMESTAMP(updated_at)
                FROM friend_edge
                WHERE uid=?
                ORDER BY friend_id ASC
                LIMIT ?
                "#,
            )
            .bind(user as u64)
            .bind(lim)
            .fetch_all(self.db())
            .await
        }
        .with_context(|| "page_friends: query failed")?;

        let mut items = Vec::with_capacity(rows.len());
        let mut next: Option<UID> = None;

        for r in rows.into_iter() {
            let fid: u64 = r.try_get(0)?;
            let nickname: Option<String> = r.try_get(1)?;
            let apply_source: i32 = r.try_get(2)?;
            let remark: Option<String> = r.try_get(3)?;
            let blacklisted: i32 = r.try_get(4)?;
            let created_at: i64 = r.try_get(5)?;
            let updated_at: i64 = r.try_get(6)?;
            next = Some(fid as UID);
            items.push(FriendEntry {
                friend_id: fid as UID,
                nickname,
                apply_source,
                remark,
                blacklisted: blacklisted != 0,
                created_at,
                updated_at,
            });
        }

        let next_cursor = if items.len() == lim as usize {
            next
        } else {
            None
        };
        Ok((items, next_cursor))
    }

    async fn upsert_bulk(&self, user: UID, items: &[(UID, Option<&str>)]) -> Result<()> {
        if items.is_empty() {
            return Ok(());
        }

        let mut tx = self
            .db()
            .begin()
            .await
            .with_context(|| "upsert_bulk: begin tx")?;

        for chunk in items.chunks(self.chunk) {
            let mut qb: QueryBuilder<MySql> = QueryBuilder::new(
                "INSERT INTO friend_edge (uid, friend_id, nickname, apply_source, remark) ",
            );
            qb.push_values(chunk, |mut b, (fid, nickname)| {
                b.push_bind(user as u64)
                    .push_bind(*fid as u64)
                    .push_bind(*nickname)
                    .push_bind(0)
                    .push_bind(*nickname);
            });
            qb.push(
                " ON DUPLICATE KEY UPDATE nickname=VALUES(nickname), apply_source=VALUES(apply_source), remark=VALUES(remark), updated_at=CURRENT_TIMESTAMP ",
            );

            qb.build()
                .execute(&mut *tx)
                .await
                .with_context(|| "upsert_bulk: insert chunk failed")?;
        }

        // 刷新计数（以 DB 真实计数为准）
        let cnt: i64 = sqlx::query_scalar(r#"SELECT COUNT(*) FROM friend_edge WHERE uid=? "#)
            .bind(user as u64)
            .fetch_one(&mut *tx)
            .await
            .with_context(|| "upsert_bulk: count failed")?;

        sqlx::query(
            r#"
            INSERT INTO user_friends_meta (uid, friend_count)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE friend_count=VALUES(friend_count), updated_at=CURRENT_TIMESTAMP
            "#,
        )
        .bind(user as u64)
        .bind(cnt as u64)
        .execute(&mut *tx)
        .await
        .with_context(|| "upsert_bulk: upsert meta failed")?;

        tx.commit().await?;
        Ok(())
    }

    async fn clear_all(&self, user: UID) -> Result<()> {
        let mut tx = self
            .db()
            .begin()
            .await
            .with_context(|| "clear_all: begin tx")?;

        sqlx::query(r#"DELETE FROM friend_edge WHERE uid=? "#)
            .bind(user as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| "clear_all: delete edge failed")?;

        sqlx::query(r#"DELETE FROM user_friends_meta WHERE uid=? "#)
            .bind(user as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| "clear_all: delete meta failed")?;

        tx.commit().await?;
        Ok(())
    }

    async fn count(&self, user: UID) -> Result<u64> {
        let c: Option<i64> =
            sqlx::query_scalar(r#"SELECT friend_count FROM user_friends_meta WHERE uid=? "#)
                .bind(user as u64)
                .fetch_optional(self.db())
                .await
                .with_context(|| "count: select meta failed")?;
        Ok(c.unwrap_or(0) as u64)
    }
}
