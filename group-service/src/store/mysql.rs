use anyhow::{Context, Result};
use async_trait::async_trait;
use sqlx::{mysql::MySqlQueryResult, MySql, Pool, Row};
use std::collections::HashMap;
use std::convert::TryFrom;
use std::sync::Arc;
use tonic::codegen::tokio_stream::StreamExt;
use super::GroupStorage;

use crate::grpc::group_service::MemberRef;
use common::config::{get_db, MySqlPool};
use common::GroupId;
const LOAD_GROUP_PAGE_LIMIT: usize = 2_000;
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

    /// —— 新增：Keyset/游标分页（大表友好）——
    /// 返回：(当前页成员, next_cursor)，next_cursor 为本页最后一个 user_id
    pub async fn seek_members(
        &self,
        gid: GroupId,
        after_user_id: Option<i64>,
        limit: usize,
    ) -> Result<(Vec<MemberRef>, Option<i64>)> {
        let limit = (limit.max(1)) as i64;

        let rows = if let Some(after) = after_user_id {
            sqlx::query(
                r#"
                SELECT user_id, alias, role
                FROM group_member
                WHERE group_id = ? AND user_id > ?
                ORDER BY user_id ASC
                LIMIT ?
                "#,
            )
                .bind(gid as u64)
                .bind(u64::try_from(after).unwrap_or_default())
                .bind(limit)
                .fetch_all(self.pool())
                .await
                .with_context(|| format!("seek_members (cursor) failed, group_id={}", gid))?
        } else {
            sqlx::query(
                r#"
                SELECT user_id, alias, role
                FROM group_member
                WHERE group_id = ?
                ORDER BY user_id ASC
                LIMIT ?
                "#,
            )
                .bind(gid as u64)
                .bind(limit)
                .fetch_all(self.pool())
                .await
                .with_context(|| format!("seek_members (first) failed, group_id={}", gid))?
        };

        let mut out = Vec::with_capacity(rows.len());
        let mut next_cursor: Option<i64> = None;

        for r in rows {
            let uid_u64: u64 = r.try_get("user_id")?;
            let alias: Option<String> = r.try_get("alias")?;
            let role_i64: i64 = r.try_get("role")?;
            let role = i32::try_from(role_i64).context("seek_members: role overflow")?;

            let id_i64 = uid_u64 as i64;
            out.push(MemberRef { id: id_i64, alias, role });
            next_cursor = Some(id_i64); // 本页最后一条
        }

        Ok((out, next_cursor))
    }

    /// —— 新增：流式读取（边拉边处理，避免大结果集常驻内存）——
    pub async fn stream_all_members<F>(&self, gid: GroupId, mut handle: F) -> Result<()>
    where
        F: FnMut(MemberRef) -> Result<()> + Send,
    {
        let mut rows = sqlx::query(
            r#"
            SELECT user_id, alias, role
            FROM group_member
            WHERE group_id = ?
            ORDER BY user_id ASC
            "#,
        )
            .bind(gid as u64)
            .fetch(self.pool());

        while let Some(r) = rows.try_next().await? {
            let uid: u64 = r.try_get("user_id")?;
            let alias: Option<String> = r.try_get("alias")?;
            let role_i64: i64 = r.try_get("role")?;
            let role = i32::try_from(role_i64)?;
            handle(MemberRef { id: uid as i64, alias, role })?;
        }
        Ok(())
    }
}

#[async_trait]
impl GroupStorage for MySqlStore {
    /// 读取某群的**全部成员**，按 user_id 升序返回（含 alias）
    async fn load_group(&self, gid: GroupId) -> Result<Option<Vec<MemberRef>>> {
        let mut after: Option<i64> = None;
        let mut out: Vec<MemberRef> = Vec::new();
        let mut first_page = true;

        loop {
            let (page, next) = self
                .seek_members(gid, after, LOAD_GROUP_PAGE_LIMIT)
                .await
                .with_context(|| format!("load_group(seek): gid={}, after={:?}", gid, after))?;

            if first_page && page.is_empty() {
                // 首页即空：视为无成员（保持与旧语义一致，返回 None）
                return Ok(None);
            }
            first_page = false;

            if page.is_empty() {
                break; // 没有更多数据
            }

            out.extend(page);
            after = next;
        }

        Ok(Some(out))
    }

