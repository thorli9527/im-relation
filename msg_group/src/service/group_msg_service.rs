//! 群消息业务实现。
//!
//! - 只负责好友消息域的存储与快照维护，把来自 app_socket 的 `DomainMessage` 写入 `message_info` 表并更新会话快照；
//! - 目前无状态/ACK 机制（占位），`HandleGroupEvent` 逻辑已搬空，仅保留最小必要的内容路由；
//! - 其他群业务（审批、事件派发等）由上游服务或 `GroupBizService` 处理（如需恢复可以在此处补充）。

use std::convert::TryFrom;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use common::infra::grpc::grpc_group::group_service::{
    self as hotpb, CommonResp as HotCommonResp, CreateGroupReq as HotCreateGroupReq,
    GetManagersReq as HotGetManagersReq, InsertManyReq as HotInsertManyReq,
    InsertReq as HotInsertReq, MemberRef as HotMemberRef,
};
use common::infra::grpc::message::{
    self as msg_message, Content, DomainMessage, QueryGroupMessagesRequest, QueryMessagesResponse,
};
use common::support::util::common_utils::build_snow_id;
use log::{info, warn};
use prost::Message;
use tonic::{Request, Response, Status};

use crate::{
    dao::{
        delete_group_conversation_snapshot, get_join_request, get_join_request_by_id,
        insert_group_message, list_group_conversation_snapshots, list_group_messages,
        update_join_request_status, upsert_group_conversation_snapshot, upsert_join_request,
        GroupConversationSnapshot, GroupJoinRequestRow, GroupMessageRecord, JoinRequestStatus,
    },
    server::Services,
    service::hot_group_client::HgGroupClient,
};
use common::infra::grpc::grpc_msg_group::msg_group_service as msgpb;
use common::infra::grpc::grpc_msg_group::msg_group_service::group_msg_service_server::GroupMsgService;

/// 群消息 gRPC 服务实现。
///
/// 每个 RPC 负责从 DB 读取/写入消息、快照，并保证数据一致性（如分页/边界判断）。
#[derive(Clone)]
pub struct GroupMsgServiceImpl {
    /// 共享上下文，主要用于获取 DB 连接池。
    inner: Arc<Services>,
}

impl GroupMsgServiceImpl {
    pub fn new(inner: Arc<Services>) -> Self {
        Self { inner }
    }

    /// 当前时间（毫秒）。
    fn now_ms() -> i64 {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as i64
    }

    fn hot_client(&self) -> Result<HgGroupClient, Status> {
        self.inner
            .group_client()
            .cloned()
            .ok_or_else(|| Status::unavailable("group_service client not configured"))
    }
}

#[tonic::async_trait]
impl GroupMsgService for GroupMsgServiceImpl {
    /// 分页读取群聊消息，限制在 1..=200 条，超出部分返回 `has_more` 标志。
    /// 支持 `before_message_id`/`before_timestamp` 作为历史游标，按照时间升序填充 `messages`。
    async fn list_group_messages(
        &self,
        request: Request<QueryGroupMessagesRequest>,
    ) -> Result<Response<QueryMessagesResponse>, Status> {
        let req = request.into_inner();
        let requested = if req.limit == 0 { 20 } else { req.limit };
        let limit = requested.max(1).min(200);
        let fetch_limit = (limit as usize).saturating_add(1);

        let rows = list_group_messages(
            self.inner.pool(),
            req.group_id,
            req.before_message_id.map(|id| id as i64),
            req.before_timestamp,
            fetch_limit,
        )
        .await
        .map_err(|e| Status::internal(format!("list_group_messages: {e}")))?;

        let mut messages = Vec::with_capacity(rows.len());
        let mut has_more = false;

        for (idx, rec) in rows.into_iter().enumerate() {
            if idx == limit as usize {
                has_more = true;
                break;
            }

            let content = Content::decode(rec.content.as_slice())
                .map_err(|e| Status::internal(format!("decode message failed: {e}")))?;
            // if content.msg_kind == 0 {
            //     content.msg_kind = rec.msg_kind;
            // }
            messages.push(content);
        }

        Ok(Response::new(QueryMessagesResponse { messages, has_more }))
    }

