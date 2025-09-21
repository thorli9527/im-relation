use std::sync::Arc;

use tonic::{Request, Response, Status};

use crate::grpc_msg_group::msg_group_service::{
    group_biz_service_server::GroupBizService, ApproveJoinReq, ChangeMemberRoleReq,
    CountMembersReq, CountMembersResp, CreateGroupReq, CreateGroupResp, DismissGroupReq,
    GetGroupReq, GetMembersReq, GetMembersResp, GroupInfo, InviteMembersReq, JoinGroupReq,
    KickMemberReq, LeaveGroupReq, UpdateGroupProfileReq, UpdateMemberAliasReq, UserGroupsReq,
    UserGroupsResp,
};
use crate::server::server_grpc::Services;

#[derive(Clone)]
pub struct GroupBizServiceImpl {
    #[allow(dead_code)]
    inner: Arc<Services>,
}

impl GroupBizServiceImpl {
    pub fn new(inner: Arc<Services>) -> Self {
        Self { inner }
    }

    fn not_impl(method: &str) -> Status {
        Status::unimplemented(method)
    }
}

#[tonic::async_trait]
impl GroupBizService for GroupBizServiceImpl {
    async fn create_group(
        &self,
        _request: Request<CreateGroupReq>,
    ) -> Result<Response<CreateGroupResp>, Status> {
        Err(Self::not_impl("GroupBizService.CreateGroup"))
    }

    async fn update_group_profile(
        &self,
        _request: Request<UpdateGroupProfileReq>,
    ) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.UpdateGroupProfile"))
    }

    async fn dismiss_group(
        &self,
        _request: Request<DismissGroupReq>,
    ) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.DismissGroup"))
    }

    async fn join_group(&self, _request: Request<JoinGroupReq>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.JoinGroup"))
    }

    async fn leave_group(&self, _request: Request<LeaveGroupReq>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.LeaveGroup"))
    }

    async fn approve_join(
        &self,
        _request: Request<ApproveJoinReq>,
    ) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.ApproveJoin"))
    }

    async fn invite_members(
        &self,
        _request: Request<InviteMembersReq>,
    ) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.InviteMembers"))
    }

    async fn kick_member(&self, _request: Request<KickMemberReq>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.KickMember"))
    }

    async fn update_member_alias(
        &self,
        _request: Request<UpdateMemberAliasReq>,
    ) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.UpdateMemberAlias"))
    }

    async fn change_member_role(
        &self,
        _request: Request<ChangeMemberRoleReq>,
    ) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupBizService.ChangeMemberRole"))
    }

    async fn get_group(
        &self,
        _request: Request<GetGroupReq>,
    ) -> Result<Response<GroupInfo>, Status> {
        Err(Self::not_impl("GroupBizService.GetGroup"))
    }

    async fn get_members(
        &self,
        _request: Request<GetMembersReq>,
    ) -> Result<Response<GetMembersResp>, Status> {
        Err(Self::not_impl("GroupBizService.GetMembers"))
    }

    async fn count_members(
        &self,
        _request: Request<CountMembersReq>,
    ) -> Result<Response<CountMembersResp>, Status> {
        Err(Self::not_impl("GroupBizService.CountMembers"))
    }

    async fn user_groups(
        &self,
        _request: Request<UserGroupsReq>,
    ) -> Result<Response<UserGroupsResp>, Status> {
        Err(Self::not_impl("GroupBizService.UserGroups"))
    }
}
