// client-service/src/service/client_service_impl.rs

use std::sync::Arc;

use argon2::{
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use argon2::password_hash::rand_core::OsRng;
use prost_types::FieldMask;
use sqlx::{Executor, MySql, Pool, QueryBuilder, Row};
use tonic::{Request, Response, Status};
use common::config::MySqlPool;
use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use crate::grpc::client_service::{
    client_entity_service_server::ClientEntityService, ChangeEmailReq, ChangePasswordReq,
    ChangePhoneReq, ChangeResponse, ClientEntity, GetClientReq, RegisterUserReq, UpdateClientReq,
};
use crate::hot_cold::{ClientHot, Normalizer};

#[async_trait::async_trait]
pub trait IdAllocator: Send + Sync + 'static {
    async fn next_id(&self) -> anyhow::Result<i64>;
}

pub struct DummyIdAlloc;
#[async_trait::async_trait]
impl IdAllocator for DummyIdAlloc {
    async fn next_id(&self) -> anyhow::Result<i64> {
        let dur = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_err(|e| anyhow::anyhow!("clock drift: {e}"))?;
        Ok(((dur.as_nanos()) & (i64::MAX as u128)) as i64)
    }
}

pub struct ClientEntityServiceImpl<C, D, N, I>
where
    C: ClientReadRepo + Send + Sync + 'static,
    D: DirectoryReadRepo + Send + Sync + 'static,
    N: Normalizer,
    I: IdAllocator,
{
    // 读全走热层
    hot: ClientHot<C, D, N>,
    // 直接持有 normalizer，避免从 hot 取私有字段/方法
    normalizer: Arc<N>,

    // 写库
    shard_pools: Arc<[MySqlPool]>,
    dir_pool: MySqlPool,

    shard_count: usize,
    id_alloc: Arc<I>,

    // 密码哈希器（argon2id）
    pwd: Argon2<'static>,
}