    /// 查询用户的会话快照，按照更新时间倒序（最近更新在前），并返回 `has_more` 辅助分页。
    async fn list_group_conversations(
        &self,
        request: Request<msgpb::ListGroupConversationsRequest>,
    ) -> Result<Response<msgpb::ListGroupConversationsResponse>, Status> {
        let req = request.into_inner();
        if req.uid == 0 {
            return Err(Status::invalid_argument("uid required"));
        }

        let requested = if req.limit == 0 { 20 } else { req.limit };
        let limit = requested.max(1).min(200);
        let fetch_limit = (limit as usize).saturating_add(1);
        let before_updated_at = if req.before_updated_at > 0 {
            Some(req.before_updated_at)
        } else {
            None
        };
        let before_group_id = if req.before_group_id > 0 {
            Some(req.before_group_id)
        } else {
            None
        };

        let rows = list_group_conversation_snapshots(
            self.inner.pool(),
            req.uid,
            before_updated_at,
            before_group_id,
            fetch_limit,
        )
        .await
        .map_err(|e| Status::internal(format!("list_group_conversation_snapshots: {e}")))?;

        let has_more = rows.len() > limit as usize;
        let mut snapshots = Vec::with_capacity(rows.len().min(limit as usize));
        for (idx, row) in rows.into_iter().enumerate() {
            if idx == limit as usize {
                break;
            }
            snapshots.push(msgpb::GroupConversationSnapshot {
                uid: row.uid,
                group_id: row.group_id,
                last_msg_id: row.last_msg_id,
                last_sender_id: row.last_sender_id,
                last_timestamp: row.last_timestamp,
                unread_count: row.unread_count.max(0) as u32,
                updated_at: row.updated_at,
                created_at: row.created_at,
            });
        }

        Ok(Response::new(msgpb::ListGroupConversationsResponse {
            snapshots,
            has_more,
        }))
    }

    /// 持久化客户端上报的 `DomainMessage` 并执行内容层面的日志/观察。
    /// - 仅在 `contents` 非空时写入，减少无效落库；
    /// - 写入后紧接 `process_group_contents`，为将来补 Kafka/审计/通知留出接口。
    async fn handle_group_message(
        &self,
        request: Request<DomainMessage>,
    ) -> Result<Response<()>, Status> {
        let domain = request.into_inner();
        info!(
            "handle_group_message scene={} group={} sender={}",
            domain.scene, domain.receiver_id, domain.sender_id
        );

        if let Some(biz) = domain.group_business.clone() {
            self.apply_group_business(&domain, biz).await?;
        }

        if !domain.contents.is_empty() {
            self.persist_group_message(&domain).await?;
            let mut client: Option<HgGroupClient> = None;
            self.process_group_contents(&mut client, &domain.contents)
                .await?;
        }

        Ok(Response::new(()))
    }

    /// 更新（或新增）群会话快照，确保浏览器/客户端能读取到最新的预览/未读计数。
    async fn upsert_group_conversation_snapshot(
        &self,
        request: Request<msgpb::UpsertGroupConversationSnapshotRequest>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let snapshot = req
            .snapshot
            .ok_or_else(|| Status::invalid_argument("snapshot required"))?;

        if snapshot.uid == 0 || snapshot.group_id == 0 {
            return Err(Status::invalid_argument("uid and group_id required"));
        }

        let now = Self::now_ms();
        let updated_at = if snapshot.updated_at > 0 {
            snapshot.updated_at
        } else {
            now
        };
        let created_at = if snapshot.created_at > 0 {
            snapshot.created_at
        } else {
            updated_at
        };

        let record = GroupConversationSnapshot {
            uid: snapshot.uid,
            group_id: snapshot.group_id,
            last_msg_id: snapshot.last_msg_id,
            last_sender_id: snapshot.last_sender_id,
            last_timestamp: snapshot.last_timestamp,
            unread_count: snapshot.unread_count as i32,
            created_at,
            updated_at,
        };

        upsert_group_conversation_snapshot(self.inner.pool(), &record)
            .await
            .map_err(|e| Status::internal(format!("upsert_group_conversation_snapshot: {e}")))?;

        Ok(Response::new(()))
    }

