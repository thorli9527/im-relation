// friend_service/src/store/mysql.rs
use anyhow::{Context, Result};
use async_trait::async_trait;
use common::config::{get_db, MySqlPool};
use common::UID;
use sqlx::{mysql::MySqlRow, MySql, QueryBuilder, Row};
use std::sync::Arc;

// =============== 领域模型与接口 ===============

#[derive(Debug, Clone)]
pub struct FriendEntry {
    pub friend_id: UID,
    pub alias: Option<String>,
    pub remark: Option<String>,
    pub blacklisted: bool,
    pub created_at: i64, // UNIX_TIMESTAMP 秒
    pub updated_at: i64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AddOutcome {
    Inserted,
    Updated,
    Unchanged,
}

#[async_trait]
pub trait FriendRepo: Send + Sync + 'static {
    async fn add_friend(&self, user: UID, friend: UID, alias: Option<&str>) -> Result<AddOutcome>;
    /// 原子地为双方建立好友关系，并刷新两侧计数（以实时 COUNT(*) 为准）。
    async fn add_friend_both(
        &self,
        a: UID,
        b: UID,
        alias_for_a: Option<&str>,
        alias_for_b: Option<&str>,
    ) -> Result<()>;
    async fn remove_friend(&self, user: UID, friend: UID) -> Result<bool>;
    async fn set_alias(&self, user: UID, friend: UID, alias: Option<&str>) -> Result<bool>;
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
}

#[async_trait]
impl FriendRepo for FriendStorage {
    async fn add_friend(&self, user: UID, friend: UID, alias: Option<&str>) -> Result<AddOutcome> {
        let insert_res = sqlx::query(
            r#"
        INSERT INTO friend_edge (uid, friend_id, alias, remark)
        VALUES (?, ?, ?, ?)
        "#,
        )
        .bind(user as u64)
        .bind(friend as u64)
        .bind(alias)
        .bind(alias)
        .execute(self.db())
        .await;

        match insert_res {
            Ok(_ok) => {
                // 计数 +1（失败不阻塞主流程）
                let _ = sqlx::query(
                    r#"
                INSERT INTO user_friends_meta (uid, friend_count)
                VALUES (?, 1)
                ON DUPLICATE KEY UPDATE
                  friend_count = friend_count + 1,
                  updated_at   = CURRENT_TIMESTAMP
                "#,
                )
                .bind(user as u64)
                .execute(self.db())
                .await;

                Ok(AddOutcome::Inserted)
            }

            Err(sqlx::Error::Database(db_err)) => {
                // 用 SQLSTATE 判断“唯一键冲突”（MySQL=23000）
                let is_dup = db_err.code().as_deref() == Some("23000");
                if !is_dup {
                    return Err(sqlx::Error::Database(db_err))
                        .with_context(|| "add_friend: insert failed");
                }

                // 已存在：读取现有 alias 并比较
                let db_alias: Option<String> = sqlx::query_scalar(
                    r#"SELECT alias FROM friend_edge WHERE uid=? AND friend_id=? "#,
                )
                .bind(user as u64)
                .bind(friend as u64)
                .fetch_optional(self.db())
                .await
                .with_context(|| "add_friend: fetch alias after dup key")?
                .flatten();

                let changed = match (db_alias.as_deref(), alias) {
                    (None, None) => false,
                    (Some(a), Some(b)) => a != b,
                    (Some(_), None) | (None, Some(_)) => true,
                };

                if changed {
                    sqlx::query(
                        r#"
                    UPDATE friend_edge
                    SET alias = ?, remark = ?, updated_at = CURRENT_TIMESTAMP
                    WHERE uid=? AND friend_id=?
                    "#,
                    )
                    .bind(alias)
                    .bind(alias)
                    .bind(user as u64)
                    .bind(friend as u64)
                    .execute(self.db())
                    .await
                    .with_context(|| "add_friend: update alias on dup")?;

                    Ok(AddOutcome::Updated)
                } else {
                    Ok(AddOutcome::Unchanged)
                }
            }

            Err(e) => Err(e).with_context(|| "add_friend: insert failed"),
        }
    }