    /// 仅对差异做写入：
    /// - 新增：内存有、DB 无 -> INSERT (group_id, user_id, alias, role)
    /// - 删除：DB 有、内存无 -> DELETE
    /// - 变更：交集且 alias/role 任一不同 -> UPDATE alias=?, role=?
    ///
    /// 全过程在同一事务中执行。
    async fn save_group(&self, gid: GroupId, members: &[MemberRef]) -> Result<()> {
        let mut tx = self.pool().begin().await?;

        // --- 1) 读取 DB 当前视图 ---
        let db_rows = sqlx::query(
            r#"
            SELECT user_id, alias, role
            FROM group_member
            WHERE group_id = ?
            "#,
        )
            .bind(gid as u64)
            .fetch_all(&mut *tx)
            .await
            .with_context(|| format!("save_group(diff): fetch member members failed, group_id={}", gid))?;

        // DB -> HashMap<uid, (alias, role)>
        let mut db_map: HashMap<i64, (Option<String>, i32)> = HashMap::with_capacity(db_rows.len());
        for r in db_rows {
            let uid_u64: u64 = r.try_get("user_id")?;
            let alias_db: Option<String> = r.try_get("alias")?;
            let role_i64: i64 = r.try_get("role")?;
            let role_i32 = i32::try_from(role_i64)
                .with_context(|| format!("save_group(diff): member role overflow, v={}", role_i64))?;
            db_map.insert(uid_u64 as i64, (alias_db, role_i32));
        }

        // 内存 -> HashMap<uid, (alias, role)>（后写覆盖先写；空串 -> None）
        let mut mem_map: HashMap<i64, (Option<String>, i32)> = HashMap::with_capacity(members.len());
        for m in members {
            let alias_norm = m.alias.as_ref().and_then(|s| if s.is_empty() { None } else { Some(s.clone()) });
            mem_map.insert(m.id, (alias_norm, m.role));
        }

        // --- 2) 计算差异 ---
        let mut to_add: Vec<(i64, Option<String>, i32)> = Vec::new();
        let mut to_del: Vec<i64> = Vec::new();
        let mut to_upd: Vec<(i64, Option<String>, i32)> = Vec::new();

        for (&uid, (m_alias, m_role)) in mem_map.iter() {
            match db_map.get(&uid) {
                None => to_add.push((uid, m_alias.clone(), *m_role)),
                Some((d_alias, d_role)) => {
                    if d_alias != m_alias || d_role != m_role {
                        to_upd.push((uid, m_alias.clone(), *m_role));
                    }
                }
            }
        }
        for (&uid, _) in db_map.iter() {
            if !mem_map.contains_key(&uid) {
                to_del.push(uid);
            }
        }

        // --- 3) 执行差异写入（分批） ---
        // 3.1 删除
        for chunk in to_del.chunks(self.chunk_size) {
            if chunk.is_empty() { continue; }
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

        // 3.2 新增
        for chunk in to_add.chunks(self.chunk_size) {
            if chunk.is_empty() { continue; }
            let mut sql = String::from(
                "INSERT INTO group_member (group_id, user_id, alias, role) VALUES ",
            );
            sql.push_str(&vec!["(?,?,?,?)"; chunk.len()].join(","));

            let mut q = sqlx::query(&sql);
            for (uid, alias_opt, role) in chunk {
                q = q
                    .bind(gid as u64)
                    .bind(u64::try_from(*uid).unwrap_or_default())
                    .bind(alias_opt.as_ref()) // Option<&String> -> NULL/值
                    .bind(i64::from(*role));
            }
            let _res: MySqlQueryResult = q
                .execute(&mut *tx)
                .await
                .with_context(|| format!("save_group(diff): insert chunk failed, group_id={}", gid))?;
        }

        // 3.3 变更（alias/role）
        for chunk in to_upd.chunks(self.chunk_size) {
            if chunk.is_empty() { continue; }
            for (uid, alias_opt, role) in chunk {
                sqlx::query(
                    r#"
                    UPDATE group_member
                    SET alias = ?, role = ?
                    WHERE group_id = ? AND user_id = ?
                    "#,
                )
                    .bind(alias_opt.as_ref()) // Option<&String>
                    .bind(i64::from(*role))
                    .bind(gid as u64)
                    .bind(u64::try_from(*uid).unwrap_or_default())
                    .execute(&mut *tx)
                    .await
                    .with_context(|| {
                        format!(
                            "save_group(diff): update (alias/role) failed, group_id={}, user_id={}",
                            gid, uid
                        )
                    })?;
            }
        }

        // --- 4) 更新 meta（成员数与更新时间）
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
