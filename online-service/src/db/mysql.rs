use std::collections::HashMap;
use std::sync::Arc;

use anyhow::Result;
use prost_types::Timestamp;
use serde_json::Value as JsonValue;
use sqlx::{mysql::MySqlRow, MySql, Pool, Row, QueryBuilder};

use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use crate::grpc::client_service::ClientEntity;

// ---- 时间/行映射 ----
#[inline]
fn ts_from_parts(seconds: i64, micros: i64) -> Timestamp {
    Timestamp { seconds, nanos: (micros as i32) * 1_000 }
}
fn row_to_entity(row: &MySqlRow) -> Result<ClientEntity> {
    let id: i64 = row.try_get("id")?;
    let name: String = row.try_get("name")?;
    let language: Option<String> = row.try_get("language")?;
    let avatar: String = row.try_get("avatar")?;
    let allow_add_friend: i32 = row.try_get::<i8, _>("allow_add_friend")? as i32;
    let gender: i32 = row.try_get::<i8, _>("gender")? as i32;
    let user_type: i32 = row.try_get::<i8, _>("user_type")? as i32;

    let email_norm: Option<Vec<u8>> = row.try_get("email_norm").ok();
    let phone_norm: Option<Vec<u8>> = row.try_get("phone_norm").ok();

    let profile_fields: Option<JsonValue> = row.try_get("profile_fields").ok();
    let map = match profile_fields {
        Some(JsonValue::Object(obj)) => obj
            .into_iter()
            .filter_map(|(k, v)| v.as_str().map(|s| (k, s.to_owned())))
            .collect(),
        _ => Default::default(),
    };

    let ct_sec: i64 = row.try_get("ct_s")?;
    let ct_us: i64 = row.try_get("ct_us")?;
    let ut_sec: i64 = row.try_get("ut_s")?;
    let ut_us: i64 = row.try_get("ut_us")?;

    Ok(ClientEntity {
        id, name,
        email: email_norm.map(|b| String::from_utf8(b).unwrap_or_default()),
        phone: phone_norm.map(|b| String::from_utf8(b).unwrap_or_default()),
        language, avatar,
        allow_add_friend, gender, user_type,
        profile_fields: map,
        create_time: Some(ts_from_parts(ct_sec, ct_us)),
        update_time: Some(ts_from_parts(ut_sec, ut_us)),
    })
}
const SELECT_ENTITY_PROJECTION: &str = r#"
    id, name, language, avatar,
    allow_add_friend, gender, user_type,
    email_norm, phone_norm, profile_fields,
    UNIX_TIMESTAMP(created_at) AS ct_s,
    MICROSECOND(created_at)    AS ct_us,
    UNIX_TIMESTAMP(updated_at) AS ut_s,
    MICROSECOND(updated_at)    AS ut_us
"#;

// ---- Client 主表只读仓库（分片） ----
#[derive(Clone)]
pub struct ClientRepoSqlx {
    shards: Arc<[Pool<MySql>]>, // 与 client 分区对齐
}
impl ClientRepoSqlx {
    pub fn new(shard_pools: Vec<Pool<MySql>>) -> Self {
        assert!(!shard_pools.is_empty());
        Self { shards: shard_pools.into() }
    }
    #[inline] fn idx(&self, id: i64) -> usize {
        (id as u64 % self.shards.len() as u64) as usize
    }
    #[inline] fn pool_of(&self, id: i64) -> &Pool<MySql> {
        &self.shards[self.idx(id)]
    }
    #[inline]
    fn bucketize(&self, ids: &[i64]) -> HashMap<usize, Vec<i64>> {
        let mut b: HashMap<usize, Vec<i64>> = HashMap::with_capacity(self.shards.len());
        for &id in ids {
            b.entry(self.idx(id)).or_default().push(id);
        }
        b
    }
    pub fn shards(&self) -> &[Pool<MySql>] { &self.shards }
}
#[async_trait::async_trait]
impl ClientReadRepo for ClientRepoSqlx {
    async fn get_by_id(&self, id: i64) -> Result<Option<ClientEntity>> {
        let db = self.pool_of(id);
        let sql = format!("SELECT {} FROM client WHERE id = ? LIMIT 1", SELECT_ENTITY_PROJECTION);
        let opt = sqlx::query(&sql).bind(id).fetch_optional(db).await?;
        Ok(opt.map(|row| row_to_entity(&row)).transpose()?)
    }

