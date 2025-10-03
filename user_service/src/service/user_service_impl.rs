// hot_online_service/src/grpc/user_service_impl.rs

use std::pin::Pin;
use std::sync::Arc;

use prost_types::FieldMask;
use sqlx::{MySql, QueryBuilder, Row};
use tonic::{Request, Response, Status};

use common::config::get_db;
use common::util::common_utils::build_snow_id;

use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use crate::hot_cold::{ClientHot, Normalizer};
use common::grpc::grpc_hot_online::online_service::user_rpc_service_server::UserRpcService;
use common::grpc::grpc_hot_online::online_service::{
    ChangeEmailReq, ChangePasswordReq, ChangePhoneReq, ChangeResponse, FindByContentReq,
    FindUserDto, GetUserReq, GetUsersReq, RegisterUserReq, UpdateUserReq, UserEntity,
};
use tokio_stream::iter;

#[async_trait::async_trait]
pub trait IdAllocator: Send + Sync + 'static {
    async fn next_id(&self) -> anyhow::Result<i64>;
}

pub struct DummyIdAlloc;
#[async_trait::async_trait]
impl IdAllocator for DummyIdAlloc {
    async fn next_id(&self) -> anyhow::Result<i64> {
        Ok(build_snow_id())
    }
}

/// 可选的在线续命回调：所有对外 RPC 在读热之前触发一次。
type OnlineTouch = Arc<dyn Fn(i64) + Send + Sync>;

pub struct UserEntityServiceImpl<C, D, N, I>
where
    C: ClientReadRepo + Send + Sync + 'static,
    D: DirectoryReadRepo + Send + Sync + 'static,
    N: Normalizer,
    I: IdAllocator,
{
    hot: ClientHot<C, D, N>,
    normalizer: Arc<N>,
    id_alloc: Arc<I>,
    // 取热前"触摸续命"（可选）
    online_touch: Option<OnlineTouch>,
}

impl<C, D, N, I> UserEntityServiceImpl<C, D, N, I>
where
    C: ClientReadRepo + Send + Sync + 'static,
    D: DirectoryReadRepo + Send + Sync + 'static,
    N: Normalizer,
    I: IdAllocator,
{
    pub fn new(
        hot: ClientHot<C, D, N>,
        normalizer: Arc<N>,
        id_alloc: I,
        online_touch: Option<OnlineTouch>,
    ) -> Self {
        Self {
            hot,
            normalizer,
            id_alloc: Arc::new(id_alloc),
            online_touch,
        }
    }

    #[inline]
    fn touch_online(&self, id: i64) {
        if let Some(cb) = &self.online_touch {
            (cb)(id);
        }
    }

    // -------- 密码 --------

    #[inline]
    fn verify_password(&self, stored_password: &str, raw: &str) -> bool {
        // 直接比较明文密码
        stored_password == raw
    }

    // -------- 目录写帮助（uid_*：列名使用 email/phone/name；无 shard_id） --------

    async fn upsert_uid_email(
        &self,
        tx: &mut sqlx::Transaction<'_, MySql>,
        email_norm: &[u8],
        id: i64,
    ) -> Result<(), Status> {
        // 存量是否占用
        if let Some(existing) =
            sqlx::query_scalar::<_, i64>("SELECT id FROM uid_email WHERE email=?")
                .bind(email_norm)
                .fetch_optional(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("select uid_email: {e}")))?
        {
            if existing != id {
                return Err(Status::already_exists("email already used"));
            }
            sqlx::query("UPDATE uid_email SET state=1, update_time=NOW(3) WHERE email=?")
                .bind(email_norm)
                .execute(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("update uid_email: {e}")))?;
            return Ok(());
        }
        // 新增
        sqlx::query("INSERT INTO uid_email(email,id,state) VALUES(?,?,1)")
            .bind(email_norm)
            .bind(id)
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
    ) -> Result<(), Status> {
        if let Some(existing) =
            sqlx::query_scalar::<_, i64>("SELECT id FROM uid_phone WHERE phone=?")
                .bind(phone_norm)
                .fetch_optional(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("select uid_phone: {e}")))?
        {
            if existing != id {
                return Err(Status::already_exists("phone already used"));
            }
            sqlx::query("UPDATE uid_phone SET state=1, update_time=NOW(3) WHERE phone=?")
                .bind(phone_norm)
                .execute(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("update uid_phone: {e}")))?;
            return Ok(());
        }
        sqlx::query("INSERT INTO uid_phone(phone,id,state) VALUES(?,?,1)")
            .bind(phone_norm)
            .bind(id)
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
    ) -> Result<(), Status> {
        if let Some(existing) = sqlx::query_scalar::<_, i64>("SELECT id FROM uid_name WHERE name=?")
            .bind(name_norm)
            .fetch_optional(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("select uid_name: {e}")))?
        {
            if existing != id {
                return Err(Status::already_exists("username already used"));
            }
            sqlx::query("UPDATE uid_name SET state=1, update_time=NOW(3) WHERE name=?")
                .bind(name_norm)
                .execute(tx.as_mut())
                .await
                .map_err(|e| Status::internal(format!("update uid_name: {e}")))?;
            return Ok(());
        }
        sqlx::query("INSERT INTO uid_name(name,id,state) VALUES(?,?,1)")
            .bind(name_norm)
            .bind(id)
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
        sqlx::query("DELETE FROM uid_email WHERE email=?")
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
        sqlx::query("DELETE FROM uid_phone WHERE phone=?")
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
        sqlx::query("DELETE FROM uid_name WHERE name=?")
            .bind(name_norm)
            .execute(tx.as_mut())
            .await
            .map_err(|e| Status::internal(format!("delete uid_name: {e}")))?;
        Ok(())
    }
}