impl<C, D, N, I> ClientEntityServiceImpl<C, D, N, I>
where
    C: ClientReadRepo + Send + Sync + 'static,
    D: DirectoryReadRepo + Send + Sync + 'static,
    N: Normalizer,
    I: IdAllocator,
{
    pub fn new(
        hot: ClientHot<C, D, N>,
        normalizer: Arc<N>,
        shard_pools: Vec<Pool<MySql>>,
        dir_pool: Pool<MySql>,
        id_alloc: I,
    ) -> Self {
        let shard_count = shard_pools.len();
        assert!(shard_count > 0, "shard_pools cannot be empty");
        Self {
            hot,
            normalizer,
            shard_pools: shard_pools.into(),
            dir_pool,
            shard_count,
            id_alloc: Arc::new(id_alloc),
            pwd: Argon2::default(),
        }
    }

    #[inline]
    fn shard_idx(&self, id: i64) -> usize {
        (id as u64 % self.shard_count as u64) as usize
    }
    #[inline]
    fn shard_db(&self, id: i64) -> &Pool<MySql> {
        &self.shard_pools[self.shard_idx(id)]
    }

    // -------- 密码 --------

    #[inline]
    fn hash_password(&self, raw: &str) -> Result<String, Status> {
        let salt = SaltString::generate(&mut OsRng);
        self.pwd
            .hash_password(raw.as_bytes(), &salt)
            .map(|h| h.to_string())
            .map_err(|e| Status::internal(format!("hash_password: {e}")))
    }

    #[inline]
    fn verify_password(&self, stored_hash: &str, raw: &str) -> Result<bool, Status> {
        let parsed = PasswordHash::new(stored_hash)
            .map_err(|e| Status::internal(format!("parse hash: {e}")))?;
        Ok(self.pwd.verify_password(raw.as_bytes(), &parsed).is_ok())
    }

    // -------- 目录写帮助（统一 tx.as_mut()） --------

    async fn upsert_uid_email(
        &self,
        tx: &mut sqlx::Transaction<'_, MySql>,
        email_norm: &[u8],
        id: i64,
        shard_id: i32,
    ) -> Result<(), Status> {
        if let Some(existing) =
            sqlx::query_scalar::<_, i64>("SELECT id FROM uid_email WHERE email_norm=?")
                .bind(email_norm)
                .fetch_optional(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("select uid_email: {e}")))?
        {
            if existing != id {
                return Err(Status::already_exists("email already used"));
            }
            sqlx::query("UPDATE uid_email SET state=1, shard_id=?, updated_at=NOW(3) WHERE email_norm=?")
                .bind(shard_id)
                .bind(email_norm)
                .execute(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("update uid_email: {e}")))?;
            return Ok(());
        }
        sqlx::query("INSERT INTO uid_email(email_norm,id,shard_id,state,updated_at) VALUES(?,?,?,1,NOW(3))")
            .bind(email_norm)
            .bind(id)
            .bind(shard_id)
            .execute(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("insert uid_email: {e}")))?;
        Ok(())
    }

    async fn upsert_uid_phone(
        &self,
        tx: &mut sqlx::Transaction<'_, MySql>,
        phone_norm: &[u8],
        id: i64,
        shard_id: i32,
    ) -> Result<(), Status> {
        if let Some(existing) =
            sqlx::query_scalar::<_, i64>("SELECT id FROM uid_phone WHERE phone_norm=?")
                .bind(phone_norm)
                .fetch_optional(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("select uid_phone: {e}")))?
        {
            if existing != id {
                return Err(Status::already_exists("phone already used"));
            }
            sqlx::query("UPDATE uid_phone SET state=1, shard_id=?, updated_at=NOW(3) WHERE phone_norm=?")
                .bind(shard_id)
                .bind(phone_norm)
                .execute(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("update uid_phone: {e}")))?;
            return Ok(());
        }
        sqlx::query("INSERT INTO uid_phone(phone_norm,id,shard_id,state,updated_at) VALUES(?,?,?,1,NOW(3))")
            .bind(phone_norm)
            .bind(id)
            .bind(shard_id)
            .execute(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("insert uid_phone: {e}")))?;
        Ok(())
    }

    async fn upsert_uid_name(
        &self,
        tx: &mut sqlx::Transaction<'_, MySql>,
        name_norm: &str,
        id: i64,
        shard_id: i32,
    ) -> Result<(), Status> {
        if let Some(existing) =
            sqlx::query_scalar::<_, i64>("SELECT id FROM uid_name WHERE name_norm=?")
                .bind(name_norm)
                .fetch_optional(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("select uid_name: {e}")))?
        {
            if existing != id {
                return Err(Status::already_exists("username already used"));
            }
            sqlx::query("UPDATE uid_name SET shard_id=?, updated_at=NOW(3) WHERE name_norm=?")
                .bind(shard_id)
                .bind(name_norm)
                .execute(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("update uid_name: {e}")))?;
            return Ok(());
        }
        sqlx::query("INSERT INTO uid_name(name_norm,id,shard_id,updated_at) VALUES(?,?,?,NOW(3))")
            .bind(name_norm)
            .bind(id)
            .bind(shard_id)
            .execute(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("insert uid_name: {e}")))?;
        Ok(())
    }

    async fn delete_uid_email(
        &self,
        tx: &mut sqlx::Transaction<'_, MySql>,
        email_norm: &[u8],
    ) -> Result<(), Status> {
        sqlx::query("DELETE FROM uid_email WHERE email_norm=?")
            .bind(email_norm)
            .execute(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("delete uid_email: {e}")))?;
        Ok(())
    }

    async fn delete_uid_phone(
        &self,
        tx: &mut sqlx::Transaction<'_, MySql>,
        phone_norm: &[u8],
    ) -> Result<(), Status> {
        sqlx::query("DELETE FROM uid_phone WHERE phone_norm=?")
            .bind(phone_norm)
            .execute(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("delete uid_phone: {e}")))?;
        Ok(())
    }

    async fn delete_uid_name(
        &self,
        tx: &mut sqlx::Transaction<'_, MySql>,
        name_norm: &str,
    ) -> Result<(), Status> {
        sqlx::query("DELETE FROM uid_name WHERE name_norm=?")
            .bind(name_norm)
            .execute(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("delete uid_name: {e}")))?;
        Ok(())
    }
}

