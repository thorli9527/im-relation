use crate::grpc::group_service;
use crate::grpc::group_service::group_service_server::GroupService;
use crate::grpc::group_service::{AllKeysByShardReq, AllKeysByShardResp, AllKeysReq, AllKeysResp, ChangeAliasReq, ChangeAliasResp, ChangeRoleReq, ChangeRoleResp, ClearReq, ClearResp, CountReq, CountResp, GetAllReq, GetAllResp, GetPageReq, GetPageResp, InsertManyReq, InsertManyResp, InsertReq, InsertResp, RemoveReq, RemoveResp, UserGroupsReq, UserGroupsResp};
use crate::hot_cold::HotColdFacade;
use crate::store::mysql::MySqlStore;
use async_trait::async_trait;
use common::MemberListError;
use std::sync::Arc;
use tonic::{Request, Response, Status};
const MAX_PAGE_SIZE: usize = 10_000;
pub struct GroupServiceImpl {
    pub facade: Arc<HotColdFacade<MySqlStore>>,
}
#[async_trait]
impl GroupService for GroupServiceImpl {
    async fn insert(&self, req: Request<InsertReq>) -> Result<Response<InsertResp>, Status> {
        let r = req.into_inner();
        let Some(member_ref) = r.member else {
            return Err(Status::invalid_argument("member is required"));
        };
        self.facade
            .insert(r.group_id, member_ref)
            .await
            .map_err(to_status)?;
        Ok(Response::new(InsertResp {}))
    }

    async fn insert_many(&self, req: Request<InsertManyReq>) -> Result<Response<InsertManyResp>, Status> {
        let r = req.into_inner();
        if r.members.is_empty() {
            return Err(Status::invalid_argument("members is empty"));
        }
        self.facade
            .insert_many(r.group_id, r.members)
            .await
            .map_err(to_status)?;
        Ok(Response::new(InsertManyResp {}))
    }

    async fn remove(&self, req: Request<RemoveReq>) -> Result<Response<RemoveResp>, Status> {
        let r = req.into_inner();
        let removed = self
            .facade
            .remove(r.group_id, r.user_id)
            .await
            .map_err(to_status)?;
        Ok(Response::new(RemoveResp { removed }))
    }

    async fn change_role(&self, req: Request<ChangeRoleReq>) -> Result<Response<ChangeRoleResp>, Status> {
        let r = req.into_inner();
        let role = group_service::GroupRoleType::try_from(r.role)
            .unwrap_or(group_service::GroupRoleType::Member);
        self.facade
            .change_role(r.group_id, r.user_id, role)
            .await
            .map_err(to_status)?;
        Ok(Response::new(ChangeRoleResp {}))
    }

    // 新增：修改别名
    async fn change_alias(&self, req: Request<ChangeAliasReq>) -> Result<Response<ChangeAliasResp>, Status> {
        let r = req.into_inner();
        // 语义：None 或 Some("") => 清空别名
        let alias_opt = r.alias.filter(|s| !s.is_empty());
        self.facade
            .change_alias(r.group_id, r.user_id, alias_opt)
            .await
            .map_err(to_status)?;
        Ok(Response::new(ChangeAliasResp {}))
    }

    async fn get_page(&self, req: Request<GetPageReq>) -> Result<Response<GetPageResp>, Status> {
        let r = req.into_inner();
        let page = r.page as usize;
        let page_size = (r.page_size as usize).min(MAX_PAGE_SIZE);
        let list = self.facade.get_page(r.group_id, page, page_size).await;
        Ok(Response::new(GetPageResp { members: list }))
    }

    async fn get_all(&self, req: Request<GetAllReq>) -> Result<Response<GetAllResp>, Status> {
        let gid = req.into_inner().group_id;
        // 内部已采用游标分页（方案A）避免一次性扫描大结果集
        let list = self.facade.get_all(gid).await;
        Ok(Response::new(GetAllResp { members: list }))
    }

    async fn count(&self, req: Request<CountReq>) -> Result<Response<CountResp>, Status> {
        let gid = req.into_inner().group_id;
        let c = self.facade.count(gid).await as u64;
        Ok(Response::new(CountResp { count: c }))
    }

    async fn user_groups(&self, req: Request<UserGroupsReq>) -> Result<Response<UserGroupsResp>, Status> {
        let uid = req.into_inner().user_id;
        let groups = self.facade.user_groups(uid).await;
        Ok(Response::new(UserGroupsResp { group_ids: groups }))
    }

    async fn all_keys(&self, _req: Request<AllKeysReq>) -> Result<Response<AllKeysResp>, Status> {
        let keys = self.facade.all_keys();
        Ok(Response::new(AllKeysResp { group_ids: keys }))
    }

    async fn all_keys_by_shard(&self, req: Request<AllKeysByShardReq>) -> Result<Response<AllKeysByShardResp>, Status> {
        let idx = req.into_inner().shard_idx as usize;
        let keys = self.facade.all_keys_by_shard(idx);
        Ok(Response::new(AllKeysByShardResp { group_ids: keys }))
    }

    async fn clear(&self, req: Request<ClearReq>) -> Result<Response<ClearResp>, Status> {
        let gid = req.into_inner().group_id;
        self.facade.clear(gid).await;
        Ok(Response::new(ClearResp {}))
    }
}

// 将你的 MemberListError 精细映射为 gRPC Status；
// 下面仅示例常见分支，你可以按你项目里实际的错误枚举来细化：
fn to_status(e: MemberListError) -> Status {
    use tonic::Code::*;
    match e {
        // Member 不存在、群不存在等
        MemberListError::NotFound => Status::new(NotFound, "not found"),
        // 违反业务前置条件（如角色变更非法、越权等）
        MemberListError::PreconditionFailed(_) => Status::new(FailedPrecondition, "precondition failed"),
        // 参数非法
        MemberListError::InvalidUserId | MemberListError::InvalidArgument(_) => {
            Status::new(InvalidArgument, "invalid argument")
        }
        // 资源已存在（重复插入）
        MemberListError::AlreadyExists => Status::new(AlreadyExists, "already exists"),
        // 配额/上限
        MemberListError::TooManyMembers => Status::new(ResourceExhausted, "resource exhausted"),
        // 其它未分类 => INTERNAL，并把调试信息放 detail（按需）
        other => Status::new(Internal, format!("internal error: {:?}", other)),
    }
}