    /// 删除指定 uid/group_id 的快照（用户退出或手动清理时调用）。
    async fn delete_group_conversation_snapshot(
        &self,
        request: Request<msgpb::DeleteGroupConversationSnapshotRequest>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        if req.uid == 0 || req.group_id == 0 {
            return Err(Status::invalid_argument("uid and group_id required"));
        }

        delete_group_conversation_snapshot(self.inner.pool(), req.uid, req.group_id)
            .await
            .map_err(|e| Status::internal(format!("delete_group_conversation_snapshot: {e}")))?;

        Ok(Response::new(()))
    }
}
impl GroupMsgServiceImpl {
    async fn apply_group_business(
        &self,
        domain: &DomainMessage,
        biz: msg_message::GroupBusinessContent,
    ) -> Result<(), Status> {
        if let Some(action) = biz.action {
            match action {
                msg_message::group_business_content::Action::JoinRequest(payload) => {
                    self.handle_join_request(domain, payload).await?
                }
                msg_message::group_business_content::Action::JoinDecision(payload) => {
                    self.handle_join_decision(domain, payload).await?
                }
                msg_message::group_business_content::Action::Create(payload) => {
                    self.handle_group_create(domain, payload).await?
                }
            }
        }
        Ok(())
    }

    async fn handle_join_request(
        &self,
        _domain: &DomainMessage,
        payload: msg_message::GroupJoinRequestPayload,
    ) -> Result<(), Status> {
        let mut client = self.hot_client()?;
        let group_info = self.ensure_group(&mut client, payload.group_id).await?;
        let join_permission = hotpb::JoinPermission::try_from(group_info.join_permission)
            .unwrap_or(hotpb::JoinPermission::NeedApproval);

        let managers = client
            .get_managers(Request::new(HotGetManagersReq {
                group_id: payload.group_id,
            }))
            .await?
            .into_inner()
            .managers;
        let inviter_id = payload.via_member_ids.first().copied().unwrap_or(0);
        let inviter_is_manager = inviter_id > 0 && managers.iter().any(|m| m.id == inviter_id);

        let auto_join = matches!(join_permission, hotpb::JoinPermission::Anyone)
            || (inviter_is_manager
                && matches!(
                    join_permission,
                    hotpb::JoinPermission::NeedApproval
                        | hotpb::JoinPermission::InviteOnly
                        | hotpb::JoinPermission::Closed
                ));

        let now = Self::now_ms();
        let join_time_ms = Self::timestamp_to_ms(payload.created_at).max(now);
        let request_id = if payload.request_id > 0 {
            payload.request_id as i64
        } else {
            build_snow_id()
        };

        let existing = get_join_request(self.inner.pool(), payload.group_id, payload.applicant_id)
            .await
            .map_err(|e| Status::internal(format!("get_join_request: {e}")))?;

        let row = GroupJoinRequestRow {
            id: request_id,
            group_id: payload.group_id,
            applicant_id: payload.applicant_id,
            extra: Self::normalize_optional(&payload.reason),
            join_source: None,
            inviter_id: if inviter_id > 0 {
                Some(inviter_id)
            } else {
                None
            },
            inviter_extra: None,
            inviter_join_source: None,
            join_time_ms,
            status: if auto_join {
                JoinRequestStatus::Approved
            } else {
                JoinRequestStatus::Pending
            },
            remark: if auto_join {
                Some(if inviter_is_manager {
                    String::from("admin_invite")
                } else {
                    String::from("auto_anyone")
                })
            } else {
                None
            },
            decided_by: if auto_join {
                Some(if inviter_id > 0 {
                    inviter_id
                } else {
                    payload.applicant_id
                })
            } else {
                None
            },
            decided_at: if auto_join { Some(join_time_ms) } else { None },
            created_at: existing
                .as_ref()
                .map(|r| r.created_at)
                .unwrap_or(join_time_ms),
            updated_at: join_time_ms,
        };

        upsert_join_request(self.inner.pool(), &row)
            .await
            .map_err(|e| Status::internal(format!("upsert_join_request: {e}")))?;

        if auto_join {
            let insert_req = HotInsertReq {
                group_id: payload.group_id,
                member: Some(HotMemberRef {
                    id: payload.applicant_id,
                    alias: None,
                    role: hotpb::GroupRoleType::Member as i32,
                }),
            };
            client.insert(Request::new(insert_req)).await?;
        }

        Ok(())
    }