#[tonic::async_trait]
impl<C, D, N, I> ClientEntityService for ClientEntityServiceImpl<C, D, N, I>
where
    C: ClientReadRepo + Send + Sync + 'static,
    D: DirectoryReadRepo + Send + Sync + 'static,
    N: Normalizer,
    I: IdAllocator,
{
    async fn register(
        &self,
        req: Request<RegisterUserReq>,
    ) -> Result<Response<ClientEntity>, Status> {
        let r = req.into_inner();

        if r.name.trim().is_empty() {
            return Err(Status::invalid_argument("name required"));
        }
        if r.password.trim().is_empty() {
            return Err(Status::invalid_argument("password required"));
        }

        // 规范化（读写一致）
        let name_norm_b = self
            .normalizer
            .name_norm(&r.name)
            .map_err(|e| Status::invalid_argument(format!("bad name: {e}")))?;
        let name_norm = std::str::from_utf8(&name_norm_b)
            .map_err(|e| Status::invalid_argument(format!("name not utf8: {e}")))?;

        let email_norm = match r.email.as_deref() {
            Some(e) if !e.is_empty() => Some(
                self.normalizer
                    .email_norm(e)
                    .map_err(|e| Status::invalid_argument(format!("bad email: {e}")))?,
            ),
            _ => None,
        };
        let phone_norm = match r.phone.as_deref() {
            Some(p) if !p.is_empty() => Some(
                self.normalizer
                    .phone_norm(p)
                    .map_err(|e| Status::invalid_argument(format!("bad phone: {e}")))?,
            ),
            _ => None,
        };

        // 发号与分片
        let id = self
            .id_alloc
            .next_id()
            .await
            .map_err(|e| Status::internal(format!("alloc id: {e}")))?;
        let shard_id = self.shard_idx(id) as i32;
        let pwd_hash = self.hash_password(&r.password)?;

        // 目录库事务（先写目录，防止重复占用）
        let mut dir_tx = self
            .dir_pool
            .begin()
            .await
            .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
        self.upsert_uid_name(&mut dir_tx, name_norm, id, shard_id).await?;
        if let Some(ref en) = email_norm {
            self.upsert_uid_email(&mut dir_tx, en.as_ref(), id, shard_id)
                .await?;
        }
        if let Some(ref pn) = phone_norm {
            self.upsert_uid_phone(&mut dir_tx, pn.as_ref(), id, shard_id)
                .await?;
        }

        // 分片库事务
        let db = self.shard_db(id);
        let mut cli_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("shard begin: {e}")))?;
        sqlx::query(
            r#"
            INSERT INTO client(
              id, name, password_hash, password_algo, language, avatar,
              allow_add_friend, gender, user_type,
              email_norm, phone_norm, profile_fields,
              created_at, updated_at, version
            ) VALUES (
              ?, ?, ?, 1, ?, ?,
              ?, ?, ?,
              ?, ?, ?,
              NOW(3), NOW(3), 0
            )
        "#,
        )
            .bind(id)
            .bind(&r.name)
            .bind(pwd_hash)
            .bind(r.language.as_deref())
            .bind(&r.avatar)
            .bind(r.allow_add_friend as i32)
            .bind(r.gender as i32)
            .bind(r.user_type as i32)
            .bind(email_norm.as_ref().map(|b| b.as_ref()))
            .bind(phone_norm.as_ref().map(|b| b.as_ref()))
            .bind(sqlx::types::Json(r.profile_fields))
            .execute(cli_tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("insert client: {e}")))?;

        cli_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("shard commit: {e}")))?;
        dir_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("dir commit: {e}")))?;

        // 刷热 & 返回（refresh -> get_by_id）
        self.hot
            .refresh_by_id(id)
            .await
            .map_err(|e| Status::internal(format!("refresh hot: {e}")))?;
        let ent = self
            .hot
            .get_by_id(id)
            .await
            .map_err(|e| Status::internal(format!("reload after register: {e}")))?;
        Ok(Response::new((*ent).clone()))
    }

    async fn change_password(
        &self,
        req: Request<ChangePasswordReq>,
    ) -> Result<Response<ChangeResponse>, Status> {
        let r = req.into_inner();

        let row = sqlx::query("SELECT password_hash FROM client WHERE id=?")
            .bind(r.id)
            .fetch_optional(self.shard_db(r.id))
            .await
            .map_err(|e| Status::internal(format!("load hash: {e}")))?;
        let Some(row) = row else { return Err(Status::not_found("id not found")); };
        let stored: String =
            row.try_get("password_hash").map_err(|e| Status::internal(format!("row: {e}")))?;

        if let Some(old) = r.old_password.as_deref() {
            if !old.is_empty() {
                let ok = self.verify_password(&stored, old)?;
                if !ok {
                    return Ok(Response::new(ChangeResponse { success: false }));
                }
            }
        }

        // TODO: verify_token 校验（短信/邮箱/2FA）
        let new_hash = self.hash_password(&r.new_password)?;
        sqlx::query(
            "UPDATE client \
             SET password_hash=?, password_algo=1, updated_at=NOW(3), version=version+1 \
             WHERE id=?",
        )
            .bind(new_hash)
            .bind(r.id)
            .execute(self.shard_db(r.id))
            .await
            .map_err(|e| Status::internal(format!("update password: {e}")))?;

        Ok(Response::new(ChangeResponse { success: true }))
    }

    async fn change_phone(
        &self,
        req: Request<ChangePhoneReq>,
    ) -> Result<Response<ClientEntity>, Status> {
        let r = req.into_inner();

        let cur = self
            .hot
            .get_by_id(r.id)
            .await
            .map_err(|_| Status::not_found("id not found"))?;
        let old_phone = cur.phone.clone();

        let new_phone_norm = match r.new_phone.as_deref() {
            Some(p) if !p.is_empty() => Some(
                self.normalizer
                    .phone_norm(p)
                    .map_err(|e| Status::invalid_argument(format!("bad phone: {e}")))?,
            ),
            _ => None,
        };

        // 目录库
        let mut dir_tx = self
            .dir_pool
            .begin()
            .await
            .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
        let shard_id = self.shard_idx(r.id) as i32;
        if let Some(ref pn) = new_phone_norm {
            self.upsert_uid_phone(&mut dir_tx, pn.as_ref(), r.id, shard_id)
                .await?;
        }
        if let Some(op) = old_phone.as_deref() {
            let opn = self
                .normalizer
                .phone_norm(op)
                .map_err(|e| Status::internal(format!("norm old phone: {e}")))?;
            self.delete_uid_phone(&mut dir_tx, opn.as_ref()).await?;
        }

        // 分片库
        let db = self.shard_db(r.id);
        let mut cli_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("shard begin: {e}")))?;
        sqlx::query("UPDATE client SET phone_norm=?, updated_at=NOW(3), version=version+1 WHERE id=?")
            .bind(new_phone_norm.as_ref().map(|b| b.as_ref()))
            .bind(r.id)
            .execute(cli_tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("update client.phone: {e}")))?;
        cli_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("shard commit: {e}")))?;
        dir_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("dir commit: {e}")))?;

        self.hot
            .on_change_phone(old_phone.as_deref(), r.new_phone.as_deref(), r.id)
            .await
            .map_err(|e| Status::internal(format!("hot on_change_phone: {e}")))?;
        self.hot
            .refresh_by_id(r.id)
            .await
            .map_err(|e| Status::internal(format!("refresh: {e}")))?;
        let reloaded = self
            .hot
            .get_by_id(r.id)
            .await
            .map_err(|e| Status::internal(format!("reload after change_phone: {e}")))?;
        Ok(Response::new((*reloaded).clone()))
    }

    async fn change_email(
        &self,
        req: Request<ChangeEmailReq>,
    ) -> Result<Response<ClientEntity>, Status> {
        let r = req.into_inner();

        let cur = self
            .hot
            .get_by_id(r.id)
            .await
            .map_err(|_| Status::not_found("id not found"))?;
        let old_email = cur.email.clone();

        let new_email_norm = match r.new_email.as_deref() {
            Some(e) if !e.is_empty() => Some(
                self.normalizer
                    .email_norm(e)
                    .map_err(|e| Status::invalid_argument(format!("bad email: {e}")))?,
            ),
            _ => None,
        };

        // 目录库
        let mut dir_tx = self
            .dir_pool
            .begin()
            .await
            .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
        let shard_id = self.shard_idx(r.id) as i32;
        if let Some(ref en) = new_email_norm {
            self.upsert_uid_email(&mut dir_tx, en.as_ref(), r.id, shard_id)
                .await?;
        }
        if let Some(oe) = old_email.as_deref() {
            let oen = self
                .normalizer
                .email_norm(oe)
                .map_err(|e| Status::internal(format!("norm old email: {e}")))?;
            self.delete_uid_email(&mut dir_tx, oen.as_ref()).await?;
        }

        // 分片库
        let db = self.shard_db(r.id);
        let mut cli_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("shard begin: {e}")))?;
        sqlx::query("UPDATE client SET email_norm=?, updated_at=NOW(3), version=version+1 WHERE id=?")
            .bind(new_email_norm.as_ref().map(|b| b.as_ref()))
            .bind(r.id)
            .execute(cli_tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("update client.email: {e}")))?;
        cli_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("shard commit: {e}")))?;
        dir_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("dir commit: {e}")))?;

        self.hot
            .on_change_email(old_email.as_deref(), r.new_email.as_deref(), r.id)
            .await
            .map_err(|e| Status::internal(format!("hot on_change_email: {e}")))?;
        self.hot
            .refresh_by_id(r.id)
            .await
            .map_err(|e| Status::internal(format!("refresh: {e}")))?;
        let reloaded = self
            .hot
            .get_by_id(r.id)
            .await
            .map_err(|e| Status::internal(format!("reload after change_email: {e}")))?;
        Ok(Response::new((*reloaded).clone()))
    }

    async fn update_client(
        &self,
        req: Request<UpdateClientReq>,
    ) -> Result<Response<ClientEntity>, Status> {
        let r = req.into_inner();
        let Some(patch) = r.patch else {
            return Err(Status::invalid_argument("patch required"));
        };
        let FieldMask { paths } = r
            .update_mask
            .ok_or_else(|| Status::invalid_argument("update_mask required"))?;

        // 允许更新字段
        let mut set_name = false;
        let mut set_lang = false;
        let mut set_avatar = false;
        let mut set_policy = false;
        let mut set_gender = false;
        let mut set_user_type = false;
        let mut set_profile = false;

        for p in paths {
            match p.as_str() {
                "name" => set_name = true,
                "language" => set_lang = true,
                "avatar" => set_avatar = true,
                "allow_add_friend" => set_policy = true,
                "gender" => set_gender = true,
                "user_type" => set_user_type = true,
                "profile_fields" => set_profile = true,
                other => return Err(Status::invalid_argument(format!("field not allowed: {other}"))),
            }
        }
        if !(set_name || set_lang || set_avatar || set_policy || set_gender || set_user_type || set_profile) {
            return Err(Status::invalid_argument("no updatable fields in mask"));
        }

        // 改名：先维护目录（读写一致）
        let mut old_name: Option<String> = None;
        if set_name {
            let cur = self
                .hot
                .get_by_id(patch.id)
                .await
                .map_err(|_| Status::not_found("id not found"))?;
            old_name = Some(cur.name.clone());

            let new_name_norm_b = self
                .normalizer
                .name_norm(&patch.name)
                .map_err(|e| Status::invalid_argument(format!("bad name: {e}")))?;
            let new_name_norm = std::str::from_utf8(&new_name_norm_b)
                .map_err(|e| Status::invalid_argument(format!("name not utf8: {e}")))?;

            let mut dir_tx = self
                .dir_pool
                .begin()
                .await
                .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
            let shard_id = self.shard_idx(patch.id) as i32;
            self.upsert_uid_name(&mut dir_tx, new_name_norm, patch.id, shard_id)
                .await?;
            if let Some(ref on) = old_name {
                if on != &patch.name {
                    let on_b = self
                        .normalizer
                        .name_norm(on)
                        .map_err(|e| Status::internal(format!("norm old name: {e}")))?;
                    let on_norm = std::str::from_utf8(&on_b)
                        .map_err(|e| Status::internal(format!("old name not utf8: {e}")))?;
                    self.delete_uid_name(&mut dir_tx, on_norm).await?;
                }
            }
            dir_tx
                .commit()
                .await
                .map_err(|e| Status::internal(format!("dir commit: {e}")))?;
        }

        // 分片库：按掩码拼 UPDATE
        let db = self.shard_db(patch.id);
        let mut qb = QueryBuilder::<MySql>::new("UPDATE client SET ");
        let mut first = true;

        if set_name {
            if !first { qb.push(", "); }
            first = false;
            qb.push("name=").push_bind(&patch.name);
        }
        if set_lang {
            if !first { qb.push(", "); }
            first = false;
            qb.push("language=").push_bind(patch.language.as_deref());
        }
        if set_avatar {
            if !first { qb.push(", "); }
            first = false;
            qb.push("avatar=").push_bind(&patch.avatar);
        }
        if set_policy {
            if !first { qb.push(", "); }
            first = false;
            qb.push("allow_add_friend=").push_bind(patch.allow_add_friend);
        }
        if set_gender {
            if !first { qb.push(", "); }
            first = false;
            qb.push("gender=").push_bind(patch.gender);
        }
        if set_user_type {
            if !first { qb.push(", "); }
            first = false;
            qb.push("user_type=").push_bind(patch.user_type);
        }
        if set_profile {
            if !first { qb.push(", "); }
            first = false;
            qb.push("profile_fields=").push_bind(sqlx::types::Json(patch.profile_fields.clone()));
        }

        qb.push(", updated_at=NOW(3), version=version+1 WHERE id=").push_bind(patch.id);
        qb.build()
            .execute(db)
            .await
            .map_err(|e| Status::internal(format!("update client: {e}")))?;

        // 热层维护 & 返回
        if set_name {
            self.hot
                .on_change_name(old_name.as_deref(), Some(&patch.name), patch.id)
                .await
                .map_err(|e| Status::internal(format!("hot on_change_name: {e}")))?;
        }
        self.hot
            .refresh_by_id(patch.id)
            .await
            .map_err(|e| Status::internal(format!("refresh: {e}")))?;
        let out = self
            .hot
            .get_by_id(patch.id)
            .await
            .map_err(|e| Status::internal(format!("reload after update_client: {e}")))?;

        Ok(Response::new((*out).clone()))
    }

    async fn get_client(
        &self,
        req: Request<GetClientReq>,
    ) -> Result<Response<ClientEntity>, Status> {
        let id = req.into_inner().id;
        let ent = self
            .hot
            .get_by_id(id)
            .await
            .map_err(|_| Status::not_found("id not found"))?;
        Ok(Response::new((*ent).clone()))
    }
}