    async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<ClientEntity>> {
        if ids.is_empty() {
            return Ok(vec![]);
        }

        let buckets = self.bucketize(ids);
        let mut out = Vec::with_capacity(ids.len());

        for (shard_idx, mut shard_ids) in buckets {
            if shard_ids.is_empty() {
                continue;
            }
            // 去重更稳妥（防止调用方传了重复 id）
            shard_ids.sort_unstable();
            shard_ids.dedup();

            let db = &self.shards[shard_idx];

            let mut qb = QueryBuilder::<MySql>::new("SELECT ");
            qb.push(SELECT_ENTITY_PROJECTION)
                .push(" FROM client WHERE id IN (");

            {
                // 不需要 finalize()；离开作用域自动“收尾”
                let mut sep = qb.separated(", ");
                for id in shard_ids {
                    sep.push_bind(id);
                }
            }

            qb.push(")");

            let rows = qb.build().fetch_all(db).await?;
            for row in rows {
                out.push(row_to_entity(&row)?);
            }
        }

        Ok(out)
    }

    async fn exists(&self, id: i64) -> Result<bool> {
        let db = self.pool_of(id);
        let some = sqlx::query_scalar::<_, i64>("SELECT 1 FROM client WHERE id = ? LIMIT 1")
            .bind(id)
            .fetch_optional(db)
            .await?
            .is_some();
        Ok(some)
    }

    async fn get_version(&self, id: i64) -> Result<Option<i32>> {
        let db = self.pool_of(id);
        let ver = sqlx::query_scalar::<_, i32>("SELECT version FROM client WHERE id = ? LIMIT 1")
            .bind(id)
            .fetch_optional(db)
            .await?;
        Ok(ver)
    }
}

// ---- Directory 只读仓库：email/phone/name -> id（单条命中） ----
#[derive(Clone)]
pub struct DirectoryRepoSqlx { dir: Pool<MySql> }
impl DirectoryRepoSqlx { pub fn new(dir_pool: Pool<MySql>) -> Self { Self { dir: dir_pool } } }

#[async_trait::async_trait]
impl DirectoryReadRepo for DirectoryRepoSqlx {
    async fn get_id_by_email(&self, email_norm: &[u8]) -> Result<Option<i64>> {
        let row = sqlx::query(r#"SELECT id FROM uid_email WHERE email_norm = ? AND state = 1 LIMIT 1"#)
            .bind(email_norm)
            .fetch_optional(&self.dir)
            .await?;
        Ok(row.map(|r| r.try_get::<i64, _>("id").unwrap()))
    }
    async fn get_id_by_phone(&self, phone_norm: &[u8]) -> Result<Option<i64>> {
        let row = sqlx::query(r#"SELECT id FROM uid_phone WHERE phone_norm = ? AND state = 1 LIMIT 1"#)
            .bind(phone_norm)
            .fetch_optional(&self.dir)
            .await?;
        Ok(row.map(|r| r.try_get::<i64, _>("id").unwrap()))
    }
    async fn get_id_by_name(&self, username_norm: &str) -> Result<Option<i64>> {
        let row = sqlx::query(r#"SELECT id FROM uid_name WHERE name_norm = ? LIMIT 1"#)
            .bind(username_norm)
            .fetch_optional(&self.dir)
            .await?;
        Ok(row.map(|r| r.try_get::<i64, _>("id").unwrap()))
    }
}

// ---- 构建便捷函数（可选） ----
pub async fn build_client_repo_from_dsns(dsns: &[&str]) -> Result<ClientRepoSqlx> {
    let mut shards = Vec::with_capacity(dsns.len());
    for dsn in dsns { shards.push(Pool::<MySql>::connect(dsn).await?); }
    Ok(ClientRepoSqlx::new(shards))
}
pub async fn build_directory_repo_from_dsn(dir_dsn: &str) -> Result<DirectoryRepoSqlx> {
    Ok(DirectoryRepoSqlx::new(Pool::<MySql>::connect(dir_dsn).await?))
}
