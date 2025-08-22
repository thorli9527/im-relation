// hot_online_service/src/member/mysql.rs
//
// 目标：
// - 与 proto 对齐：ClientEntity 的时间为 i64（秒），version 为 i32
// - 健壮性：无 unwrap/expect；错误链路 .context(...)；空入参快速返回
// - 性能：get_by_ids 分批 IN + 并发；目录查询走 uid_email/uid_phone/uid_name 且 state=1
// - 兼容：client.created_at/updated_at 为 DATETIME(3)，查询时用 UNIX_TIMESTAMP 转 i64 秒
//
// DDL 假设：
//   client(id, ..., email_norm VARBINARY, phone_norm VARBINARY, profile_fields JSON,
//          created_at DATETIME(3), updated_at DATETIME(3), version INT, ...)
//   uid_email(email VARBINARY(255) PK, id BIGINT, state TINYINT, ...)
//   uid_phone(phone VARBINARY(32)  PK, id BIGINT, state TINYINT, ...)
//   uid_name (name  VARCHAR(64)    PK, id BIGINT, state TINYINT, ...)

use std::collections::HashMap;
use std::sync::Arc;

use anyhow::{Context, Result};
use futures::{StreamExt, TryStreamExt};
use serde_json::Value as JsonValue;
use sqlx::{mysql::MySqlRow, MySql, Pool, QueryBuilder, Row};

// 全局数据库连接池
use common::config::get_db;

use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use crate::grpc::client_service::ClientEntity;

// ====================== 行 -> 结构体 映射 ======================

