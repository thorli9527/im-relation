use std::sync::Arc;

use async_trait::async_trait;
use tonic::{Request, Response, Status};

use common::support::grpc::internal_error;
use common::UID;

use crate::hot_cold::HotColdFriendFacade;
use common::infra::grpc::grpc_friend::friend_service::friend_service_server::FriendService;
use common::infra::grpc::grpc_friend::friend_service::*;
// 新版：对齐 FriendRepo（非旧 FriendStorage）
use crate::store::mysql::{FriendEntry as RepoFriendEntry, FriendRepo};
use common::config::get_db;
// sqlx::Executor as _; // no longer used

/// gRPC 服务实现（对存储做成泛型，默认由上层注入具体 Repo & Facade）
pub struct FriendServiceImpl<R: FriendRepo> {
    pub facade: Arc<HotColdFriendFacade<R>>,
}

impl<R: FriendRepo> FriendServiceImpl<R> {
    /// i64 → UID（u64 别名），带负数校验
    #[inline]
    fn cast_uid(x: i64, field: &'static str) -> Result<UID, Status> {
        if x < 0 {
            return Err(Status::invalid_argument(format!("{field} must be >= 0")));
        }
        Ok(x as UID)
    }

    #[inline]
    fn convert_entry(entry: RepoFriendEntry, include_nickname: bool) -> FriendEntry {
        let RepoFriendEntry {
            friend_id,
            nickname,
            apply_source,
            remark,
            blacklisted,
            ..
        } = entry;
        FriendEntry {
            friend_id: friend_id as i64,
            nickname: if include_nickname { nickname } else { None },
            apply_source: Some(apply_source.to_string()),
            avatar: None,
            remark,
            blacklisted,
        }
    }
}