#[tonic::async_trait]
impl<C, D, N, I> UserRpcService for UserEntityServiceImpl<C, D, N, I>
where
    C: ClientReadRepo + Send + Sync + 'static,
    D: DirectoryReadRepo + Send + Sync + 'static,
    N: Normalizer,
    I: IdAllocator,
{
    type GetUsersStream =
        Pin<Box<dyn tokio_stream::Stream<Item = Result<UserEntity, Status>> + Send + 'static>>;

    async fn find_by_email(
        &self,
        request: Request<FindByContentReq>,
    ) -> Result<Response<FindUserDto>, Status> {
        let req = request.into_inner();
        let content = req.content;

        if content.is_empty() {
            return Err(Status::invalid_argument("email content is empty"));
        }

        // 通过热层查询用户
        let client_opt = self
            .hot
            .get_by_email(&content)
            .await
            .map_err(|e| Status::internal(format!("find by email failed: {}", e)))?;

        match client_opt {
            Some(client) => {
                // 触发在线状态更新
                self.touch_online(client.id);
                let entity = (*client).clone();
                Ok(Response::new(FindUserDto { user: Some(entity) }))
            }
            None => Ok(Response::new(FindUserDto { user: None })),
        }
    }

    async fn find_by_phone(
        &self,
        request: Request<FindByContentReq>,
    ) -> Result<Response<FindUserDto>, Status> {
        let req = request.into_inner();
        let content = req.content;

        if content.is_empty() {
            return Err(Status::invalid_argument("phone content is empty"));
        }

        // 通过热层查询用户
        let client_opt = self
            .hot
            .get_by_phone(&content)
            .await
            .map_err(|e| Status::internal(format!("find by phone failed: {}", e)))?;

        match client_opt {
            Some(client) => {
                // 触发在线状态更新
                self.touch_online(client.id);
                let entity = (*client).clone();
                Ok(Response::new(FindUserDto { user: Some(entity) }))
            }
            None => Ok(Response::new(FindUserDto { user: None })),
        }
    }

    async fn find_by_name(
        &self,
        request: Request<FindByContentReq>,
    ) -> Result<Response<FindUserDto>, Status> {
        let req = request.into_inner();
        let content = req.content;

        if content.is_empty() {
            return Err(Status::invalid_argument("name content is empty"));
        }

        // 通过热层查询用户
        let client_opt = self
            .hot
            .get_by_name(&content)
            .await
            .map_err(|e| Status::internal(format!("find by name failed: {}", e)))?;

        match client_opt {
            Some(client) => {
                // 触发在线状态更新
                self.touch_online(client.id);
                let entity = (*client).clone();
                Ok(Response::new(FindUserDto { user: Some(entity) }))
            }
            None => Ok(Response::new(FindUserDto { user: None })),
        }
    }

    async fn register(
        &self,
        req: Request<RegisterUserReq>,
    ) -> Result<Response<UserEntity>, Status> {
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

        // 发号、准备写库
        let id = self
            .id_alloc
            .next_id()
            .await
            .map_err(|e| Status::internal(format!("alloc id: {e}")))?;
        let db = &*get_db();

        // 目录先占位（事务）
        let mut dir_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
        self.upsert_uid_name(&mut dir_tx, name_norm, id).await?;
        if let Some(ref en) = email_norm {
            self.upsert_uid_email(&mut dir_tx, en.as_ref(), id).await?;
        }
        if let Some(ref pn) = phone_norm {
            self.upsert_uid_phone(&mut dir_tx, pn.as_ref(), id).await?;
        }

        // client 主表（事务）
        let mut cli_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("user_info begin: {e}")))?;
        sqlx::query(
            r#"
            INSERT INTO user_info(
              id, name, password, language, avatar,
              allow_add_friend, gender, user_type,
              email_norm, phone_norm,
              created_at, updated_at, version
            ) VALUES (
              ?, ?, ?, ?, ?,
              ?, ?, ?,
              ?, ?,
              NOW(3), NOW(3), 0
            )
        "#,
        )
        .bind(id)
        .bind(&r.name)
        .bind(&r.password) // 直接存储明文密码
        .bind(r.language.as_deref())
        .bind(&r.avatar)
        .bind(r.allow_add_friend as i32)
        .bind(r.gender as i32)
        .bind(r.user_type as i32)
        .bind(email_norm.as_ref().map(|b| b.as_ref()))
        .bind(phone_norm.as_ref().map(|b| b.as_ref()))
        .execute(cli_tx.as_mut())
        .await
        .map_err(|e| Status::internal(format!("insert user_info: {e}")))?;

        cli_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("user_info commit: {e}")))?;
        dir_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("directory commit: {e}")))?;

        // 刷热 & 返回
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
        self.touch_online(r.id);

        let db = &*get_db();
        let row = sqlx::query("SELECT password FROM user_info WHERE id=?")
            .bind(r.id)
            .fetch_optional(db)
            .await
            .map_err(|e| Status::internal(format!("load password: {e}")))?;
        let Some(row) = row else {
            return Err(Status::not_found("id not found"));
        };
        let stored: String = row
            .try_get("password")
            .map_err(|e| Status::internal(format!("row: {e}")))?;

        if let Some(old) = r.old_password.as_deref() {
            if !old.is_empty() {
                let ok = self.verify_password(&stored, old);
                if !ok {
                    return Ok(Response::new(ChangeResponse { success: false }));
                }
            }
        }

        // TODO: verify_token（短信/邮箱/2FA）
        // 直接使用新密码，不进行哈希处理
        let new_password = r.new_password.clone();
        sqlx::query(
            "UPDATE user_info \
             SET password=?, updated_at=NOW(3), version=version+1 \
             WHERE id=?",
        )
        .bind(new_password)
        .bind(r.id)
        .execute(db)
        .await
        .map_err(|e| Status::internal(format!("update password: {e}")))?;

        Ok(Response::new(ChangeResponse { success: true }))
    }

    async fn change_phone(
        &self,
        req: Request<ChangePhoneReq>,
    ) -> Result<Response<UserEntity>, Status> {
        let r = req.into_inner();
        self.touch_online(r.id);

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
        let db = &*get_db();
        let mut dir_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
        if let Some(ref pn) = new_phone_norm {
            self.upsert_uid_phone(&mut dir_tx, pn.as_ref(), r.id)
                .await?;
        }
        if let Some(op) = old_phone.as_deref() {
            let opn = self
                .normalizer
                .phone_norm(op)
                .map_err(|e| Status::internal(format!("norm old phone: {e}")))?;
            self.delete_uid_phone(&mut dir_tx, opn.as_ref()).await?;
        }

        // 主表
        let mut cli_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("user_info begin: {e}")))?;
        sqlx::query(
            "UPDATE user_info SET phone_norm=?, updated_at=NOW(3), version=version+1 WHERE id=?",
        )
        .bind(new_phone_norm.as_ref().map(|b| b.as_ref()))
        .bind(r.id)
        .execute(cli_tx.as_mut())
        .await
        .map_err(|e| Status::internal(format!("update user_info.phone: {e}")))?;
        cli_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("user_info commit: {e}")))?;
        dir_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("dir commit: {e}")))?;

        // 热层维护（内含 refresh）
        self.hot
            .on_change_phone(old_phone.as_deref(), r.new_phone.as_deref(), r.id)
            .await
            .map_err(|e| Status::internal(format!("hot on_change_phone: {e}")))?;

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
    ) -> Result<Response<UserEntity>, Status> {
        let r = req.into_inner();
        self.touch_online(r.id);

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

        let db = &*get_db();
        // 目录
        let mut dir_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
        if let Some(ref en) = new_email_norm {
            self.upsert_uid_email(&mut dir_tx, en.as_ref(), r.id)
                .await?;
        }
        if let Some(oe) = old_email.as_deref() {
            let oen = self
                .normalizer
                .email_norm(oe)
                .map_err(|e| Status::internal(format!("norm old email: {e}")))?;
            self.delete_uid_email(&mut dir_tx, oen.as_ref()).await?;
        }

        // 主表
        let mut cli_tx = db
            .begin()
            .await
            .map_err(|e| Status::internal(format!("user_info begin: {e}")))?;
        sqlx::query(
            "UPDATE user_info SET email_norm=?, updated_at=NOW(3), version=version+1 WHERE id=?",
        )
        .bind(new_email_norm.as_ref().map(|b| b.as_ref()))
        .bind(r.id)
        .execute(cli_tx.as_mut())
        .await
        .map_err(|e| Status::internal(format!("update user_info.email: {e}")))?;
        cli_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("user_info commit: {e}")))?;
        dir_tx
            .commit()
            .await
            .map_err(|e| Status::internal(format!("dir commit: {e}")))?;

        self.hot
            .on_change_email(old_email.as_deref(), r.new_email.as_deref(), r.id)
            .await
            .map_err(|e| Status::internal(format!("hot on_change_email: {e}")))?;

        let reloaded = self
            .hot
            .get_by_id(r.id)
            .await
            .map_err(|e| Status::internal(format!("reload after change_email: {e}")))?;
        Ok(Response::new((*reloaded).clone()))
    }

    async fn update_user(
        &self,
        req: Request<UpdateUserReq>,
    ) -> Result<Response<UserEntity>, Status> {
        let r = req.into_inner();
        let Some(patch) = r.patch else {
            return Err(Status::invalid_argument("patch required"));
        };
        self.touch_online(patch.id);

        let FieldMask { paths } = r
            .update_mask
            .ok_or_else(|| Status::invalid_argument("update_mask required"))?;

        // 允许更新字段（移除了 profile_fields 相关代码）
        let mut set_name = false;
        let mut set_lang = false;
        let mut set_avatar = false;
        let mut set_policy = false;
        let mut set_gender = false;
        let mut set_user_type = false;

        for p in paths {
            match p.as_str() {
                "name" => set_name = true,
                "language" => set_lang = true,
                "avatar" => set_avatar = true,
                "allow_add_friend" => set_policy = true,
                "gender" => set_gender = true,
                "user_type" => set_user_type = true,
                "profile_fields" => {
                    return Err(Status::invalid_argument("profile_fields not allowed"))
                }
                other => {
                    return Err(Status::invalid_argument(format!(
                        "field not allowed: {other}"
                    )))
                }
            }
        }
        if !(set_name || set_lang || set_avatar || set_policy || set_gender || set_user_type) {
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

            let db = &*get_db();
            let mut dir_tx = db
                .begin()
                .await
                .map_err(|e| Status::internal(format!("dir begin: {e}")))?;
            self.upsert_uid_name(&mut dir_tx, new_name_norm, patch.id)
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

        // 主表：按掩码拼 UPDATE
        let db = &*get_db();
        let mut qb = QueryBuilder::<MySql>::new("UPDATE user_info SET ");
        let mut first = true;

        if set_name {
            if !first {
                qb.push(", ");
            }
            first = false;
            qb.push("name=").push_bind(&patch.name);
        }
        if set_lang {
            if !first {
                qb.push(", ");
            }
            first = false;
            qb.push("language=").push_bind(patch.language.as_deref());
        }
        if set_avatar {
            if !first {
                qb.push(", ");
            }
            first = false;
            qb.push("avatar=").push_bind(&patch.avatar);
        }
        if set_policy {
            if !first {
                qb.push(", ");
            }
            first = false;
            qb.push("allow_add_friend=")
                .push_bind(patch.allow_add_friend);
        }
        if set_gender {
            if !first {
                qb.push(", ");
            }
            first = false;
            qb.push("gender=").push_bind(patch.gender);
        }
        if set_user_type {
            if !first {
                qb.push(", ");
            }
            first = false;
            qb.push("user_type=").push_bind(patch.user_type);
        }

        qb.push(", updated_at=NOW(3), version=version+1 WHERE id=")
            .push_bind(patch.id);
        qb.build()
            .execute(db)
            .await
            .map_err(|e| Status::internal(format!("update user_info: {e}")))?;

        // 热层维护 & 返回
        if set_name {
            self.hot
                .on_change_name(old_name.as_deref(), Some(&patch.name), patch.id)
                .await
                .map_err(|e| Status::internal(format!("hot on_change_name: {e}")))?;
        }
        let out = self
            .hot
            .get_by_id(patch.id)
            .await
            .map_err(|e| Status::internal(format!("reload after update_user: {e}")))?;

        Ok(Response::new((*out).clone()))
    }

    async fn get_user(&self, req: Request<GetUserReq>) -> Result<Response<UserEntity>, Status> {
        let id = req.into_inner().id;
        self.touch_online(id);

        let ent = self
            .hot
            .get_by_id(id)
            .await
            .map_err(|_| Status::not_found("id not found"))?;
        Ok(Response::new((*ent).clone()))
    }

    async fn get_users(
        &self,
        req: Request<GetUsersReq>,
    ) -> Result<Response<Self::GetUsersStream>, Status> {
        let ids = req.into_inner().ids;
        if ids.is_empty() {
            let stream = iter(std::iter::empty::<Result<UserEntity, Status>>());
            return Ok(Response::new(Box::pin(stream)));
        }

        for id in &ids {
            self.touch_online(*id);
        }

        let entities = self
            .hot
            .get_by_ids(&ids)
            .await
            .map_err(|e| Status::internal(format!("get_by_ids failed: {e}")))?;

        let stream = iter(entities.into_iter().map(|ent| Ok((*ent).clone())));
        Ok(Response::new(Box::pin(stream)))
    }
}