/// 将一行 client 映射到 ClientEntity。
/// 预期 SELECT 投影见 SELECT_ENTITY_PROJECTION 常量。
fn row_to_entity(r: &MySqlRow) -> Result<ClientEntity> {
    let id: i64 = r.try_get("id").context("missing 'id'")?;
    let name: String = r.try_get("name").context("missing 'name'")?;

    let language: Option<String> = r.try_get("language").ok();
    let avatar: String = r.try_get("avatar").context("missing 'avatar'")?;

    // TINYINT/SMALLINT 兼容为 i32
    let allow_add_friend: i32 = r
        .try_get::<i32, _>("allow_add_friend")
        .or_else(|_| r.try_get::<i16, _>("allow_add_friend").map(|v| v as i32))
        .context("missing 'allow_add_friend'")?;
    let gender: i32 = r
        .try_get::<i32, _>("gender")
        .or_else(|_| r.try_get::<i16, _>("gender").map(|v| v as i32))
        .context("missing 'gender'")?;
    let user_type: i32 = r
        .try_get::<i32, _>("user_type")
        .or_else(|_| r.try_get::<i16, _>("user_type").map(|v| v as i32))
        .context("missing 'user_type'")?;

    // email_norm / phone_norm 为 VARBINARY；仅含 ASCII，按 UTF-8 尝试转 String，失败则视为 None
    let email: Option<String> = match r.try_get::<Vec<u8>, _>("email_norm").ok() {
        Some(bytes) if !bytes.is_empty() => String::from_utf8(bytes).ok(),
        _ => None,
    };
    let phone: Option<String> = match r.try_get::<Vec<u8>, _>("phone_norm").ok() {
        Some(bytes) if !bytes.is_empty() => String::from_utf8(bytes).ok(),
        _ => None,
    };

    // JSON -> map<string,string>；非对象/解析失败 -> 空 Map（避免 E0515）
    let profile_fields: HashMap<String, String> =
        match r.try_get::<JsonValue, _>("profile_fields").ok() {
            Some(JsonValue::Object(map)) => map
                .into_iter()
                .map(|(k, v)| {
                    let s = match v {
                        JsonValue::String(s) => s,
                        other => other.to_string(),
                    };
                    (k, s)
                })
                .collect(),
            _ => HashMap::new(),
        };

    // 秒级时间戳（UNIX_TIMESTAMP(...) 已在投影里转换）
    let create_time: i64 = r.try_get("create_time").context("missing 'create_time'")?;
    let update_time: i64 = r.try_get("update_time").context("missing 'update_time'")?;

    let version: i32 = r
        .try_get::<i32, _>("version")
        .or_else(|_| r.try_get::<i16, _>("version").map(|v| v as i32))
        .context("missing 'version'")?;

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

/// 与 row_to_entity 对齐的统一投影；将 DATETIME(3) 转为 i64 秒。
const SELECT_ENTITY_PROJECTION: &str = r#"
    id,
    name,
    language,
    avatar,
    allow_add_friend,
    gender,
    user_type,
    email_norm,
    phone_norm,
    profile_fields,
    CAST(UNIX_TIMESTAMP(created_at) AS SIGNED) AS create_time,
    CAST(UNIX_TIMESTAMP(updated_at) AS SIGNED) AS update_time,
    version
"#;

// ====================== Client 主表只读仓库（单库/分区） ======================

#[derive(Clone)]
pub struct ClientRepoSqlx {
    pool: Arc<Pool<MySql>>,
}

impl ClientRepoSqlx {
    /// 使用全局 get_db() 获取池
    pub fn new() -> Self {
        Self { pool: get_db() }
    }

    // 将单批 ids（拥有所有权）查询出来；用于并发分批。
    async fn fetch_chunk(pool: Arc<Pool<MySql>>, ids_vec: Vec<i64>) -> Result<Vec<ClientEntity>> {
        if ids_vec.is_empty() {
            return Ok(Vec::new());
        }

        let mut qb = QueryBuilder::<MySql>::new(format!(
            "SELECT {} FROM client WHERE id IN (",
            SELECT_ENTITY_PROJECTION
        ));
        {
            let mut sep = qb.separated(", ");
            for id in &ids_vec {
                sep.push_bind(id);
            }
        }
        qb.push(")");

        let rows = qb
            .build()
            .fetch_all(&*pool)
            .await
            .context("DB query failed in get_by_ids chunk")?;

        let mut out = Vec::with_capacity(rows.len());
        for row in rows {
            let ent = row_to_entity(&row).context("row_to_entity failed in get_by_ids")?;
            out.push(ent);
        }
        Ok(out)
    }
}

#[async_trait::async_trait]
impl ClientReadRepo for ClientRepoSqlx {
    async fn get_by_id(&self, id: i64) -> Result<Option<ClientEntity>> {
        let sql = format!(
            "SELECT {} FROM client WHERE id = ? LIMIT 1",
            SELECT_ENTITY_PROJECTION
        );
        let row_opt = sqlx::query(&sql)
            .bind(id)
            .fetch_optional(&*self.pool)
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

        // 去重
        let mut uniq = ids.to_vec();
        uniq.sort_unstable();
        uniq.dedup();

        // 分批 + 并发
        const CHUNK: usize = 2000;
        let mut futs = Vec::with_capacity((uniq.len() + CHUNK - 1) / CHUNK);
        for chunk in uniq.chunks(CHUNK) {
            let ids_vec = chunk.to_vec(); // 拥有所有权，避免 HRTB 限制
            let pool = self.pool.clone();
            futs.push(Self::fetch_chunk(pool, ids_vec));
        }

        let lists: Vec<Vec<ClientEntity>> = futures::stream::iter(futs)
            .buffer_unordered(8) // 并发度按连接池/DB 压力调优
            .try_collect()
            .await
            .context("concurrent chunk fetch failed in get_by_ids")?;

        Ok(lists.into_iter().flatten().collect())
    }

    async fn exists(&self, id: i64) -> Result<bool> {
        let row_opt = sqlx::query("SELECT 1 FROM client WHERE id = ? LIMIT 1")
            .bind(id)
            .fetch_optional(&*self.pool)
            .await
            .context("DB query failed in exists")?;
        Ok(row_opt.is_some())
    }

    async fn get_version(&self, id: i64) -> Result<Option<i32>> {
        let row_opt = sqlx::query("SELECT version FROM client WHERE id = ? LIMIT 1")
            .bind(id)
            .fetch_optional(&*self.pool)
            .await
            .context("DB query failed in get_version")?;
        row_opt
            .map(|r| {
                r.try_get::<i32, _>("version")
                    .or_else(|_| r.try_get::<i16, _>("version").map(|v| v as i32))
            })
            .transpose()
            .context("missing/invalid 'version' column in get_version")
    }
}

// ====================== Directory 只读仓库（uid_*） ======================

#[derive(Clone)]
pub struct DirectoryRepoSqlx {
    pool: Arc<Pool<MySql>>,
}

impl DirectoryRepoSqlx {
    /// 使用全局 get_db() 获取池
    pub fn new() -> Self {
        Self { pool: get_db() }
    }

    /// 通用查询：按给定 SQL 和参数获取 id（state=1 过滤在 SQL 中写明）
    /// 使用 HRTB：for<'q> Encode<'q, MySql>，以支持 &str / &[u8] / String / Vec<u8> 等。
    #[inline]
    async fn get_id_by_key<T>(&self, sql: &str, param: T, label: &'static str) -> Result<Option<i64>>
    where
        T: Send + for<'q> sqlx::Encode<'q, MySql> + sqlx::Type<MySql>,
    {
        let row_opt = sqlx::query(sql)
            .bind(param)
            .fetch_optional(&*self.pool)
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
        if email_norm.is_empty() {
            return Ok(None);
        }
        self.get_id_by_key(
            "SELECT id FROM uid_email WHERE email = ? AND state = 1 LIMIT 1",
            email_norm,
            "get_id_by_email",
        )
            .await
    }

    async fn get_id_by_phone(&self, phone_norm: &[u8]) -> Result<Option<i64>> {
        if phone_norm.is_empty() {
            return Ok(None);
        }
        self.get_id_by_key(
            "SELECT id FROM uid_phone WHERE phone = ? AND state = 1 LIMIT 1",
            phone_norm,
            "get_id_by_phone",
        )
            .await
    }

    async fn get_id_by_name(&self, name_norm: &str) -> Result<Option<i64>> {
        if name_norm.is_empty() {
            return Ok(None);
        }
        self.get_id_by_key(
            "SELECT id FROM uid_name WHERE name = ? AND state = 1 LIMIT 1",
            name_norm,
            "get_id_by_name",
        )
            .await
    }
}

// ====================== 便捷构造（可选） ======================
// 若外部代码希望保留 Builder 风格，这里提供无参构造包装。

pub fn build_client_repo() -> ClientRepoSqlx {
    ClientRepoSqlx::new()
}

pub fn build_directory_repo() -> DirectoryRepoSqlx {
    DirectoryRepoSqlx::new()
}