#[async_trait]
impl<R: FriendRepo + Send + Sync + 'static> FriendService for FriendServiceImpl<R> {
    async fn add_friend(
        &self,
        request: Request<AddFriendReq>,
    ) -> Result<Response<AddFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;
        let fid = Self::cast_uid(req.friend_id, "friend_id")?;
        if uid == fid {
            return Err(Status::invalid_argument("cannot add yourself"));
        }
        let normalize = |s: Option<&str>| {
            s.and_then(|v| {
                let t = v.trim();
                (!t.is_empty()).then_some(t.to_string())
            })
        };
        // 备注字段兼容逻辑：若 nickname_for_user 未提供，则使用 remark
        let remark_clean = normalize(req.remark.as_deref());
        let remark_for_user = remark_clean.as_deref();
        let remark_for_friend = remark_clean.as_deref();
        let nickname_for_user = normalize(req.nickname_for_user.as_deref());
        let nickname_for_friend = normalize(req.nickname_for_friend.as_deref());

        // 判断是否已存在（决定返回布尔）
        let already = self
            .facade
            .get_friends(uid)
            .await
            .map(|v| v.contains(&fid))
            .map_err(|e| internal_error(format!("add_friend/get_friends: {e}")))?;

        // 双向建立关系（事务在存储层）；失败时写入补偿任务。
        match self
            .facade
            .add_friend_both(
                uid,
                fid,
                nickname_for_user.as_deref(),
                nickname_for_friend.as_deref(),
                remark_clean.as_deref(),
                remark_for_user,
                remark_for_friend,
                req.source,
            )
            .await
        {
            Ok(()) => Ok(Response::new(AddFriendResp { added: !already })),
            Err(err) => {
                let msg = err.to_string();
                if let Err(job_err) = enqueue_friend_add_job(
                    uid,
                    fid,
                    nickname_for_user.as_deref(),
                    nickname_for_friend.as_deref(),
                    req.source,
                    remark_for_user,
                    remark_for_friend,
                    &msg,
                )
            .await
            {
                eprintln!("friend add compensation enqueue failed: {}", job_err);
                }
                Err(internal_error(format!("add_friend/write: {msg}")))
            }
        }
    }

    async fn remove_friend(
        &self,
        request: Request<RemoveFriendReq>,
    ) -> Result<Response<RemoveFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;
        let fid = Self::cast_uid(req.friend_id, "friend_id")?;

        // 同理：根据是否存在决定 removed 布尔
        let existed = self
            .facade
            .get_friends(uid)
            .await
            .map(|v| v.contains(&fid))
            .map_err(|e| internal_error(format!("remove_friend/get_friends: {e}")))?;

        self.facade
            .remove_friend(uid, fid)
            .await
            .map_err(|e| internal_error(format!("remove_friend/write: {e}")))?;

        Ok(Response::new(RemoveFriendResp { removed: existed }))
    }

    async fn is_friend(
        &self,
        request: Request<IsFriendReq>,
    ) -> Result<Response<IsFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;
        let fid = Self::cast_uid(req.friend_id, "friend_id")?;

        // 若想更高效，可给 facade 增加 is_friend 直连底库；此处保持兼容
        let is_friend = self
            .facade
            .get_friends(uid)
            .await
            .map(|v| v.contains(&fid))
            .map_err(|e| internal_error(format!("is_friend/get_friends: {e}")))?;

        Ok(Response::new(IsFriendResp { is_friend }))
    }

    async fn get_friends_detailed(
        &self,
        request: Request<GetFriendsDetailedReq>,
    ) -> Result<Response<GetFriendsDetailedResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;

        let mut cursor: Option<UID> = None;
        let mut friends = Vec::new();
        loop {
            let (batch, next) = self
                .facade
                .page_friends_detailed(uid, cursor, 1024)
                .await
                .map_err(|e| internal_error(format!("get_friends_detailed: {e}")))?;
            if batch.is_empty() {
                break;
            }
            friends.extend(
                batch
                    .into_iter()
                    .map(|entry| Self::convert_entry(entry, req.nickname)),
            );
            cursor = next;
            if cursor.is_none() {
                break;
            }
        }

        Ok(Response::new(GetFriendsDetailedResp { friends }))
    }

    async fn get_friends_page_detailed(
        &self,
        request: Request<GetFriendsPageDetailedReq>,
    ) -> Result<Response<GetFriendsPageDetailedResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;
        let page = req.page.max(1) as usize;
        let page_size = req.page_size.clamp(1, 5_000) as u32;

        let mut current_page = 1usize;
        let mut cursor: Option<UID> = None;
        loop {
            let (batch, next) = self
                .facade
                .page_friends_detailed(uid, cursor, page_size)
                .await
                .map_err(|e| internal_error(format!("get_friends_page_detailed: {e}")))?;

            if current_page == page {
                let friends = batch
                    .into_iter()
                    .map(|entry| Self::convert_entry(entry, true))
                    .collect();
                return Ok(Response::new(GetFriendsPageDetailedResp { friends }));
            }

            if batch.is_empty() || next.is_none() {
                return Ok(Response::new(GetFriendsPageDetailedResp {
                    friends: Vec::new(),
                }));
            }

            cursor = next;
            current_page += 1;
        }
    }

    async fn update_friend_nickname(
        &self,
        request: Request<UpdateFriendNicknameReq>,
    ) -> Result<Response<UpdateFriendNicknameResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;
        let fid = Self::cast_uid(req.friend_id, "friend_id")?;
        let nickname = req
            .nickname
            .as_deref()
            .and_then(|s| if s.is_empty() { None } else { Some(s) });

        let updated = self
            .facade
            .update_friend_nickname(uid, fid, nickname)
            .await
            .map_err(|e| internal_error(format!("update_friend_nickname: {e}")))?;

        Ok(Response::new(UpdateFriendNicknameResp { updated }))
    }

    async fn update_friend_remark(
        &self,
        request: Request<UpdateFriendRemarkReq>,
    ) -> Result<Response<UpdateFriendRemarkResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;
        let fid = Self::cast_uid(req.friend_id, "friend_id")?;
        let remark = req
            .remark
            .as_deref()
            .and_then(|s| if s.is_empty() { None } else { Some(s) });

        let updated = self
            .facade
            .update_friend_remark(uid, fid, remark)
            .await
            .map_err(|e| internal_error(format!("update_friend_remark: {e}")))?;

        Ok(Response::new(UpdateFriendRemarkResp { updated }))
    }

    async fn update_friend_blacklist(
        &self,
        request: Request<UpdateFriendBlacklistReq>,
    ) -> Result<Response<UpdateFriendBlacklistResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;
        let fid = Self::cast_uid(req.friend_id, "friend_id")?;

        let updated = self
            .facade
            .update_friend_blacklist(uid, fid, req.blocked)
            .await
            .map_err(|e| internal_error(format!("update_friend_blacklist: {e}")))?;

        Ok(Response::new(UpdateFriendBlacklistResp { updated }))
    }

    async fn clear_friends(
        &self,
        request: Request<ClearFriendsReq>,
    ) -> Result<Response<ClearFriendsResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.uid, "uid")?;

        // 统一通过 facade 的删除用户逻辑（清持久层并失效热存）
        self.facade
            .delete_user(uid)
            .await
            .map_err(|e| internal_error(format!("clear_friends/write: {e}")))?;

        Ok(Response::new(ClearFriendsResp {}))
    }
}

/// 写入补偿任务（失败不再上抛错误）
async fn enqueue_friend_add_job(
    a: UID,
    b: UID,
    nickname_for_a: Option<&str>,
    nickname_for_b: Option<&str>,
    apply_source: i32,
    remark_for_a: Option<&str>,
    remark_for_b: Option<&str>,
    error_msg: &str,
) -> anyhow::Result<()> {
    let pool = get_db();
    let mut msg = error_msg.to_string();
    if msg.len() > 500 {
        msg.truncate(500);
    }
    sqlx::query(
        r#"INSERT INTO friend_add_jobs (uid, friend_uid, nickname_for_user, nickname_for_friend, apply_source, remark_for_user, remark_for_friend, error_msg, status)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)"#,
    )
        .bind(a as i64)
        .bind(b as i64)
        .bind(nickname_for_a)
        .bind(nickname_for_b)
        .bind(apply_source)
        .bind(remark_for_a)
        .bind(remark_for_b)
        .bind(msg)
        .execute(&*pool)
        .await?;
    Ok(())
}
