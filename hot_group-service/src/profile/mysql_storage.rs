use super::storage::GroupProfileStorage;
use crate::profile::model::GroupEntity;
use anyhow::Result;
use async_trait::async_trait;
use common::config::get_db;
use sqlx::{Executor, Row};

/// 基于 sqlx::MySql 的群资料存储（写穿 + 可选CAS）
#[derive(Clone)]
pub struct MySqlGroupProfileStore {
}

impl MySqlGroupProfileStore {
    #[inline]
    pub fn new() -> Self {
        Self {
        }
    }
}

#[async_trait]
impl GroupProfileStorage for MySqlGroupProfileStore {
    async fn load_group_info(&self, gid: i64) -> Result<Option<GroupEntity>> {
        let pool = get_db();
        let rec = sqlx::query(
            r#"
            SELECT id, name, avatar, description, notice, join_permission, owner_id, group_type,
                   allow_search, enable, create_time, update_time
              FROM group_info
             WHERE id = ?
            "#,
        )
            .bind(gid as u64)
            .fetch_optional(&*pool)
            .await?;

        Ok(rec.map(|r| GroupEntity {
            id:             r.try_get::<u64, _>("id").unwrap_or_default() as i64,
            name:           r.try_get::<String, _>("name").unwrap_or_default(),
            avatar:         r.try_get::<String, _>("avatar").unwrap_or_default(),
            description:    r.try_get::<String, _>("description").unwrap_or_default(),
            notice:         r.try_get::<String, _>("notice").unwrap_or_default(),
            join_permission:r.try_get::<i32, _>("join_permission").unwrap_or(0),
            owner_id:       r.try_get::<u64, _>("owner_id").unwrap_or_default() as i64,
            group_type:     r.try_get::<i32, _>("group_type").unwrap_or(0),
            allow_search:   r.try_get::<bool, _>("allow_search").unwrap_or(true),
            enable:         r.try_get::<bool, _>("enable").unwrap_or(true),
            create_time:    r.try_get::<u64, _>("create_time").unwrap_or_default(),
            update_time:    r.try_get::<u64, _>("update_time").unwrap_or_default(),
        }))
    }

    async fn save_group_info(
        &self,
        e: &GroupEntity,
        expected_update_time: Option<u64>,
    ) -> Result<bool> {
        let pool = get_db();

        match expected_update_time {
            // CAS 更新
            Some(expect) => {
                let res = sqlx::query(
                    r#"
                    UPDATE group_info
                       SET name=?, avatar=?, description=?, notice=?, join_permission=?,
                           owner_id=?, group_type=?, allow_search=?, enable=?, update_time=?
                     WHERE id=? AND update_time=?
                    "#,
                )
                    .bind(&e.name)
                    .bind(&e.avatar)
                    .bind(&e.description)
                    .bind(&e.notice)
                    .bind(e.join_permission)
                    .bind(e.owner_id as u64)
                    .bind(e.group_type)
                    .bind(e.allow_search)
                    .bind(e.enable)
                    .bind(e.update_time)
                    .bind(e.id as u64)
                    .bind(expect)
                    .execute(&*pool)
                    .await?;
                Ok(res.rows_affected() == 1)
            }
            // Upsert
            None => {
                sqlx::query(
                    r#"
                    INSERT INTO group_info
                      (id,name,avatar,description,notice,join_permission,owner_id,group_type,
                       allow_search,enable,create_time,update_time)
                    VALUES
                      (?,?,?,?,?, ?,?,?, ?,?, ?,?)
                    ON DUPLICATE KEY UPDATE
                      name=VALUES(name),
                      avatar=VALUES(avatar),
                      description=VALUES(description),
                      notice=VALUES(notice),
                      join_permission=VALUES(join_permission),
                      owner_id=VALUES(owner_id),
                      group_type=VALUES(group_type),
                      allow_search=VALUES(allow_search),
                      enable=VALUES(enable),
                      update_time=VALUES(update_time)
                    "#,
                )
                    .bind(e.id as u64)
                    .bind(&e.name)
                    .bind(&e.avatar)
                    .bind(&e.description)
                    .bind(&e.notice)
                    .bind(e.join_permission)
                    .bind(e.owner_id as u64)
                    .bind(e.group_type)
                    .bind(e.allow_search)
                    .bind(e.enable)
                    .bind(e.create_time)
                    .bind(e.update_time)
                    .execute(&*pool)
                    .await?;
                Ok(true)
            }
        }
    }

    async fn delete_group_info(&self, gid: i64) -> Result<()> {
        let pool = get_db();
        sqlx::query("DELETE FROM group_info WHERE id=?")
            .bind(gid as u64)
            .execute(&*pool)
            .await?;
        Ok(())
    }
}