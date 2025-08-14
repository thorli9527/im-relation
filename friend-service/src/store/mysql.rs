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
        use std::collections::HashSet;

        let mut tx = self.pool().begin().await?;

        // --- 1) 读取 DB 当前好友列表 ---
        let db_rows: Vec<u64> = sqlx::query_scalar(
            r#"
            SELECT friend_id
            FROM user_friends
            WHERE user_id = ?
            "#,
        )
            .bind(user_id as u64)
            .fetch_all(&mut *tx)
            .await
            .with_context(|| format!("save_friends(diff): fetch db rows failed, user_id={}", user_id))?;

        let db_set: HashSet<u64> = db_rows.into_iter().collect();

        // 内存去重（避免上层重复传入）
        let mem_set: HashSet<u64> = friends.iter().copied().map(|x| x as u64).collect();

        // --- 2) 计算差异 ---
        // 待新增：内存有、DB 无
        let mut to_add: Vec<u64> = Vec::new();
        // 待删除：DB 有、内存无
        let mut to_del: Vec<u64> = Vec::new();

        for fid in mem_set.iter() {
            if !db_set.contains(fid) {
                to_add.push(*fid);
            }
        }
        for fid in db_set.iter() {
            if !mem_set.contains(fid) {
                to_del.push(*fid);
            }
        }

        // --- 3) 执行差异写入（分批 & 同一事务） ---
        // 删除：DELETE FROM user_friends WHERE user_id=? AND friend_id IN (...)
        for chunk in to_del.chunks(self.chunk_size) {
            let mut sql = String::from(
                "DELETE FROM user_friends WHERE user_id=? AND friend_id IN (",
            );
            sql.push_str(&vec!["?"; chunk.len()].join(","));
            sql.push(')');

            let mut q = sqlx::query(&sql).bind(user_id as u64);
            for fid in chunk {
                q = q.bind(*fid);
            }
            q.execute(&mut *tx)
                .await
                .with_context(|| format!("save_friends(diff): delete chunk failed, user_id={}", user_id))?;
        }

        // 新增：INSERT INTO user_friends (user_id, friend_id) VALUES (...),(...)
        if !to_add.is_empty() {
            use sqlx::QueryBuilder;
            for chunk in to_add.chunks(self.chunk_size) {
                let mut qb: QueryBuilder<MySql> =
                    QueryBuilder::new("INSERT INTO user_friends (user_id, friend_id) ");
                qb.push_values(chunk, |mut b, &fid| {
                    b.push_bind(user_id as u64).push_bind(fid);
                });
                let _res: MySqlQueryResult = qb
                    .build()
                    .execute(&mut *tx)
                    .await
                    .with_context(|| {
                        format!(
                            "save_friends(diff): insert chunk failed, user_id={}, chunk_len={}",
                            user_id,
                            chunk.len()
                        )
                    })?;
            }
        }

        // --- 4) 更新元数据（按“内存视图”为准） ---
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
            .bind(mem_set.len() as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("save_friends(diff): upsert meta failed, user_id={}", user_id))?;

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
