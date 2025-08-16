// online-service/src/db/mysql.rs
//
// 与 proto3 定义完全对齐（int64 create_time/update_time + int32 version）
// 健壮性：无 unwrap；? + anyhow::Context；fetch_optional 区分未命中/失败；空入参短路
// 性能：get_by_ids 跨分片并发（buffer_unordered）+ IN 分批（默认 2000）
//
// 若物理表时间列是 DATETIME(6)/TIMESTAMP(6)，请改用文内注释的 UNIX_TIMESTAMP 方案。

use std::collections::HashMap;
use std::sync::Arc;

use anyhow::{Context, Result};
use futures::{StreamExt, TryStreamExt};
use serde_json::Value as JsonValue;
use sqlx::{mysql::MySqlRow, MySql, Pool, Row, QueryBuilder};

use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use crate::grpc::client_service::ClientEntity;

// ====================== 行映射 ======================

fn row_to_entity(r: &MySqlRow) -> Result<ClientEntity> {
    let id: i64 = r.try_get("id").context("missing 'id'")?;
    let name: String = r.try_get("name").context("missing 'name'")?;
    let email: Option<String> = r.try_get("email").ok();
    let phone: Option<String> = r.try_get("phone").ok();
    let language: Option<String> = r.try_get("language").ok();
    let avatar: String = r.try_get("avatar").context("missing 'avatar'")?;
    let allow_add_friend: i32 = r.try_get("allow_add_friend").context("missing 'allow_add_friend'")?;
    let gender: i32 = r.try_get("gender").context("missing 'gender'")?;
    let user_type: i32 = r.try_get("user_type").context("missing 'user_type'")?;

    // JSON 映射（非对象/解析失败 -> 空 Map，并带上下文）
    let profile_fields: HashMap<String, String> = match r.try_get::<String, _>("profile_fields").ok() {
        None => HashMap::new(),
        Some(s) if s.is_empty() => HashMap::new(),
        Some(s) => {
            let v: JsonValue = serde_json::from_str(&s)
                .with_context(|| format!("invalid JSON in 'profile_fields': {}", s))?;
            match v {
                JsonValue::Object(map) => map
                    .into_iter()
                    .map(|(k, v)| (k, v.as_str().unwrap_or(&v.to_string()).to_string()))
                    .collect(),
                _ => HashMap::new(),
            }
        }
    };

    // 时间：int64 秒（与 proto 一致）
    let create_time: i64 = r.try_get("create_time").context("missing 'create_time' (int64)")?;
    let update_time: i64 = r.try_get("update_time").context("missing 'update_time' (int64)")?;

    // 版本（乐观锁）
    let version: i32 = r.try_get("version").context("missing 'version'")?;

    Ok(ClientEntity {
        id,
        name,
        email,
        phone,
        language,
        avatar,
        allow_add_friend,
        gender,
        user_type,
        profile_fields,
        create_time,
        update_time,
        version,
    })
}

// 统一投影，避免列名漂移；确保与 row_to_entity 字段一致。
// 如果物理列为 DATETIME(6)，可把 create_time/update_time 改为：
//   UNIX_TIMESTAMP(create_time) AS create_time, UNIX_TIMESTAMP(update_time) AS update_time
const SELECT_ENTITY_PROJECTION: &str = "\
    id, \
    name, \
    email, \
    phone, \
    language, \
    avatar, \
    allow_add_friend, \
    gender, \
    user_type, \
    profile_fields, \
    create_time, \
    update_time, \
    version \
";

// ====================== Client 主表只读仓库（分片） ======================
#[derive(Clone)]
pub struct ClientRepoSqlx {
    shards: Arc<[Pool<MySql>]>,
}

impl ClientRepoSqlx {
    pub fn new<P: Into<Vec<Pool<MySql>>>>(pools: P) -> Self {
        let pools = pools.into();
        assert!(!pools.is_empty(), "ClientRepoSqlx requires at least one shard pool");
        Self { shards: Arc::from(pools.into_boxed_slice()) }
    }

    #[inline]
    fn shard_idx(&self, id: i64) -> usize {
        let n = self.shards.len() as i64;
        let m = if id >= 0 { id % n } else { (id % n + n) % n };
        m as usize
    }

    #[inline]
    fn pool_by_id(&self, id: i64) -> &Pool<MySql> {
        &self.shards[self.shard_idx(id)]
    }
}

#[async_trait::async_trait]
impl ClientReadRepo for ClientRepoSqlx {
    async fn get_by_id(&self, id: i64) -> Result<Option<ClientEntity>> {
        let db = self.pool_by_id(id);
        let sql = format!("SELECT {} FROM client WHERE id = ? LIMIT 1", SELECT_ENTITY_PROJECTION);

        // 若 DATETIME(6) 存储，请改成上方注释形式（UNIX_TIMESTAMP(...) AS create_time,...）
        let row_opt = sqlx::query(&sql)
            .bind(id)
            .fetch_optional(db)
            .await
            .context("DB query failed in get_by_id")?;

        match row_opt {
            Some(row) => row_to_entity(&row).map(Some),
            None => Ok(None),
        }
    }

