// user_service/src/member/mysql.rs
//
// 目标：
// - 与 proto 对齐：UserEntity 的时间为 i64（秒），version 为 i32
// - 健壮性：无 unwrap/expect；错误链路 .context(...)；空入参快速返回
// - 性能：get_by_ids 分批 IN + 并发；目录查询走 uid_email/uid_phone/uid_name 且 state=1
// - 兼容：user.created_at/updated_at 为 DATETIME(3)，查询时用 UNIX_TIMESTAMP 转 i64 秒
//
// DDL 假设：
//   user_info(id, ..., email_norm VARBINARY, phone_norm VARBINARY, profile_fields JSON,
//          created_at DATETIME(3), updated_at DATETIME(3), version INT, ...)
//   uid_email(email VARBINARY(255) PK, id BIGINT, state TINYINT, ...)
//   uid_phone(phone VARBINARY(32)  PK, id BIGINT, state TINYINT, ...)
//   uid_name (name  VARCHAR(64)    PK, id BIGINT, state TINYINT, ...)

use std::collections::HashMap;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use futures::{StreamExt, TryStreamExt};
use rand::RngCore;
use serde_json::Value as JsonValue;
use sqlx::types::time::PrimitiveDateTime;
use sqlx::{mysql::MySqlRow, MySql, Pool, QueryBuilder, Row};
use std::convert::TryFrom;
use time::format_description::FormatItem;
use time::macros::format_description;
use time::{Duration as TimeDuration, OffsetDateTime};

// 全局数据库连接池
use common::config::get_db;

use crate::db::traits::{
    ClientReadRepo, DirectoryReadRepo, SessionTokenRecord, SessionTokenRepo, SessionTokenUpsert,
    SessionTokenUpsertResult,
};
use common::infra::grpc::grpc_user::online_service::{DeviceType, UserEntity};

