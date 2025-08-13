use anyhow::{Context, Result};
use async_trait::async_trait;
use sqlx::{mysql::MySqlQueryResult, MySql, Pool, Row};
use std::convert::TryFrom;
use std::ops::Deref;
use std::sync::Arc;
use common::config::{get_db, MySqlPool};
use crate::common::GroupId;
use crate::grpc::group_service::MemberRef;
use super::GroupStorage;

/// MySQL 实现的 GroupStorage。
/// - `pool`: 连接池（sqlx::Pool 内部已是 Arc，按值持有即可）
/// - `chunk_size`: 批量插入单批条数上限（避免超出 max_allowed_packet）
pub struct MySqlStore {
    pool: Arc<MySqlPool>,
    chunk_size: usize,
}

impl MySqlStore {
    /// 默认 chunk_size = 1000，通常比较安全
    pub fn new() -> Self {
        Self { pool: get_db(), chunk_size: 1000 }
    }

    /// 自定义批量插入 chunk 大小（至少为 1）
    pub fn with_chunk_size(mut self, n: usize) -> Self {
        self.chunk_size = n.max(1);
        self
    }

    /// 暴露 Pool 引用，便于上层复用（如做额外 SQL）
    #[inline]
    pub fn pool(&self) -> &Pool<MySql> {
        self.pool.as_ref()
    }
}

#[async_trait]
impl GroupStorage for MySqlStore {
    /// 读取某群的**全部成员**，按 user_id 升序返回。
    /// 注意：fetch_all 会把所有行一次性拉入内存；如成员非常多，请评估内存占用。
    async fn load_group(&self, gid: GroupId) -> Result<Option<Vec<MemberRef>>> {
        // SQL：全量拉取成员，排序便于后续分页/二分
        let rows = sqlx::query(
            r#"
            SELECT user_id, role
            FROM group_member
            WHERE group_id = ?
            ORDER BY user_id ASC
            "#,
        )
            .bind(gid as u64)
            .fetch_all(self.pool())
            .await
            .with_context(|| format!("load_group: fetch_all failed, group_id={}", gid))?;

        if rows.is_empty() {
            return Ok(None);
        }

        let mut out = Vec::with_capacity(rows.len());
        for r in rows {
            // 按列名读取可读性更好；若表定义是 BIGINT UNSIGNED，映射到 Rust u64
            let uid_u64: u64 = r
                .try_get("user_id")
                .with_context(|| "load_group: column user_id missing or type mismatch")?;

            // role 建议在表里用 INT（范围在 i32），读出时做显式转换检查
            let role_i64: i64 = r
                .try_get("role")
                .with_context(|| "load_group: column role missing or type mismatch")?;
            let role = i32::try_from(role_i64)
                .with_context(|| format!("load_group: role overflow, value={}", role_i64))?;

            out.push(MemberRef {
                id: uid_u64 as i64, // 下游若要求 i64，这里统一转换
                role,
            });
        }
        Ok(Some(out))
    }

    /// 全量保存某群的成员列表：先删后插，再更新 meta。
    /// 并发注意：
    /// - 若可能有并发写，请考虑在事务开头对 group_meta 该行做 `SELECT ... FOR UPDATE`
    ///   以串行化同一 group_id 的写入，或引入 version/updated_at 做乐观锁。
    async fn save_group(&self, gid: GroupId, members: &[MemberRef]) -> Result<()> {
        let mut tx = self.pool().begin().await?;

        // 可选：对当前 group_id 的 meta 行加锁，串行化同组写（若并发写入可能发生）
        // sqlx::query("SELECT group_id FROM group_meta WHERE group_id = ? FOR UPDATE")
        //     .bind(gid as u64)
        //     .execute(&mut *tx)
        //     .await?;

        // 1) 清空旧成员
        sqlx::query(r#"DELETE FROM group_member WHERE group_id = ?"#)
            .bind(gid as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("save_group: delete group_member failed, group_id={}", gid))?;

        // 2) 批量插入新成员
        if !members.is_empty() {
            for chunk in members.chunks(self.chunk_size) {
                // 预估 SQL 容量（大致，每个 "(?,?,?)" 7 字节 + 逗号；这里只是近似，避免多次扩容）
                let mut qb = String::with_capacity(64 + chunk.len() * 8);
                qb.push_str("INSERT INTO group_member (group_id, user_id, role) VALUES ");

                // 构造 "(?,?,?),(?,?,?),..."
                for (i, _) in chunk.iter().enumerate() {
                    if i > 0 {
                        qb.push(',');
                    }
                    qb.push_str("(?,?,?)");
                }

                // 绑定所有参数：按顺序 (gid, uid, role) * N
                let mut q = sqlx::query(&qb);
                for m in chunk {
                    // 这里可考虑去重（若上游可能传重复 user_id）
                    q = q.bind(gid as u64)
                        .bind(u64::try_from(m.id).unwrap_or_default()) // 若 m.id 是 i64，可显式检查
                        .bind(i64::from(m.role));
                }

                let _res: MySqlQueryResult = q.execute(&mut *tx).await?;
                // 如需校验影响行数一致，可断言：
                // assert_eq!(_res.rows_affected() as usize, chunk.len());
            }
        }

        // 3) 更新 group_meta（member_cnt 与更新时间）
        sqlx::query(
            r#"
            INSERT INTO group_meta (group_id, member_cnt)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
              member_cnt = VALUES(member_cnt),
              updated_at = CURRENT_TIMESTAMP
            "#,
        )
            .bind(gid as u64)
            .bind(members.len() as u64)
            .execute(&mut *tx)
            .await
            .with_context(|| format!("save_group: upsert group_meta failed, group_id={}", gid))?;

        tx.commit().await?;
        Ok(())
    }

    /// 删除群：成员与元数据都删
    async fn delete_group(&self, gid: GroupId) -> Result<()> {
        let mut tx = self.pool().begin().await?;

        sqlx::query(r#"DELETE FROM group_member WHERE group_id = ?"#)
            .bind(gid as u64)
            .execute(&mut *tx)
            .await?;

        sqlx::query(r#"DELETE FROM group_meta WHERE group_id = ?"#)
            .bind(gid as u64)
            .execute(&mut *tx)
            .await?;

        tx.commit().await?;
        Ok(())
    }

    /// 读取某用户加入的群（升序）。同样注意 fetch_all 的内存占用问题。
    async fn load_user_groups(&self, uid: i64) -> Result<Option<Vec<i64>>> {
        let rows = sqlx::query(
            r#"
            SELECT group_id
            FROM group_member
            WHERE user_id = ?
            ORDER BY group_id ASC
            "#,
        )
            .bind(u64::try_from(uid).unwrap_or_default())
            .fetch_all(self.pool())
            .await?;

        if rows.is_empty() {
            return Ok(None);
        }

        let mut out = Vec::with_capacity(rows.len());
        for r in rows {
            let gid_u64: u64 = r.try_get("group_id")?;
            out.push(gid_u64 as i64);
        }
        Ok(Some(out))
    }
}