    async fn handle_join_decision(
        &self,
        domain: &DomainMessage,
        payload: msg_message::GroupJoinDecisionPayload,
    ) -> Result<(), Status> {
        let mut client = self.hot_client()?;
        let row = get_join_request_by_id(self.inner.pool(), payload.request_id as i64)
            .await
            .map_err(|e| Status::internal(format!("get_join_request: {e}")))?;
        let row = match row {
            Some(r) => r,
            None => {
                return Err(Status::not_found("join request not found"));
            }
        };

        if row.status != JoinRequestStatus::Pending {
            return Err(Status::failed_precondition("join request already decided"));
        }

        let now = Self::now_ms();
        let decided_at = Self::timestamp_to_ms(payload.decided_at).max(now);

        let status = if payload.approved {
            JoinRequestStatus::Approved
        } else {
            JoinRequestStatus::Rejected
        };

        let remark = Self::normalize_optional(&payload.remark);

        update_join_request_status(
            self.inner.pool(),
            payload.group_id,
            row.applicant_id,
            status,
            domain.sender_id,
            decided_at,
            remark.clone(),
        )
        .await
        .map_err(|e| Status::internal(format!("update_join_request_status: {e}")))?;

        if payload.approved {
            let mut member_ids = payload.approved_member_ids.clone();
            if member_ids.is_empty() {
                member_ids.push(row.applicant_id);
            }

            let members: Vec<HotMemberRef> = member_ids
                .into_iter()
                .map(|uid| HotMemberRef {
                    id: uid,
                    alias: None,
                    role: hotpb::GroupRoleType::Member as i32,
                })
                .collect();

            if members.len() == 1 {
                let insert_req = HotInsertReq {
                    group_id: payload.group_id,
                    member: Some(members.into_iter().next().unwrap()),
                };
                client.insert(Request::new(insert_req)).await?;
            } else {
                client
                    .insert_many(Request::new(HotInsertManyReq {
                        group_id: payload.group_id,
                        members,
                    }))
                    .await?;
            }
        }

        Ok(())
    }

    async fn handle_group_create(
        &self,
        domain: &DomainMessage,
        payload: msg_message::GroupCreateContent,
    ) -> Result<(), Status> {
        let mut client = self.hot_client()?;
        let name = payload.group_name.trim();
        if name.is_empty() {
            return Err(Status::invalid_argument("group name required"));
        }

        let members = payload
            .members
            .iter()
            .filter(|m| m.member_id != domain.sender_id)
            .map(|m| m.member_id)
            .collect();

        let hot_req = HotCreateGroupReq {
            id: build_snow_id(),
            creator_uid: domain.sender_id,
            name: name.to_string(),
            members,
            avatar: None,
            intro: Self::normalize_optional(&payload.notice),
            announcement: payload
                .event
                .as_ref()
                .and_then(|event| Self::normalize_optional(&event.reason)),
        };

        let resp = client
            .create_group(Request::new(hot_req))
            .await?
            .into_inner();
        self.map_hot_common(resp, "create_group failed")
    }

