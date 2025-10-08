//! msg_group 对外群业务接口。
//!
//! - 热数据（成员、资料）统一托管在 group_service，本服务通过 gRPC 代理。
//! - 冷数据（申请、审批、审计日志）落在本地 MySQL 以便追踪。
//! - 每次变更尽量先确保热存储成功，再补齐日志，确保体验与可观测性兼顾。

use std::collections::HashSet;
use std::convert::TryFrom;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use common::kafka::kafka_producer::KafkaInstanceService;
use common::util::common_utils::build_snow_id;
use log::warn;
use serde_json::json;
use tonic::{Request, Response, Status};

use crate::dao::action_log::{insert_group_action_log, GroupActionLogRow};
use crate::dao::join_request::{
    get_join_request, update_join_request_status, upsert_join_request, GroupJoinRequestRow,
    JoinRequestStatus,
};
use crate::server::Services;
use crate::service::socket_push::push_socket_message;
use crate::socket::MsgKind as SocketMsgKind;
use common::grpc::grpc_hot_group::group_service::{
    self as hotpb, ChangeAliasReq as HotChangeAliasReq, ChangeRoleReq as HotChangeRoleReq,
    CommonResp as HotCommonResp, CountReq as HotCountReq, CreateGroupReq as HotCreateGroupReq,
    DismissGroupReq as HotDismissGroupReq, GetAllReq as HotGetAllReq,
    GetManagersReq as HotGetManagersReq, GetPageReq as HotGetPageReq, IdReq as HotIdReq,
    InsertManyReq as HotInsertManyReq, InsertReq as HotInsertReq, MemberRef as HotMemberRef,
    RemoveReq as HotRemoveReq, UpdateGroupProfileReq as HotUpdateGroupProfileReq,
};
use common::grpc::grpc_msg_group::msg_group_service::{
    group_biz_service_server::GroupBizService, ApproveJoinReq, ChangeMemberRoleReq,
    CountMembersReq, CountMembersResp, CreateGroupReq, CreateGroupResp, DismissGroupReq,
    GetGroupReq, GetMembersReq, GetMembersResp, GroupInfo, GroupMemberChangeNotice, GroupRoleType,
    InviteMembersReq, JoinGroupReq, JoinRequestHandledNotice, JoinRequestNotice, KickMemberReq,
    LeaveGroupReq, MemberRef, UpdateGroupProfileReq, UpdateMemberAliasReq, UserGroupsReq,
    UserGroupsResp,
};

/// gRPC 服务具体实现，负责协调 hot_group 与本地持久化。
#[derive(Clone)]
pub struct GroupBizServiceImpl {
    /// 共享上下文，包含数据库连接与可选的 hot_group 客户端。
    pub inner: Arc<Services>,
}

impl GroupBizServiceImpl {
    pub fn new(inner: Arc<Services>) -> Self {
        Self { inner }
    }

    /// 获取当前时间戳（毫秒）。
    fn now_ms() -> i64 {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as i64
    }

    /// 构建 hot_group 客户端，没有配置时返回 UNAVAILABLE，避免静默失败。
    fn hot_client(&self) -> Result<crate::service::hot_group_client::HgGroupClient, Status> {
        self.inner
            .group_client()
            .cloned()
            .ok_or_else(|| Status::unavailable("group_service client not configured"))
    }

    fn kafka(&self) -> Option<&Arc<KafkaInstanceService>> {
        self.inner.kafka()
    }

    /// 去除空白字符串，辅助填充 proto optional 字段。
    fn normalize_optional(s: &str) -> Option<String> {
        let trimmed = s.trim();
        if trimmed.is_empty() {
            None
        } else {
            Some(trimmed.to_string())
        }
    }

    /// 从 hot_group 查询群资料，若不存在则返回 NOT_FOUND。
    async fn ensure_group(
        &self,
        client: &mut crate::service::hot_group_client::HgGroupClient,
        group_id: i64,
    ) -> Result<hotpb::GroupInfo, Status> {
        let resp = client
            .get_group(Request::new(HotIdReq { ref_id: group_id }))
            .await?;
        Ok(resp.into_inner())
    }

    /// 统一处理 hot_group CommonResp。
    fn map_common_resp(resp: HotCommonResp, default_err: &str) -> Result<(), Status> {
        if resp.success {
            Ok(())
        } else if resp.message.is_empty() {
            Err(Status::failed_precondition(default_err))
        } else {
            Err(Status::failed_precondition(resp.message))
        }
    }

