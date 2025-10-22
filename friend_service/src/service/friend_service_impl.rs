use std::sync::Arc;

use async_trait::async_trait;
use tonic::{Request, Response, Status};

use common::support::grpc::internal_error;
use common::UserId;

use crate::hot_cold::HotColdFriendFacade;
use common::infra::grpc::grpc_friend::friend_service::friend_service_server::FriendService;
use common::infra::grpc::grpc_friend::friend_service::*;
// 新版：对齐 FriendRepo（非旧 FriendStorage）
use crate::store::mysql::FriendRepo;
use common::config::get_db;
use sqlx::Executor as _;

/// gRPC 服务实现（对存储做成泛型，默认由上层注入具体 Repo & Facade）
pub struct FriendServiceImpl<R: FriendRepo> {
    pub facade: Arc<HotColdFriendFacade<R>>,
}

impl<R: FriendRepo> FriendServiceImpl<R> {
    /// i64 → UserId（u64 别名），带负数校验
    #[inline]
    fn cast_uid(x: i64, field: &'static str) -> Result<UserId, Status> {
        if x < 0 {
            return Err(Status::invalid_argument(format!("{field} must be >= 0")));
        }
        Ok(x as UserId)
    }

    /// 将 Vec<UserId> 转为 Vec<i64>（proto 使用 i64）
    #[inline]
    fn ids_to_i64(ids: Vec<UserId>) -> Vec<i64> {
        ids.into_iter().map(|id| id as i64).collect()
    }

    /// 简单分页（page 从 1 起，page_size 至少 1，最大上限可按需调整）
    #[inline]
    fn paginate(mut items: Vec<UserId>, page: usize, page_size: usize) -> Vec<UserId> {
        let page = page.max(1);
        let page_size = page_size.clamp(1, 10_000);
        items.sort_unstable(); // 若上游已保证有序，可去掉
        let start = (page - 1) * page_size;
        if start >= items.len() {
            return Vec::new();
        }
        let end = (start + page_size).min(items.len());
        items[start..end].to_vec()
    }
}

#[async_trait]
impl<R: FriendRepo + Send + Sync + 'static> FriendService for FriendServiceImpl<R> {
    async fn add_friend(
        &self,
        request: Request<AddFriendReq>,
    ) -> Result<Response<AddFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id, "user_id")?;
        let fid = Self::cast_uid(req.friend_id, "friend_id")?;
        // 仅使用新字段 alias_for_user
        let alias_for_user = req.alias_for_user.as_deref();
        let alias_for_friend = req.alias_for_friend.as_deref();

        // 判断是否已存在（决定返回布尔）
        let already = self
            .facade
            .get_friends(uid)
            .await
            .map(|v| v.contains(&fid))
            .map_err(|e| internal_error(format!("add_friend/get_friends: {e}")))?;

        // 双向建立关系（事务在存储层）
        if let Err(e) = self
            .facade
            .add_friend_both(uid, fid, alias_for_user, alias_for_friend)
            .await
        {
            // 补偿：写入 job 表
            let msg = format!("{}", e);
            if let Err(job_err) =
                enqueue_friend_add_job(uid, fid, alias_for_user, alias_for_friend, &msg).await
            {
                eprintln!("friend add compensation enqueue failed: {}", job_err);
            }
            return Err(internal_error(format!("add_friend/write: {e}")));
        }

        Ok(Response::new(AddFriendResp { added: !already }))
    }

    async fn remove_friend(
        &self,
        request: Request<RemoveFriendReq>,
    ) -> Result<Response<RemoveFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id, "user_id")?;
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
        let uid = Self::cast_uid(req.user_id, "user_id")?;
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
        todo!()
    }

    async fn get_friends_page_detailed(
        &self,
        request: Request<GetFriendsPageDetailedReq>,
    ) -> Result<Response<GetFriendsPageDetailedResp>, Status> {
        todo!()
    }

    async fn update_friend_alias(
        &self,
        request: Request<UpdateFriendAliasReq>,
    ) -> Result<Response<UpdateFriendAliasResp>, Status> {
        todo!()
    }

    async fn clear_friends(
        &self,
        request: Request<ClearFriendsReq>,
    ) -> Result<Response<ClearFriendsResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id, "user_id")?;

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
    a: UserId,
    b: UserId,
    alias_for_a: Option<&str>,
    alias_for_b: Option<&str>,
    error_msg: &str,
) -> anyhow::Result<()> {
    let pool = get_db();
    let mut msg = error_msg.to_string();
    if msg.len() > 500 {
        msg.truncate(500);
    }
    sqlx::query(
        r#"INSERT INTO friend_add_jobs (user_id, friend_id, alias_for_user, alias_for_friend, error_msg, status)
           VALUES (?, ?, ?, ?, ?, 0)"#,
    )
        .bind(a as i64)
        .bind(b as i64)
        .bind(alias_for_a)
        .bind(alias_for_b)
        .bind(msg)
        .execute(&*pool)
        .await?;
    Ok(())
}