    fn normalize_optional(value: &str) -> Option<String> {
        let trimmed = value.trim();
        if trimmed.is_empty() {
            None
        } else {
            Some(trimmed.to_string())
        }
    }

    async fn ensure_group(
        &self,
        client: &mut HgGroupClient,
        group_id: i64,
    ) -> Result<hotpb::GroupInfo, Status> {
        client
            .get_group(Request::new(hotpb::IdReq { ref_id: group_id }))
            .await
            .map(|resp| resp.into_inner())
            .map_err(|e| Status::internal(format!("ensure_group failed: {}", e)))
    }

    fn map_hot_common(&self, resp: HotCommonResp, default_err: &str) -> Result<(), Status> {
        if resp.success {
            Ok(())
        } else if resp.message.is_empty() {
            Err(Status::failed_precondition(default_err.to_string()))
        } else {
            Err(Status::failed_precondition(resp.message))
        }
    }

    fn timestamp_to_ms(ts: i64) -> i64 {
        ts
    }
}
impl GroupMsgServiceImpl {
    /// 将 `DomainMessage` 对象序列化后写入 `group_message_info` 表，并同步更新会话快照。
    /// - message_id 不存在时使用 `snowflake` 补齐，避免重复写入；
    /// - 写入后立刻更新发送者的会话快照，保障客户端的“会话列表”展示与未读统计。
    async fn persist_group_message(&self, domain: &DomainMessage) -> Result<(), Status> {
        let now = Self::now_ms();
        let msg_id = domain
            .message_id
            .map(|id| id as i64)
            .unwrap_or_else(build_snow_id);
        let msg_no = domain.message_id.unwrap_or(msg_id as u64) as i64;

        let content = Content {
            message_id: domain.message_id,
            sender_id: domain.sender_id,
            receiver_id: domain.receiver_id,
            timestamp: domain.timestamp,
            scene: domain.scene,
            contents: domain.contents.clone(),
            friend_business: domain.friend_business.clone(),
            group_business: domain.group_business.clone(),
            ..Default::default()
        };

        let mut buf = Vec::with_capacity(content.encoded_len());
        content
            .encode(&mut buf)
            .map_err(|e| Status::internal(format!("encode group content failed: {e}")))?;

        let record = GroupMessageRecord {
            msg_id,
            group_id: domain.receiver_id,
            sender_id: domain.sender_id,
            timestamp_ms: domain.timestamp,
            created_at_ms: now,
            msg_no,
            content: buf,
        };

        insert_group_message(self.inner.pool(), &record)
            .await
            .map_err(|e| Status::internal(format!("insert_group_message: {e}")))?;

        let snapshot = GroupConversationSnapshot {
            uid: domain.sender_id,
            group_id: domain.receiver_id,
            last_msg_id: record.msg_id,
            last_sender_id: record.sender_id,
            last_timestamp: record.timestamp_ms,
            unread_count: 0,
            created_at: now,
            updated_at: now,
        };

        upsert_group_conversation_snapshot(self.inner.pool(), &snapshot)
            .await
            .map_err(|e| Status::internal(format!("update_group_snapshot: {e}")))?;

        Ok(())
    }
}

/// 当前只对内容 segment 进行简单日志记录；后续可在这里执行分发、审计、内容审查等逻辑。
impl GroupMsgServiceImpl {
    /// 解析每个内容段，重点处理 `GroupEventContent` 业务事件并进行权限核验。
    async fn process_group_contents(
        &self,
        client_opt: &mut Option<HgGroupClient>,
        contents: &[msg_message::MessageContent],
    ) -> Result<(), Status> {
        for segment in contents {
            if let Some(msg_message::message_content::Content::GroupEvent(event)) = &segment.content
            {
                self.handle_group_event(client_opt, event).await?;
            }
        }
        Ok(())
    }

