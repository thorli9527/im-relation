use crate::grpc::group_service;
use crate::grpc::group_service::group_service_server::GroupService;
use crate::grpc::group_service::{AllKeysByShardReq, AllKeysByShardResp, AllKeysReq, AllKeysResp, ChangeRoleReq, ChangeRoleResp, ClearReq, ClearResp, CountReq, CountResp, GetAllReq, GetAllResp, GetPageReq, GetPageResp, InsertManyReq, InsertManyResp, InsertReq, InsertResp, RemoveReq, RemoveResp, UserGroupsReq, UserGroupsResp};
use crate::hot_cold::HotColdFacade;
use crate::store::mysql::MySqlStore;
use async_trait::async_trait;
use common::MemberListError;
use std::sync::Arc;
use tonic::{Request, Response, Status};

pub struct GroupServiceImpl {
    pub facade: Arc<HotColdFacade<MySqlStore>>,
}
#[async_trait]
impl GroupService for GroupServiceImpl {
    async fn insert(&self, req: Request<InsertReq>) -> Result<Response<InsertResp>, Status> {
        let r = req.into_inner();
        let member_ref = r.member.expect("member is required");
        self.facade.insert(r.group_id, member_ref).await.map_err(to_status)?;
        Ok(Response::new(InsertResp{}))
    }

    async fn insert_many(&self, req: Request<InsertManyReq>) -> Result<Response<InsertManyResp>, Status> {
        let r = req.into_inner();
        self.facade.insert_many(r.group_id, r.members).await.map_err(to_status)?;
        Ok(Response::new(InsertManyResp{}))
    }

    async fn remove(&self, req: Request<RemoveReq>) -> Result<Response<RemoveResp>, Status> {
        let r = req.into_inner();
        let removed = self.facade.remove(r.group_id, r.user_id).await.map_err(to_status)?;
        Ok(Response::new(RemoveResp { removed }))
    }

    async fn change_role(&self, req: Request<ChangeRoleReq>) -> Result<Response<ChangeRoleResp>, Status> {
        let r = req.into_inner();
        let role = group_service::GroupRoleType::try_from(r.role).unwrap_or(group_service::GroupRoleType::Member);
        self.facade.change_role(r.group_id, r.user_id, role).await.map_err(to_status)?;
        Ok(Response::new(ChangeRoleResp{}))
    }

    async fn get_page(&self, req: Request<GetPageReq>) -> Result<Response<GetPageResp>, Status> {
        let r = req.into_inner();
        let list = self.facade.get_page(r.group_id, r.page as usize, r.page_size as usize).await;
        Ok(Response::new(GetPageResp { members: list }))
    }

    async fn get_all(&self, req: Request<GetAllReq>) -> Result<Response<GetAllResp>, Status> {
        let gid = req.into_inner().group_id;
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
        Ok(Response::new(UserGroupsResp { group_ids: self.facade.user_groups(uid).await }))
    }

    async fn all_keys(&self, _req: Request<AllKeysReq>) -> Result<Response<AllKeysResp>, Status> {
        Ok(Response::new(AllKeysResp { group_ids: self.facade.all_keys() }))
    }

    async fn all_keys_by_shard(&self, req: Request<AllKeysByShardReq>) -> Result<Response<AllKeysByShardResp>, Status> {
        let idx = req.into_inner().shard_idx as usize;
        Ok(Response::new(AllKeysByShardResp { group_ids: self.facade.all_keys_by_shard(idx) }))
    }

    async fn clear(&self, req: Request<ClearReq>) -> Result<Response<ClearResp>, Status> {
        let gid = req.into_inner().group_id;
        self.facade.clear(gid).await;
        Ok(Response::new(ClearResp{}))
    }
}

fn to_status(e: MemberListError) -> Status { Status::internal("MemberListError.error") }
