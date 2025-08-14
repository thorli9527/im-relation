use std::sync::Arc;

use async_trait::async_trait;
use tonic::{Request, Response, Status};

use common::UserId;

use crate::grpc::friend_service::friend_service_server::FriendService;
use crate::grpc::friend_service::*;
use crate::hot_cold::HotColdFriendFacade;
// 如果你想保持固定实现，也可以直接用 MySqlFriendStore；此处做成泛型更利于测试
use crate::store::mysql::FriendStorage;

/// gRPC 服务实现（对存储实现做成泛型，默认用 MySqlFriendStore 传入）
pub struct FriendServiceImpl<S: FriendStorage> {
    pub facade: Arc<HotColdFriendFacade<S>>,
}

impl<S: FriendStorage> FriendServiceImpl<S> {
    #[inline]
    fn to_status(err: anyhow::Error, ctx: &str) -> Status {
        Status::internal(format!("{ctx}: {err}"))
    }

    #[inline]
    fn cast_uid(x: i64) -> UserId {
        // 你的 UserId 若为 u64 别名，这里做安全转换；如需更严格的校验可自行加范围检查
        x as UserId
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
        // 可选：稳定一下顺序（如果上层已保证有序可去掉）
        items.sort_unstable();
        let start = (page - 1) * page_size;
        if start >= items.len() {
            return Vec::new();
        }
        let end = (start + page_size).min(items.len());
        items[start..end].to_vec()
    }
}

#[async_trait]
impl<S: FriendStorage + Send + Sync + 'static> FriendService for FriendServiceImpl<S> {
    async fn add_friend(
        &self,
        request: Request<AddFriendReq>,
    ) -> Result<Response<AddFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id);
        let fid = Self::cast_uid(req.friend_id);

        // 先看是否已存在（决定返回的 added 布尔）
        let already = self
            .facade
            .get_friends(uid)
            .await
            .map(|v| v.contains(&fid))
            .map_err(|e| Self::to_status(e, "add_friend/get_friends"))?;

        self.facade
            .add_friend(uid, fid)
            .await
            .map_err(|e| Self::to_status(e, "add_friend/save"))?;

        Ok(Response::new(AddFriendResp { added: !already }))
    }

    async fn remove_friend(
        &self,
        request: Request<RemoveFriendReq>,
    ) -> Result<Response<RemoveFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id);
        let fid = Self::cast_uid(req.friend_id);

        // 同理：根据是否存在决定 removed 布尔
        let existed = self
            .facade
            .get_friends(uid)
            .await
            .map(|v| v.contains(&fid))
            .map_err(|e| Self::to_status(e, "remove_friend/get_friends"))?;

        self.facade
            .remove_friend(uid, fid)
            .await
            .map_err(|e| Self::to_status(e, "remove_friend/save"))?;

        Ok(Response::new(RemoveFriendResp { removed: existed }))
    }

    async fn is_friend(
        &self,
        request: Request<IsFriendReq>,
    ) -> Result<Response<IsFriendResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id);
        let fid = Self::cast_uid(req.friend_id);

        let is_friend = self
            .facade
            .get_friends(uid)
            .await
            .map(|v| v.contains(&fid))
            .map_err(|e| Self::to_status(e, "is_friend/get_friends"))?;

        Ok(Response::new(IsFriendResp { is_friend }))
    }

    async fn get_friends(
        &self,
        request: Request<GetFriendsReq>,
    ) -> Result<Response<GetFriendsResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id);

        let friend_ids = self
            .facade
            .get_friends(uid)
            .await
            .map_err(|e| Self::to_status(e, "get_friends"))?;

        Ok(Response::new(GetFriendsResp {
            friend_ids: Self::ids_to_i64(friend_ids),
        }))
    }

    async fn get_friends_page(
        &self,
        request: Request<GetFriendsPageReq>,
    ) -> Result<Response<GetFriendsPageResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id);

        let list = self
            .facade
            .get_friends(uid)
            .await
            .map_err(|e| Self::to_status(e, "get_friends_page/get_friends"))?;

        let page_slice = Self::paginate(list, req.page as usize, req.page_size as usize);

        Ok(Response::new(GetFriendsPageResp {
            friend_ids: Self::ids_to_i64(page_slice),
        }))
    }

    async fn clear_friends(
        &self,
        request: Request<ClearFriendsReq>,
    ) -> Result<Response<ClearFriendsResp>, Status> {
        let req = request.into_inner();
        let uid = Self::cast_uid(req.user_id);

        // 统一通过 facade 的删除用户逻辑（会清持久层并失效热存）
        self.facade
            .delete_user(uid)
            .await
            .map_err(|e| Self::to_status(e, "clear_friends/delete_user"))?;

        Ok(Response::new(ClearFriendsResp {}))
    }
}