    /// 将一条操作记录写入 `group_action_log` 表。
    async fn log_action<T>(
        &self,
        group_id: i64,
        operator_id: i64,
        target_id: Option<i64>,
        event: &str,
        payload: Option<T>,
    ) -> Result<(), Status>
    where
        T: serde::Serialize,
    {
        let row = GroupActionLogRow {
            id: build_snow_id(),
            group_id,
            event_type: event.to_string(),
            operator_id,
            target_id,
            payload,
            created_at: Self::now_ms(),
        };
        insert_group_action_log(self.inner.pool(), &row)
            .await
            .map_err(|e| Status::internal(format!("insert_group_action_log: {e}")))
    }

    /// 通过 get_all 拉取群成员角色（当前热层未提供精确查询接口）。
    async fn fetch_member_role(
        &self,
        client: &mut crate::service::hot_group_client::HgGroupClient,
        group_id: i64,
        user_id: i64,
    ) -> Result<Option<i32>, Status> {
        let members = client
            .get_all(Request::new(HotGetAllReq { group_id }))
            .await?
            .into_inner()
            .members;
        Ok(members
            .into_iter()
            .find(|m| m.id == user_id)
            .map(|m| m.role))
    }

    /// hot_group MemberRef -> msg_group proto
    fn map_remote_member(member: hotpb::MemberRef) -> MemberRef {
        MemberRef {
            id: member.id,
            alias: member.alias,
            role: member.role,
        }
    }

    /// hot_group GroupInfo -> msg_group proto
    fn map_remote_group(info: hotpb::GroupInfo) -> GroupInfo {
        GroupInfo {
            id: info.id,
            name: info.name,
            avatar: info.avatar,
            description: info.description,
            notice: info.notice,
            join_permission: info.join_permission,
            owner_id: info.owner_id,
            group_type: info.group_type,
            allow_search: info.allow_search,
            enable: info.enable,
            create_time: info.create_time,
            update_time: info.update_time,
            member_cnt: info.member_cnt,
        }
    }

    async fn notify_join_request(
        &self,
        admins: &[HotMemberRef],
        notice: &JoinRequestNotice,
        applicant_id: i64,
    ) {
        for admin in admins {
            if admin.id == applicant_id {
                continue;
            }
            if let Err(err) = push_socket_message(
                self.kafka(),
                admin.id,
                Some(notice.group_id),
                SocketMsgKind::MkGroupJoinRequest,
                notice,
                true,
            )
            .await
            {
                warn!(
                    "push join request notice to admin {} failed: {}",
                    admin.id, err
                );
            }
        }
    }

    async fn push_join_request_result(
        &self,
        group_id: i64,
        applicant_id: i64,
        operator_id: i64,
        accepted: bool,
        remark: Option<String>,
        handled_at: i64,
    ) {
        let notice = JoinRequestHandledNotice {
            group_id,
            applicant_id,
            operator_id,
            accepted,
            remark: remark.unwrap_or_default(),
            handled_at,
        };

        if let Err(err) = push_socket_message(
            self.kafka(),
            applicant_id,
            Some(group_id),
            SocketMsgKind::MkGroupJoinRequestAck,
            &notice,
            true,
        )
        .await
        {
            warn!(
                "push join request ack to user {} failed: {}",
                applicant_id, err
            );
        }
    }

    async fn broadcast_member_added(
        &self,
        client: &mut crate::service::hot_group_client::HgGroupClient,
        group_id: i64,
        operator_id: i64,
        member_id: i64,
        reason: &str,
    ) -> Result<(), Status> {
        let members = client
            .get_all(Request::new(HotGetAllReq { group_id }))
            .await?
            .into_inner()
            .members;

        let event_time = Self::now_ms();
        let member_proto = members
            .iter()
            .find(|m| m.id == member_id)
            .cloned()
            .unwrap_or(HotMemberRef {
                id: member_id,
                alias: None,
                role: hotpb::GroupRoleType::Member as i32,
            });
        let notice = GroupMemberChangeNotice {
            group_id,
            operator_id,
            member: Some(Self::map_remote_member(member_proto)),
            reason: reason.to_string(),
            event_time,
        };

        for member in members {
            if let Err(err) = push_socket_message(
                self.kafka(),
                member.id,
                Some(group_id),
                SocketMsgKind::MkGroupMemberAdd,
                &notice,
                false,
            )
            .await
            {
                warn!("broadcast member_add to user {} failed: {}", member.id, err);
            }
        }

        Ok(())
    }
}

