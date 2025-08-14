use anyhow::{Context, Result};
use async_trait::async_trait;
use sqlx::{mysql::MySqlQueryResult, MySql, Pool, Row};
use std::collections::HashMap;
use std::convert::TryFrom;
use std::sync::Arc;

use common::config::{get_db, MySqlPool};
use crate::common::GroupId;
use crate::grpc::group_service::MemberRef;
use super::GroupStorage;

/// MySQL 实现的 GroupStorage。
/// - `pool`: 连接池（sqlx::Pool 内部已是 Arc，按值持有即可）
/// - `chunk_size`: 批量插入/删除单批条数上限（避免超出 max_allowed_packet）
pub struct MySqlStore {
    pool: Arc<MySqlPool>,
    chunk_size: usize,
}

impl MySqlStore {
    /// 默认 chunk_size = 1000，通常比较安全
    pub fn new() -> Self {
        Self { pool: get_db(), chunk_size: 1000 }
    }

    /// 自定义批量 chunk 大小（至少为 1）
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
    async fn load_group(&self, gid: GroupId) -> Result<Option<Vec<MemberRef>>> {
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
            let uid_u64: u64 = r
                .try_get("user_id")
                .with_context(|| "load_group: column user_id missing or type mismatch")?;
            let role_i64: i64 = r
                .try_get("role")
                .with_context(|| "load_group: column role missing or type mismatch")?;
            let role = i32::try_from(role_i64)
                .with_context(|| format!("load_group: role overflow, value={}", role_i64))?;

            out.push(MemberRef { id: uid_u64 as i64, role });
        }
        Ok(Some(out))
    }

    /// 仅对差异做写入（方案 A）：
    /// - 新增：内存有、DB 无 -> INSERT
    /// - 删除：DB 有、内存无 -> DELETE
    /// - 角色变更：交集且 role 不同 -> UPDATE
    ///
    /// 注意：
    /// 1) 全过程放在**同一事务**中，避免中间态被读到。
    /// 2) 默认 RR 隔离下外部一致性读看不到未提交变化。
    /// 3) 强烈建议表上有联合唯一索引/主键 (group_id, user_id)。
    async fn save_group(&self, gid: GroupId, members: &[MemberRef]) -> Result<()> {
        let mut tx = self.pool().begin().await?;

        // --- 1) 读取 DB 当前视图 ---
        let db_rows = sqlx::query(
            r#"
            SELECT user_id, role
            FROM group_member
            WHERE group_id = ?
            "#,
        )
            .bind(gid as u64)
            .fetch_all(&mut *tx)
            .await
            .with_context(|| format!("save_group(diff): fetch db members failed, group_id={}", gid))?;

        // DB -> HashMap<uid, role>
        let mut db_map: HashMap<i64, i32> = HashMap::with_capacity(db_rows.len());
        for r in db_rows {
            let uid_u64: u64 = r.try_get("user_id")?;
            let role_i64: i64 = r.try_get("role")?;
            let role = i32::try_from(role_i64)
                .with_context(|| format!("save_group(diff): db role overflow, v={}", role_i64))?;
            db_map.insert(uid_u64 as i64, role);
        }

        // 内存 -> HashMap<uid, role>（顺便去重 & 最后一次覆盖）
        let mut mem_map: HashMap<i64, i32> = HashMap::with_capacity(members.len());
        for m in members {
            mem_map.insert(m.id, m.role);
        }

        // --- 2) 计算差异 ---
        let mut to_add: Vec<(i64, i32)> = Vec::new();
        let mut to_del: Vec<i64> = Vec::new();
        let mut to_role: Vec<(i64, i32)> = Vec::new();

        // 新增 & 角色变更
        for (&uid, &mrole) in mem_map.iter() {
            match db_map.get(&uid) {
                None => to_add.push((uid, mrole)),
                Some(&drole) if drole != mrole => to_role.push((uid, mrole)),
                _ => {}
            }
        }
        // 删除
        for (&uid, _) in db_map.iter() {
            if !mem_map.contains_key(&uid) {
                to_del.push(uid);
            }
        }

        // --- 3) 执行差异写入（分批） ---
        // 3.1 删除：DELETE ... WHERE group_id=? AND user_id IN (?,...,?)
        for chunk in to_del.chunks(self.chunk_size) {
            let mut sql = String::from("DELETE FROM group_member WHERE group_id=? AND user_id IN (");
            sql.push_str(&vec!["?"; chunk.len()].join(","));
            sql.push(')');

            let mut q = sqlx::query(&sql).bind(gid as u64);
            for uid in chunk {
                q = q.bind(u64::try_from(*uid).unwrap_or_default());
            }
            q.execute(&mut *tx)
                .await
                .with_context(|| format!("save_group(diff): delete chunk failed, group_id={}", gid))?;
        }

        // 3.2 新增：INSERT ... VALUES (?,?,?),(?,?,?),...
        for chunk in to_add.chunks(self.chunk_size) {
            let mut sql = String::from("INSERT INTO group_member (group_id, user_id, role) VALUES ");
            sql.push_str(&vec!["(?,?,?)"; chunk.len()].join(","));

            let mut q = sqlx::query(&sql);
            for (uid, role) in chunk {
                q = q
                    .bind(gid as u64)
                    .bind(u64::try_from(*uid).unwrap_or_default())
                    .bind(i64::from(*role));
            }
            let _res: MySqlQueryResult = q
                .execute(&mut *tx)
                .await
                .with_context(|| format!("save_group(diff): insert chunk failed, group_id={}", gid))?;
        }

        // 3.3 角色变更：逐条 UPDATE（或按角色分组拼 CASE WHEN）
        // 逐条更稳（避免巨大 SQL），量大时也可分批
        for chunk in to_role.chunks(self.chunk_size) {
            for (uid, role) in chunk {
                sqlx::query(
                    r#"
                    UPDATE group_member
                    SET role = ?
                    WHERE group_id = ? AND user_id = ?
                    "#,
                )
                    .bind(i64::from(*role))
                    .bind(gid as u64)
                    .bind(u64::try_from(*uid).unwrap_or_default())
                    .execute(&mut *tx)
                    .await
                    .with_context(|| {
                        format!(
                            "save_group(diff): update role failed, group_id={}, user_id={}",
                            gid, uid
                        )
                    })?;
            }
        }

        // --- 4) 更新 meta（成员数与更新时间）；只写必要 ---
        // 注意：members.len() 是“内存视图”成员数，代表新状态
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
            .with_context(|| format!("save_group(diff): upsert group_meta failed, group_id={}", gid))?;

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

    /// 读取某用户加入的群（升序）。
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
