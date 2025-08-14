// friend-service/src/store/mysql.rs
use anyhow::{Context, Result};
use async_trait::async_trait;
use sqlx::{mysql::MySqlQueryResult, MySql, Pool, QueryBuilder};
use std::sync::Arc;
use sysinfo::User;
use common::config::{get_db, MySqlPool};
use common::UserId;

#[async_trait]
pub trait FriendStorage: Send + Sync + 'static {
    async fn load_friends(&self, user_id: UserId) -> Result<Option<Vec<UserId>>>;
    async fn save_friends(&self, user_id: UserId, friends: &[UserId]) -> Result<()>;
    async fn delete_friends(&self, user_id: UserId) -> Result<()>;
}

#[derive(Clone)]
pub struct MySqlFriendStore {
    pool: Arc<MySqlPool>,
    chunk_size: usize,
}

impl MySqlFriendStore {
    /// 使用全局配置创建（依赖 common::config::get_db）
    pub fn new() -> Self {
        Self {
            pool: get_db(),
            chunk_size: 1000,
        }
    }

    /// 使用外部注入的连接池（便于测试/多库）
    pub fn from_pool(pool: Arc<MySqlPool>) -> Self {
        Self {
            pool,
            chunk_size: 1000,
        }
    }

    /// 配置批量插入 chunk 大小（默认 1000，最小 1）
    pub fn with_chunk_size(mut self, n: usize) -> Self {
        self.chunk_size = n.max(1);
        self
    }

    #[inline]
    pub fn pool(&self) -> &Pool<MySql> {
        self.pool.as_ref()
    }
}

#[async_trait]
impl FriendStorage for MySqlFriendStore {
    async fn load_friends(&self, user_id: UserId) -> Result<Option<Vec<UserId>>> {
        let rows: Vec<UserId> = sqlx::query_scalar(
            r#"
            SELECT friend_id
            FROM user_friends
            WHERE user_id = ?
            ORDER BY friend_id ASC
            "#,
        )
            .bind(user_id as u64)
            .fetch_all(self.pool())
            .await
            .with_context(|| format!("load_friends: fetch_all failed, user_id={}", user_id))?;

        if rows.is_empty() {
            Ok(None)
        } else {
            Ok(Some(rows))
        }
    }

    async fn save_friends(&self, user_id: UserId, friends: &[UserId]) -> Result<()> {
        let mut tx = self.pool().begin().await?;

        // 1) 删除旧数据
        sqlx::query(r#"DELETE FROM user_friends WHERE user_id = ?"#)
            .bind(user_id as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("save_friends: delete failed, user_id={}", user_id))?;

        // 2) 批量插入新数据（分块）
        if !friends.is_empty() {
            for chunk in friends.chunks(self.chunk_size) {
                let mut qb: QueryBuilder<MySql> =
                    QueryBuilder::new("INSERT INTO user_friends (user_id, friend_id) ");
                qb.push_values(chunk, |mut b, &fid| {
                    b.push_bind(user_id as u64).push_bind(fid);
                });

                let query = qb.build();
                let _res: MySqlQueryResult = query
                    .execute(&mut *tx)
                    .await
                    .with_context(|| {
                        format!(
                            "save_friends: batch insert failed, user_id={}, chunk_len={}",
                            user_id,
                            chunk.len()
                        )
                    })?;
            }
        }

        // 3) 更新元数据表
        sqlx::query(
            r#"
            INSERT INTO user_friends_meta (user_id, friend_count)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
              friend_count = VALUES(friend_count),
              updated_at = CURRENT_TIMESTAMP
            "#,
        )
            .bind(user_id as u64)
            .bind(friends.len() as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("save_friends: upsert meta failed, user_id={}", user_id))?;

        tx.commit().await?;
        Ok(())
    }

    async fn delete_friends(&self, user_id: UserId) -> Result<()> {
        let mut tx = self.pool().begin().await?;

        sqlx::query(r#"DELETE FROM user_friends WHERE user_id = ?"#)
            .bind(user_id as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("delete_friends: from user_friends failed, user_id={}", user_id))?;

        sqlx::query(r#"DELETE FROM user_friends_meta WHERE user_id = ?"#)
            .bind(user_id as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("delete_friends: from user_friends_meta failed, user_id={}", user_id))?;

        tx.commit().await?;
        Ok(())
    }
}