#[tonic::async_trait]
impl GroupBizService for GroupBizServiceImpl {
    /// 创建群：写入 hot_group，并补充操作日志。
    async fn create_group(
        &self,
        request: Request<CreateGroupReq>,
    ) -> Result<Response<CreateGroupResp>, Status> {
        let req = request.into_inner();
        let name = req.name.trim();
        if name.is_empty() {
            return Err(Status::invalid_argument("group name required"));
        }

        let mut client = self.hot_client()?;
        let group_id = build_snow_id();
        let hot_req = HotCreateGroupReq {
            id: group_id,
            creator_uid: req.creator_id,
            name: name.to_string(),
            members: req.members.clone(),
            avatar: Self::normalize_optional(&req.avatar),
            intro: Self::normalize_optional(&req.intro),
        };
        let resp = client
            .create_group(Request::new(hot_req))
            .await?
            .into_inner();
        Self::map_common_resp(resp, "create_group failed")?;

        self.log_action(
            group_id,
            req.creator_id,
            None,
            "group_created",
            Some(json!({
                "members": req.members,
                "avatar": req.avatar,
                "intro": req.intro,
            })),
        )
        .await?;

        Ok(Response::new(CreateGroupResp { group_id }))
    }

    /// 更新群资料，保持热层与审计同步。
    async fn update_group_profile(
        &self,
        request: Request<UpdateGroupProfileReq>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;
        let hot_req = HotUpdateGroupProfileReq {
            operator_uid: req.operator_id,
            group_id: req.group_id,
            name: Self::normalize_optional(&req.name),
            avatar: Self::normalize_optional(&req.avatar),
            intro: Self::normalize_optional(&req.intro),
        };
        let resp = client
            .update_group_profile(Request::new(hot_req))
            .await?
            .into_inner();
        Self::map_common_resp(resp, "update_group_profile failed")?;

        self.log_action(
            req.group_id,
            req.operator_id,
            None,
            "group_profile_updated",
            Some(json!({
                "name": req.name,
                "avatar": req.avatar,
                "intro": req.intro,
            })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 解散群：验证群主身份后调用 hot_group。
    async fn dismiss_group(
        &self,
        request: Request<DismissGroupReq>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;

        let owner_role = self
            .fetch_member_role(&mut client, req.group_id, req.operator_id)
            .await?;
        if owner_role != Some(GroupRoleType::Owner as i32) {
            return Err(Status::permission_denied("only owner can dismiss group"));
        }

        let hot_req = HotDismissGroupReq {
            id: build_snow_id(),
            owner_uid: req.operator_id,
            group_id: req.group_id,
        };
        let resp = client
            .dismiss_group(Request::new(hot_req))
            .await?
            .into_inner();
        Self::map_common_resp(resp, "dismiss_group failed")?;

        self.log_action(
            req.group_id,
            req.operator_id,
            None,
            "group_dismissed",
            Some(json!({ "reason": "owner_dismiss" })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 提交或自动处理加群申请。
    async fn join_group(&self, request: Request<JoinGroupReq>) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;
        let group_info = self.ensure_group(&mut client, req.group_id).await?;

        let join_permission = hotpb::JoinPermission::try_from(group_info.join_permission)
            .unwrap_or(hotpb::JoinPermission::NeedApproval);

        let now = Self::now_ms();
        let existing = get_join_request(self.inner.pool(), req.group_id, req.user_id)
            .await
            .map_err(|e| Status::internal(format!("get_join_request: {e}")))?;

        let current_members = client
            .get_all(Request::new(HotGetAllReq {
                group_id: req.group_id,
            }))
            .await?
            .into_inner()
            .members;
        if current_members.iter().any(|m| m.id == req.user_id) {
            return Err(Status::already_exists("user already in group"));
        }

        let admins = client
            .get_managers(Request::new(HotGetManagersReq {
                group_id: req.group_id,
            }))
            .await?
            .into_inner()
            .managers;

        let inviter_is_manager =
            req.inviter_id > 0 && admins.iter().any(|m| m.id == req.inviter_id);
        let mut auto_join = false;
        let mut auto_decider = 0_i64;
        let mut auto_reason = String::from("auto_join");

        match join_permission {
            hotpb::JoinPermission::Anyone => {
                auto_join = true;
                auto_reason = String::from("auto_anyone");
            }
            hotpb::JoinPermission::NeedApproval => {
                if inviter_is_manager {
                    auto_join = true;
                    auto_decider = req.inviter_id;
                    auto_reason = String::from("admin_invite");
                }
            }
            hotpb::JoinPermission::InviteOnly => {
                if inviter_is_manager {
                    auto_join = true;
                    auto_decider = req.inviter_id;
                    auto_reason = String::from("admin_invite");
                } else {
                    return Err(Status::permission_denied("group requires invitation"));
                }
            }
            hotpb::JoinPermission::Closed => {
                if inviter_is_manager {
                    auto_join = true;
                    auto_decider = req.inviter_id;
                    auto_reason = String::from("admin_invite");
                } else {
                    return Err(Status::permission_denied("group is closed"));
                }
            }
        }

        let join_request_id = existing
            .as_ref()
            .map(|r| r.id)
            .unwrap_or_else(build_snow_id);
        let auto_remark = if auto_join {
            Some(auto_reason.clone())
        } else {
            None
        };

        let row = GroupJoinRequestRow {
            id: join_request_id,
            group_id: req.group_id,
            applicant_id: req.user_id,
            extra: Self::normalize_optional(&req.extra),
            join_source: Self::normalize_optional(&req.join_source),
            inviter_id: if req.inviter_id > 0 {
                Some(req.inviter_id)
            } else {
                None
            },
            inviter_extra: Self::normalize_optional(&req.inviter_extra),
            inviter_join_source: Self::normalize_optional(&req.inviter_join_source),
            join_time_ms: if req.join_time_ms > 0 {
                req.join_time_ms
            } else {
                now
            },
            status: if auto_join {
                JoinRequestStatus::Approved
            } else {
                JoinRequestStatus::Pending
            },
            remark: auto_remark.clone(),
            decided_by: if auto_join {
                Some(if auto_decider > 0 { auto_decider } else { 0 })
            } else {
                None
            },
            decided_at: if auto_join { Some(now) } else { None },
            created_at: existing.as_ref().map(|r| r.created_at).unwrap_or(now),
            updated_at: now,
        };

        upsert_join_request(self.inner.pool(), &row)
            .await
            .map_err(|e| Status::internal(format!("upsert_join_request: {e}")))?;

        self.log_action(
            req.group_id,
            req.user_id,
            Some(req.user_id),
            "join_requested",
            Some(json!({
                "extra": req.extra,
                "join_source": req.join_source,
                "inviter_id": req.inviter_id,
            })),
        )
        .await?;

        if auto_join {
            let insert_req = HotInsertReq {
                group_id: req.group_id,
                member: Some(HotMemberRef {
                    id: req.user_id,
                    alias: None,
                    role: hotpb::GroupRoleType::Member as i32,
                }),
            };
            client.insert(Request::new(insert_req)).await?;

            self.log_action(
                req.group_id,
                if auto_decider > 0 {
                    auto_decider
                } else {
                    req.user_id
                },
                Some(req.user_id),
                "member_joined",
                Some(json!({ "mode": auto_reason })),
            )
            .await?;

            self.push_join_request_result(
                req.group_id,
                req.user_id,
                auto_decider,
                true,
                auto_remark,
                now,
            )
            .await;

            self.broadcast_member_added(
                &mut client,
                req.group_id,
                if auto_decider > 0 {
                    auto_decider
                } else {
                    req.user_id
                },
                req.user_id,
                &auto_reason,
            )
            .await?;

            return Ok(Response::new(()));
        }

        let notice = JoinRequestNotice {
            group_id: req.group_id,
            group_name: group_info.name.clone(),
            applicant_id: req.user_id,
            extra: req.extra.clone(),
            join_source: req.join_source.clone(),
            inviter_id: req.inviter_id,
            inviter_extra: req.inviter_extra.clone(),
            request_time: now,
        };

        self.notify_join_request(&admins, &notice, req.user_id)
            .await;

        Ok(Response::new(()))
    }

    /// 成员主动退群。
    async fn leave_group(&self, request: Request<LeaveGroupReq>) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;

        let resp = client
            .remove(Request::new(HotRemoveReq {
                group_id: req.group_id,
                user_id: req.user_id,
            }))
            .await?
            .into_inner();
        if !resp.removed {
            return Err(Status::not_found("member not found"));
        }

        self.log_action(
            req.group_id,
            req.user_id,
            Some(req.user_id),
            "member_left",
            Some(json!({ "reason": req.reason })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 审批加群请求，支持拒绝与通过两种路径。
    async fn approve_join(&self, request: Request<ApproveJoinReq>) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;
        let remark_trimmed = Self::normalize_optional(&req.remark);

        let join_req = get_join_request(self.inner.pool(), req.group_id, req.applicant_id)
            .await
            .map_err(|e| Status::internal(format!("get_join_request: {e}")))?
            .ok_or_else(|| Status::not_found("join request not found"))?;
        if join_req.status != JoinRequestStatus::Pending {
            return Err(Status::failed_precondition("join request already decided"));
        }

        if !req.accept {
            let now = Self::now_ms();
            update_join_request_status(
                self.inner.pool(),
                req.group_id,
                req.applicant_id,
                JoinRequestStatus::Rejected,
                req.operator_id,
                now,
                remark_trimmed.clone(),
            )
            .await
            .map_err(|e| Status::internal(format!("update_join_request_status: {e}")))?;

            self.log_action(
                req.group_id,
                req.operator_id,
                Some(req.applicant_id),
                "join_rejected",
                Some(json!({
                    "remark": remark_trimmed.clone().unwrap_or_default()
                })),
            )
            .await?;
            self.push_join_request_result(
                req.group_id,
                req.applicant_id,
                req.operator_id,
                false,
                remark_trimmed.clone(),
                now,
            )
            .await;
            return Ok(Response::new(()));
        }

        let insert_req = HotInsertReq {
            group_id: req.group_id,
            member: Some(HotMemberRef {
                id: req.applicant_id,
                alias: None,
                role: hotpb::GroupRoleType::Member as i32,
            }),
        };
        client.insert(Request::new(insert_req)).await?;

        let now = Self::now_ms();
        update_join_request_status(
            self.inner.pool(),
            req.group_id,
            req.applicant_id,
            JoinRequestStatus::Approved,
            req.operator_id,
            now,
            remark_trimmed.clone(),
        )
        .await
        .map_err(|e| Status::internal(format!("update_join_request_status: {e}")))?;

        self.log_action(
            req.group_id,
            req.operator_id,
            Some(req.applicant_id),
            "join_approved",
            Some(json!({
                "remark": remark_trimmed.clone().unwrap_or_default()
            })),
        )
        .await?;
        self.push_join_request_result(
            req.group_id,
            req.applicant_id,
            req.operator_id,
            true,
            remark_trimmed.clone(),
            now,
        )
        .await;
        self.broadcast_member_added(
            &mut client,
            req.group_id,
            req.operator_id,
            req.applicant_id,
            "approval",
        )
        .await?;
        self.log_action(
            req.group_id,
            req.applicant_id,
            Some(req.applicant_id),
            "member_joined",
            Some(json!({ "mode": "approval" })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 批量邀请成员，直接写入热层。
    async fn invite_members(
        &self,
        request: Request<InviteMembersReq>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        if req.invitee_ids.is_empty() {
            return Ok(Response::new(()));
        }

        let mut client = self.hot_client()?;
        let members: Vec<HotMemberRef> = req
            .invitee_ids
            .iter()
            .copied()
            .map(|uid| HotMemberRef {
                id: uid,
                alias: None,
                role: hotpb::GroupRoleType::Member as i32,
            })
            .collect();
        let insert_many = HotInsertManyReq {
            group_id: req.group_id,
            members,
        };
        client.insert_many(Request::new(insert_many)).await?;

        let mut seen = HashSet::new();
        for uid in req.invitee_ids.iter().copied() {
            if seen.insert(uid) {
                if let Err(err) = self
                    .broadcast_member_added(
                        &mut client,
                        req.group_id,
                        req.operator_id,
                        uid,
                        "invite",
                    )
                    .await
                {
                    warn!(
                        "broadcast member_add for invited user {} failed: {}",
                        uid, err
                    );
                }
            }
        }

        self.log_action(
            req.group_id,
            req.operator_id,
            None,
            "members_invited",
            Some(json!({ "invitees": req.invitee_ids, "extra": req.extra })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 踢人操作，校验操作者权限及目标身份。
    async fn kick_member(&self, request: Request<KickMemberReq>) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;

        let operator_role = self
            .fetch_member_role(&mut client, req.group_id, req.operator_id)
            .await?;
        if !matches!(
            operator_role,
            Some(r) if r == GroupRoleType::Owner as i32 || r == GroupRoleType::Admin as i32
        ) {
            return Err(Status::permission_denied("insufficient privileges"));
        }

        let target_role = self
            .fetch_member_role(&mut client, req.group_id, req.target_id)
            .await?;
        if target_role == Some(GroupRoleType::Owner as i32) {
            return Err(Status::failed_precondition("cannot remove owner"));
        }

        let resp = client
            .remove(Request::new(HotRemoveReq {
                group_id: req.group_id,
                user_id: req.target_id,
            }))
            .await?
            .into_inner();
        if !resp.removed {
            return Err(Status::not_found("member not found"));
        }

        self.log_action(
            req.group_id,
            req.operator_id,
            Some(req.target_id),
            "member_removed",
            Some(json!({ "reason": req.reason })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 更新群内备注（别名）。
    async fn update_member_alias(
        &self,
        request: Request<UpdateMemberAliasReq>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;

        let alias = Self::normalize_optional(&req.alias);
        client
            .change_alias(Request::new(HotChangeAliasReq {
                group_id: req.group_id,
                user_id: req.target_id,
                alias,
            }))
            .await?;

        self.log_action(
            req.group_id,
            req.operator_id,
            Some(req.target_id),
            "member_alias_updated",
            Some(json!({ "alias": req.alias })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 变更成员角色，仅限群主。
    async fn change_member_role(
        &self,
        request: Request<ChangeMemberRoleReq>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        if !(0..=2).contains(&req.role) {
            return Err(Status::invalid_argument("invalid role"));
        }

        let mut client = self.hot_client()?;
        let operator_role = self
            .fetch_member_role(&mut client, req.group_id, req.operator_id)
            .await?;
        if operator_role != Some(GroupRoleType::Owner as i32) {
            return Err(Status::permission_denied("only owner can change roles"));
        }

        client
            .change_role(Request::new(HotChangeRoleReq {
                group_id: req.group_id,
                user_id: req.target_id,
                role: req.role,
            }))
            .await?;

        self.log_action(
            req.group_id,
            req.operator_id,
            Some(req.target_id),
            "member_role_changed",
            Some(json!({ "role": req.role })),
        )
        .await?;
        Ok(Response::new(()))
    }

    /// 查询群资料。
    async fn get_group(
        &self,
        request: Request<GetGroupReq>,
    ) -> Result<Response<GroupInfo>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;
        let info = self.ensure_group(&mut client, req.group_id).await?;
        Ok(Response::new(Self::map_remote_group(info)))
    }

    /// 分页返回群成员。
    async fn get_members(
        &self,
        request: Request<GetMembersReq>,
    ) -> Result<Response<GetMembersResp>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;
        let resp = client
            .get_page(Request::new(HotGetPageReq {
                group_id: req.group_id,
                page: req.page as u64,
                page_size: req.page_size as u64,
            }))
            .await?
            .into_inner();
        let members = resp
            .members
            .into_iter()
            .map(Self::map_remote_member)
            .collect::<Vec<_>>();

        let count = client
            .count(Request::new(HotCountReq {
                group_id: req.group_id,
            }))
            .await?
            .into_inner()
            .count;

        Ok(Response::new(GetMembersResp {
            members,
            total: count,
        }))
    }

    /// 统计成员总数。
    async fn count_members(
        &self,
        request: Request<CountMembersReq>,
    ) -> Result<Response<CountMembersResp>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;
        let count = client
            .count(Request::new(HotCountReq {
                group_id: req.group_id,
            }))
            .await?
            .into_inner()
            .count;
        Ok(Response::new(CountMembersResp { count }))
    }

    /// 查询用户加入的所有群。
    async fn user_groups(
        &self,
        request: Request<UserGroupsReq>,
    ) -> Result<Response<UserGroupsResp>, Status> {
        let req = request.into_inner();
        let mut client = self.hot_client()?;
        let resp = client
            .user_groups(Request::new(hotpb::UserGroupsReq {
                user_id: req.user_id,
            }))
            .await?
            .into_inner();
        Ok(Response::new(UserGroupsResp {
            group_ids: resp.group_ids,
        }))
    }
}