const MYSQL_TS_FORMAT: &[FormatItem<'static>] =
    format_description!("[year]-[month]-[day] [hour]:[minute]:[second].[subsecond digits:3]");

// ====================== 行 -> 结构体 映射 ======================

/// 将一行 user 映射到 UserEntity。
/// 预期 SELECT 投影见 SELECT_ENTITY_PROJECTION 常量。
fn row_to_entity(r: &MySqlRow) -> Result<UserEntity> {
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
    let password = r.try_get("password").context("missing 'password'")?;
    // 秒级时间戳（UNIX_TIMESTAMP(...) 已在投影里转换）
    let create_time: i64 = r.try_get("create_time").context("missing 'create_time'")?;
    let update_time: i64 = r.try_get("update_time").context("missing 'update_time'")?;

    let version: i32 = r
        .try_get::<i32, _>("version")
        .or_else(|_| r.try_get::<i16, _>("version").map(|v| v as i32))
        .context("missing 'version'")?;
    let profile_version: i64 = r
        .try_get::<i64, _>("profile_version")
        .context("missing 'profile_version'")?;

    Ok(UserEntity {
        id,
        password,
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
        profile_version,
    })
}

/// 与 row_to_entity 对齐的统一投影；将 DATETIME(3) 转为 i64 秒。
const SELECT_ENTITY_PROJECTION: &str = r#"
    id,
    password,
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
    version,
    profile_version
"#;

// ====================== Client 主表只读仓库（单库/分区） ======================

#[derive(Clone)]
pub struct UserRepoSqlx {
    pool: Arc<Pool<MySql>>,
}

impl UserRepoSqlx {
    /// 使用全局 get_db() 获取池
    pub fn new() -> Self {
        Self { pool: get_db() }
    }

    // 将单批 ids（拥有所有权）查询出来；用于并发分批。
    async fn fetch_chunk(pool: Arc<Pool<MySql>>, ids_vec: Vec<i64>) -> Result<Vec<UserEntity>> {
        if ids_vec.is_empty() {
            return Ok(Vec::new());
        }

        let mut qb = QueryBuilder::<MySql>::new(format!(
            "SELECT {} FROM user_info WHERE id IN (",
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
impl ClientReadRepo for UserRepoSqlx {
    async fn get_by_id(&self, id: i64) -> Result<Option<UserEntity>> {
        let sql = format!(
            "SELECT {} FROM user_info WHERE id = ? LIMIT 1",
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

    async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<UserEntity>> {
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

        let lists: Vec<Vec<UserEntity>> = futures::stream::iter(futs)
            .buffer_unordered(8) // 并发度按连接池/DB 压力调优
            .try_collect()
            .await
            .context("concurrent chunk fetch failed in get_by_ids")?;

        Ok(lists.into_iter().flatten().collect())
    }

    async fn exists(&self, id: i64) -> Result<bool> {
        let row_opt = sqlx::query("SELECT 1 FROM user_info WHERE id = ? LIMIT 1")
            .bind(id)
            .fetch_optional(&*self.pool)
            .await
            .context("DB query failed in exists")?;
        Ok(row_opt.is_some())
    }

    async fn get_version(&self, id: i64) -> Result<Option<i32>> {
        let row_opt = sqlx::query("SELECT version FROM user_info WHERE id = ? LIMIT 1")
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
    async fn get_id_by_key<T>(
        &self,
        sql: &str,
        param: T,
        label: &'static str,
    ) -> Result<Option<i64>>
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

pub fn build_user_repo() -> UserRepoSqlx {
    UserRepoSqlx::new()
}

pub fn build_directory_repo() -> DirectoryRepoSqlx {
    DirectoryRepoSqlx::new()
}

#[derive(Clone)]
pub struct SessionRepoSqlx {
    pool: Pool<MySql>,
}

impl SessionRepoSqlx {
    pub fn new() -> Self {
        Self {
            pool: get_db().as_ref().clone(),
        }
    }
}

fn generate_session_token() -> String {
    let mut buf = [0u8; 32];
    let mut rng = rand::rng();
    rng.fill_bytes(&mut buf);
    hex::encode(buf)
}

fn map_device_type(value: i32) -> DeviceType {
    DeviceType::try_from(value).unwrap_or(DeviceType::Unknown)
}

#[async_trait::async_trait]
impl SessionTokenRepo for SessionRepoSqlx {
    async fn upsert_session_token(
        &self,
        payload: SessionTokenUpsert,
    ) -> Result<SessionTokenUpsertResult> {
        let SessionTokenUpsert {
            user_id,
            device_type,
            device_id,
            login_ip,
            user_agent,
        } = payload;

        let mut tx = self.pool.begin().await?;
        let existing = sqlx::query(
            r#"
                SELECT session_token
                FROM user_session
                WHERE user_id = ? AND device_type = ? AND device_id = ?
                FOR UPDATE
            "#,
        )
        .bind(user_id)
        .bind(device_type as i32)
        .bind(&device_id)
        .fetch_optional(&mut *tx)
        .await?;

        let previous_token = existing
            .and_then(|row| row.try_get::<Vec<u8>, _>("session_token").ok())
            .and_then(|bytes| String::from_utf8(bytes).ok());

        let new_token = generate_session_token();
        let expires_at = OffsetDateTime::now_utc() + TimeDuration::days(15);
        let expires_at_str = expires_at
            .format(&MYSQL_TS_FORMAT)
            .map_err(|e| anyhow!(e))?;

        sqlx::query(
            r#"
                INSERT INTO user_session
                    (user_id, device_type, device_id, session_token, status,
                     issued_at, expires_at, last_seen_at, login_ip, login_user_agent)
                VALUES
                    (?, ?, ?, ?, 1, NOW(3), ?, NOW(3), ?, ?)
                ON DUPLICATE KEY UPDATE
                    session_token = VALUES(session_token),
                    status = 1,
                    issued_at = NOW(3),
                    expires_at = VALUES(expires_at),
                    last_seen_at = NOW(3),
                    login_ip = VALUES(login_ip),
                    login_user_agent = VALUES(login_user_agent)
            "#,
        )
        .bind(user_id)
        .bind(device_type as i32)
        .bind(&device_id)
        .bind(new_token.as_bytes())
        .bind(&expires_at_str)
        .bind(login_ip)
        .bind(user_agent)
        .execute(&mut *tx)
        .await?;

        tx.commit().await?;

        Ok(SessionTokenUpsertResult {
            session_token: new_token,
            expires_at,
            previous_token,
        })
    }

    async fn validate_session_token(&self, token: &str) -> Result<Option<SessionTokenRecord>> {
        let row = sqlx::query(
            r#"
                SELECT user_id, device_type, device_id, status, expires_at, last_seen_at
                FROM user_session
                WHERE session_token = ?
            "#,
        )
        .bind(token.as_bytes())
        .fetch_optional(&self.pool)
        .await?;

        let Some(row) = row else {
            return Ok(None);
        };

        let user_id: i64 = row.try_get("user_id")?;
        let device_type_val: i32 = row.try_get("device_type")?;
        let device_id: String = row.try_get("device_id")?;
        let mut status: i32 = row.try_get("status")?;
        let expires_at_pd: PrimitiveDateTime = row.try_get("expires_at")?;
        let expires_at = expires_at_pd.assume_utc();
        let last_seen_pd: PrimitiveDateTime = row.try_get("last_seen_at")?;
        let last_seen_at = last_seen_pd.assume_utc();
        let now = OffsetDateTime::now_utc();
        if expires_at <= now && status == 1 {
            sqlx::query(
                "UPDATE user_session SET status = 3, expires_at = NOW(3) WHERE session_token = ?",
            )
            .bind(token.as_bytes())
            .execute(&self.pool)
            .await?;
            status = 3;
        }

        Ok(Some(SessionTokenRecord {
            user_id,
            device_type: map_device_type(device_type_val),
            device_id,
            session_token: token.to_string(),
            status,
            expires_at,
            last_seen_at,
        }))
    }

    async fn revoke_session_token_by_token(&self, token: &str) -> Result<Option<String>> {
        let affected = sqlx::query(
            r#"
                UPDATE user_session
                SET status = 2, expires_at = NOW(3), last_seen_at = NOW(3)
                WHERE session_token = ?
            "#,
        )
        .bind(token.as_bytes())
        .execute(&self.pool)
        .await?;

        if affected.rows_affected() == 0 {
            return Ok(None);
        }
        Ok(Some(token.to_string()))
    }

    async fn revoke_session_token_by_device(
        &self,
        user_id: i64,
        device_type: DeviceType,
        device_id: &str,
    ) -> Result<Option<String>> {
        let row = sqlx::query(
            r#"
                SELECT session_token
                FROM user_session
                WHERE user_id = ? AND device_type = ? AND device_id = ?
            "#,
        )
        .bind(user_id)
        .bind(device_type as i32)
        .bind(device_id)
        .fetch_optional(&self.pool)
        .await?;

        let Some(row) = row else {
            return Ok(None);
        };

        sqlx::query(
            r#"
                UPDATE user_session
                SET status = 2, expires_at = NOW(3), last_seen_at = NOW(3)
                WHERE user_id = ? AND device_type = ? AND device_id = ?
            "#,
        )
        .bind(user_id)
        .bind(device_type as i32)
        .bind(device_id)
        .execute(&self.pool)
        .await?;
        let token = row
            .try_get::<Vec<u8>, _>("session_token")
            .ok()
            .and_then(|bytes| String::from_utf8(bytes).ok());
        Ok(token)
    }

    async fn touch_tokens(&self, tokens: &[String]) -> Result<u64> {
        if tokens.is_empty() {
            return Ok(0);
        }
        let mut builder = QueryBuilder::new(
            "UPDATE user_session SET last_seen_at = NOW(3) WHERE session_token IN (",
        );
        let mut separated = builder.separated(", ");
        for token in tokens {
            separated.push_bind(token.as_bytes());
        }
        drop(separated);
        builder.push(")");
        let query = builder.build();
        let result = query.execute(&self.pool).await?;
        Ok(result.rows_affected())
    }
}

pub fn build_session_repo() -> SessionRepoSqlx {
    SessionRepoSqlx::new()
}