    async fn add_friend_both(
        &self,
        a: UID,
        b: UID,
        alias_for_a: Option<&str>,
        alias_for_b: Option<&str>,
    ) -> Result<()> {
        let mut tx = self
            .db()
            .begin()
            .await
            .with_context(|| "add_friend_both: begin tx")?;

        // 双向 UPSERT（幂等），别名按传入值覆盖
        sqlx::query(
            r#"
            INSERT INTO friend_edge (uid, friend_id, alias, remark)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE alias=VALUES(alias), remark=VALUES(remark), updated_at=CURRENT_TIMESTAMP
            "#,
        )
        .bind(a as u64)
        .bind(b as u64)
        .bind(alias_for_a)
        .bind(alias_for_a)
        .execute(&mut *tx)
        .await
        .with_context(|| "add_friend_both: upsert A->B failed")?;

        sqlx::query(
            r#"
            INSERT INTO friend_edge (uid, friend_id, alias, remark)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE alias=VALUES(alias), remark=VALUES(remark), updated_at=CURRENT_TIMESTAMP
            "#,
        )
        .bind(b as u64)
        .bind(a as u64)
        .bind(alias_for_b)
        .bind(alias_for_b)
        .execute(&mut *tx)
        .await
        .with_context(|| "add_friend_both: upsert B->A failed")?;

        // 计数以真实行数为准
        let cnt_a: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM friend_edge WHERE uid=?")
            .bind(a as u64)
            .fetch_one(&mut *tx)
            .await
            .with_context(|| "add_friend_both: count A failed")?;
        sqlx::query(
            r#"
            INSERT INTO user_friends_meta (uid, friend_count)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE friend_count=VALUES(friend_count), updated_at=CURRENT_TIMESTAMP
            "#,
        )
        .bind(a as u64)
        .bind(cnt_a as u64)
        .execute(&mut *tx)
        .await
        .with_context(|| "add_friend_both: upsert meta A failed")?;

        let cnt_b: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM friend_edge WHERE uid=?")
            .bind(b as u64)
            .fetch_one(&mut *tx)
            .await
            .with_context(|| "add_friend_both: count B failed")?;
        sqlx::query(
            r#"
            INSERT INTO user_friends_meta (uid, friend_count)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE friend_count=VALUES(friend_count), updated_at=CURRENT_TIMESTAMP
            "#,
        )
        .bind(b as u64)
        .bind(cnt_b as u64)
        .execute(&mut *tx)
        .await
        .with_context(|| "add_friend_both: upsert meta B failed")?;

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

    async fn set_alias(&self, user: UID, friend: UID, alias: Option<&str>) -> Result<bool> {
        // 仅在值真的变化时更新
        let changed = if let Some(a) = alias {
            let res = sqlx::query(
                r#"
                UPDATE friend_edge
                SET alias=?, remark=?, updated_at=CURRENT_TIMESTAMP
                WHERE uid=? AND friend_id=?
                  AND (alias IS NULL OR alias <> ? OR remark IS NULL OR remark <> ?)
                "#,
            )
            .bind(a)
            .bind(a)
            .bind(user as u64)
            .bind(friend as u64)
            .bind(a)
            .bind(a)
            .execute(self.db())
            .await
            .with_context(|| "set_alias: update alias failed")?;
            res.rows_affected() > 0
        } else {
            let res = sqlx::query(
                r#"
                UPDATE friend_edge
                SET alias=NULL, remark=NULL, updated_at=CURRENT_TIMESTAMP
                WHERE uid=? AND friend_id=? AND (alias IS NOT NULL OR remark IS NOT NULL)
                "#,
            )
            .bind(user as u64)
            .bind(friend as u64)
            .execute(self.db())
            .await
            .with_context(|| "set_alias: clear alias failed")?;
            res.rows_affected() > 0
        };
        Ok(changed)
    }

    async fn set_remark(&self, user: UID, friend: UID, remark: Option<&str>) -> Result<bool> {
        let rows = sqlx::query(
            r#"
            UPDATE friend_edge
            SET remark=?, updated_at=CURRENT_TIMESTAMP
            WHERE uid=? AND friend_id=?
            "#,
        )
        .bind(remark)
        .bind(user as u64)
        .bind(friend as u64)
        .execute(self.db())
        .await
        .with_context(|| "set_remark: update remark failed")?
        .rows_affected();
        Ok(rows > 0)
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
                SELECT friend_id, alias, remark, blacklisted,
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
                SELECT friend_id, alias, remark, blacklisted,
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
            let alias: Option<String> = r.try_get(1)?;
            let remark: Option<String> = r.try_get(2)?;
            let blacklisted: i32 = r.try_get(3)?;
            let created_at: i64 = r.try_get(4)?;
            let updated_at: i64 = r.try_get(5)?;
            next = Some(fid as UID);
            items.push(FriendEntry {
                friend_id: fid as UID,
                alias,
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
            let mut qb: QueryBuilder<MySql> =
                QueryBuilder::new("INSERT INTO friend_edge (uid, friend_id, alias, remark) ");
            qb.push_values(chunk, |mut b, (fid, alias)| {
                b.push_bind(user as u64)
                    .push_bind(*fid as u64)
                    .push_bind(*alias)
                    .push_bind(*alias);
            });
            qb.push(
                " ON DUPLICATE KEY UPDATE alias=VALUES(alias), remark=VALUES(remark), updated_at=CURRENT_TIMESTAMP ",
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