    /// 对来自客户端/系统的群事件数据做角色校验，并在必要时记录违规情况。
    async fn handle_group_event(
        &self,
        client_opt: &mut Option<HgGroupClient>,
        event: &msg_message::GroupEventContent,
    ) -> Result<(), Status> {
        let client: &mut HgGroupClient = match client_opt {
            Some(ref mut c) => c,
            None => {
                let mut new_client = self.hot_client()?;
                *client_opt = Some(new_client);
                client_opt.as_mut().unwrap()
            }
        };

        let gid = event.group_id;
        let operator = event.operator_id;
        let role = self.member_role(client, gid, operator).await?;

        match event.payload.as_ref() {
            Some(msg_message::group_event_content::Payload::RoleChanged(payload)) => {
                self.ensure_owner(role, event, "GroupRoleChanged", payload.change_type)
                    .await?;
            }
            Some(msg_message::group_event_content::Payload::InfoUpdated(_)) => {
                self.ensure_admin_or_owner(role, event, "GroupInfoUpdated")
                    .await?;
            }
            Some(msg_message::group_event_content::Payload::MemberChanged(payload)) => {
                self.enforce_member_change(role, event, payload).await?;
            }
            Some(msg_message::group_event_content::Payload::MuteChanged(_))
            | Some(msg_message::group_event_content::Payload::BanChanged(_)) => {
                self.ensure_admin_or_owner(role, event, "Mute/Ban event")
                    .await?;
            }
            _ => {
                info!(
                    "group event unhandled operator={} event={:?}",
                    operator, event.payload
                );
            }
        }
        Ok(())
    }

    async fn member_role(
        &self,
        client: &mut HgGroupClient,
        group_id: i64,
        uid: i64,
    ) -> Result<Option<hotpb::GroupRoleType>, Status> {
        if uid == 0 {
            return Ok(None);
        }
        let resp = client
            .get_all(Request::new(hotpb::GetAllReq { group_id }))
            .await?
            .into_inner();
        for member in resp.members {
            if member.id == uid {
                return Ok(hotpb::GroupRoleType::from_i32(member.role));
            }
        }
        Ok(None)
    }

    async fn ensure_owner(
        &self,
        role: Option<hotpb::GroupRoleType>,
        event: &msg_message::GroupEventContent,
        label: &str,
        change_type: i32,
    ) -> Result<(), Status> {
        if role != Some(hotpb::GroupRoleType::Owner) {
            warn!(
                "{} ignored: operator={} role={:?} change_type={}",
                label, event.operator_id, role, change_type
            );
        }
        Ok(())
    }

    async fn ensure_admin_or_owner(
        &self,
        role: Option<hotpb::GroupRoleType>,
        event: &msg_message::GroupEventContent,
        label: &str,
    ) -> Result<(), Status> {
        match role {
            Some(hotpb::GroupRoleType::Owner) | Some(hotpb::GroupRoleType::Admin) => Ok(()),
            _ => {
                warn!(
                    "{} ignored: operator={} role={:?}",
                    label, event.operator_id, role
                );
                Ok(())
            }
        }
    }

    async fn enforce_member_change(
        &self,
        role: Option<hotpb::GroupRoleType>,
        event: &msg_message::GroupEventContent,
        payload: &msg_message::GroupMemberChanged,
    ) -> Result<(), Status> {
        use msg_message::group_member_changed::Action;
        match Action::from_i32(payload.action) {
            Some(Action::Approved) | Some(Action::Invited) | Some(Action::Kicked) => {
                if !self.is_admin_or_owner(role) {
                    warn!(
                        "member change requires admin/owner: operator={} role={:?} action={:?}",
                        event.operator_id, role, payload.action
                    );
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn is_admin_or_owner(&self, role: Option<hotpb::GroupRoleType>) -> bool {
        matches!(
            role,
            Some(hotpb::GroupRoleType::Owner) | Some(hotpb::GroupRoleType::Admin)
        )
    }
}