    async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<ClientEntity>> {
        if ids.is_empty() {
            return Ok(Vec::new());
        }

        // 按分片归桶
        let mut buckets: HashMap<usize, Vec<i64>> = HashMap::new();
        for &id in ids {
            buckets.entry(self.shard_idx(id)).or_default().push(id);
        }

        let shard_count = self.shards.len();
        let futs = buckets.into_iter().map(|(idx, mut shard_ids)| async move {
            let db = &self.shards[idx];
            let mut out = Vec::new();

            shard_ids.sort_unstable();
            shard_ids.dedup();

            const CHUNK: usize = 2000;
            for chunk in shard_ids.chunks(CHUNK) {
                let mut qb = QueryBuilder::<MySql>::new(&format!(
                    "SELECT {} FROM client WHERE id IN (",
                    SELECT_ENTITY_PROJECTION
                ));
                {
                    let mut sep = qb.separated(", ");
                    for id in chunk {
                        sep.push_bind(id);
                    }
                }
                qb.push(")");

                let rows = qb
                    .build()
                    .fetch_all(db)
                    .await
                    .with_context(|| format!("DB query failed in get_by_ids (shard={idx})"))?;

                for row in rows {
                    let ent = row_to_entity(&row).context("row_to_entity failed in get_by_ids")?;
                    out.push(ent);
                }
            }

            Ok::<Vec<ClientEntity>, anyhow::Error>(out)
        });

        let results: Vec<Vec<ClientEntity>> = futures::stream::iter(futs)
            .buffer_unordered(shard_count) // 并发度=分片数（可按池大小调优）
            .try_collect()
            .await
            .context("concurrent shard fetch failed in get_by_ids")?;

        Ok(results.into_iter().flatten().collect())
    }

    async fn exists(&self, id: i64) -> Result<bool> {
        let db = self.pool_by_id(id);
        let row_opt = sqlx::query("SELECT 1 FROM client WHERE id = ? LIMIT 1")
            .bind(id)
            .fetch_optional(db)
            .await
            .context("DB query failed in exists")?;
        Ok(row_opt.is_some())
    }

    async fn get_version(&self, id: i64) -> Result<Option<i32>> {
        let db = self.pool_by_id(id);
        let row_opt = sqlx::query("SELECT version FROM client WHERE id = ? LIMIT 1")
            .bind(id)
            .fetch_optional(db)
            .await
            .context("DB query failed in get_version")?;
        row_opt
            .map(|r| r.try_get::<i32, _>("version"))
            .transpose()
            .context("missing/invalid 'version' column in get_version")
    }
}

// ====================== Directory 只读仓库（全局） ======================
#[derive(Clone)]
pub struct DirectoryRepoSqlx {
    pool: Pool<MySql>,
}

impl DirectoryRepoSqlx {
    pub fn new(pool: Pool<MySql>) -> Self { Self { pool } }

    #[inline]
    async fn get_id_by_key(&self, sql: &str, param: &[u8], label: &'static str) -> Result<Option<i64>> {
        if param.is_empty() {
            return Ok(None);
        }
        let row_opt = sqlx::query(sql)
            .bind(param)
            .fetch_optional(&self.pool)
            .await
            .with_context(|| format!("DB query failed in {label}"))?;
        row_opt
            .map(|r| r.try_get::<i64, _>("id"))
            .transpose()
            .with_context(|| format!("missing/invalid 'id' column in {label}"))
    }
}

#[async_trait::async_trait]
impl DirectoryReadRepo for DirectoryRepoSqlx {
    async fn get_id_by_email(&self, email_norm: &[u8]) -> Result<Option<i64>> {
        self.get_id_by_key(
            "SELECT id FROM directory WHERE email_norm = ? AND state = 1 LIMIT 1",
            email_norm,
            "get_id_by_email",
        ).await
    }

    async fn get_id_by_phone(&self, phone_norm: &[u8]) -> Result<Option<i64>> {
        self.get_id_by_key(
            "SELECT id FROM directory WHERE phone_norm = ? AND state = 1 LIMIT 1",
            phone_norm,
            "get_id_by_phone",
        ).await
    }

    async fn get_id_by_name(&self, username_norm: &str) -> Result<Option<i64>> {
        if username_norm.is_empty() {
            return Ok(None);
        }
        let row_opt = sqlx::query("SELECT id FROM directory WHERE name_norm = ? AND state = 1 LIMIT 1")
            .bind(username_norm)
            .fetch_optional(&self.pool)
            .await
            .context("DB query failed in get_id_by_name")?;
        row_opt
            .map(|r| r.try_get::<i64, _>("id"))
            .transpose()
            .context("missing/invalid 'id' column in get_id_by_name")
    }
}

// ====================== Builder 便捷函数 ======================

pub async fn build_client_repo_from_dsns(dsns: &[&str]) -> Result<ClientRepoSqlx> {
    anyhow::ensure!(!dsns.is_empty(), "at least one DSN is required");
    let mut shards = Vec::with_capacity(dsns.len());
    for dsn in dsns {
        let pool = Pool::<MySql>::connect(dsn)
            .await
            .with_context(|| format!("failed to connect MySQL pool for DSN '{}'", dsn))?;
        shards.push(pool);
    }
    Ok(ClientRepoSqlx::new(shards))
}

pub async fn build_directory_repo_from_dsn(dir_dsn: &str) -> Result<DirectoryRepoSqlx> {
    let pool = Pool::<MySql>::connect(dir_dsn)
        .await
        .with_context(|| format!("failed to connect MySQL pool for DSN '{}'", dir_dsn))?;
    Ok(DirectoryRepoSqlx::new(pool))
}
