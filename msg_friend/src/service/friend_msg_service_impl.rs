// 消息侧好友服务的实现：封装好友请求、自动通过、系统通知重试等逻辑。
use prost::Message as _;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::hash::Hasher as _;
use tonic::{
    transport::{Channel, Error as TransportError},
    Request, Response, Status,
};

use chrono::Utc;
use common::config::AppConfig;
use common::infra::grpc::{
    grpc_msg_friend::msg_friend_service as msgpb, message as msg_message, GrpcClientManager,
};
use common::support::util::common_utils::build_snow_id;
use futures::{stream::FuturesUnordered, StreamExt};
use log::{info, warn};
use once_cell::sync::OnceCell;
use std::time::Duration;
use tokio::sync::Mutex;
use tokio::time::sleep;

use crate::dao::{
    delete_friend_conversation_snapshot, get_friend_request_by_id,
    increment_friend_request_notify_retry, insert_encrypted_message, list_conversation_messages,
    list_friend_conversation_snapshots, list_friend_requests_pending_notify,
    mark_friend_request_decision, mark_friend_request_notified,
    upsert_friend_conversation_snapshot, upsert_friend_request, EncryptedMessageRecord,
    FriendConversationSnapshot, FriendRequestRow,
};
use crate::server::Services;
use common::infra::grpc::grpc_friend::friend_service::{
    friend_service_client::FriendServiceClient, AddFriendBothReq, GetFriendsDetailedReq,
    UpdateFriendBlacklistReq, UpdateFriendNicknameReq, UpdateFriendRemarkReq,
};
use common::infra::grpc::grpc_msg_friend::msg_friend_service::friend_msg_service_server::FriendMsgService;
use common::infra::grpc::grpc_msg_system::msg_system_service::system_msg_service_client::SystemMsgServiceClient;
use common::infra::grpc::grpc_user::online_service::{
    user_rpc_service_client::UserRpcServiceClient, GetUserReq,
};
use common::support::util::date_util::now;

fn make_conversation_id(a: i64, b: i64) -> i64 {
    let (min_id, max_id) = if a <= b { (a, b) } else { (b, a) };
    let key = format!("{}:{}", min_id, max_id);
    let mut hasher = twox_hash::XxHash64::with_seed(0);
    hasher.write(key.as_bytes());
    hasher.finish() as i64
}

static SYSTEM_MSG_MANAGER: OnceCell<
    GrpcClientManager<SystemMsgServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static USER_RPC_MANAGER: OnceCell<
    GrpcClientManager<UserRpcServiceClient<Channel>, TransportError>,
> = OnceCell::new();
static USER_LANG_CACHE: OnceCell<Mutex<HashMap<i64, (String, i64)>>> = OnceCell::new();

fn system_msg_manager(
) -> &'static GrpcClientManager<SystemMsgServiceClient<Channel>, TransportError> {
    SYSTEM_MSG_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            SystemMsgServiceClient::connect(endpoint).await
        })
    })
}

fn user_rpc_manager() -> &'static GrpcClientManager<UserRpcServiceClient<Channel>, TransportError> {
    USER_RPC_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            UserRpcServiceClient::connect(endpoint).await
        })
    })
}

fn user_lang_cache() -> &'static Mutex<HashMap<i64, (String, i64)>> {
    USER_LANG_CACHE.get_or_init(|| Mutex::new(HashMap::new()))
}

/// 后台重试好友业务系统通知的简单 worker：每 30 秒触发一次，处理尚未通知成功的记录。
pub async fn spawn_friend_business_notify_retry_task(services: Services) {
    tokio::spawn(async move {
        let mut ticker = tokio::time::interval(Duration::from_secs(30));
        loop {
            ticker.tick().await;
            if let Err(err) = retry_friend_business_notifications(&services).await {
                warn!("friend_business notify retry tick error: {}", err);
            }
        }
    });
}

/// 发送好友业务系统通知（依赖 msg_system），仅包装 gRPC 调用。
async fn send_friend_business_system_notify(
    biz: msg_message::FriendBusinessContent,
    sender_id: i64,
    receiver_id: i64,
) -> Result<(), String> {
    let cfg = AppConfig::get();
    let endpoint = match cfg
        .msg_system_endpoints()
        .iter()
        .filter_map(|e| e.resolved_url())
        .next()
    {
        Some(ep) => ep,
        None => {
            warn!("msg_system endpoint not configured; skip system notify");
            return Ok(());
        }
    };

    let endpoint = if endpoint.starts_with("http://") || endpoint.starts_with("https://") {
        endpoint
    } else {
        format!("http://{}", endpoint)
    };

    let client = system_msg_manager()
        .get(&endpoint)
        .await
        .map_err(|e| format!("connect msg_system failed: {e}"))?;

    let ts_ms = Utc::now().timestamp_millis();
    let domain = msg_message::DomainMessage {
        message_id: Some(build_snow_id() as u64),
        sender_id,
        receiver_id,
        timestamp: ts_ms,
        ts_ms,
        delivery: Some(msg_message::DeliveryOptions {
            require_ack: true,
            expire_ms: Some(24 * 3600 * 1000),
            max_retry: Some(5),
        }),
        scene: msg_message::ChatScene::Profile as i32,
        category: msg_message::MsgCategory::System as i32,
        contents: Vec::new(),
        friend_business: Some(biz),
        group_business: None,
        system_business: None,
    };

    let mut client = client.as_ref().clone();
    client
        .handle_system_message(Request::new(domain))
        .await
        .map(|_| ())
        .map_err(|e| format!("send to msg_system failed: {e}"))
}

fn build_add_friend_both_req(
    uid_a: i64,
    uid_b: i64,
    nickname_for_a: Option<String>,
    remark_for_a: Option<String>,
    nickname_for_b: Option<String>,
    remark_for_b: Option<String>,
    source: i32,
) -> AddFriendBothReq {
    AddFriendBothReq {
        uid_a,
        uid_b,
        nickname_for_a,
        remark_for_a,
        nickname_for_b,
        remark_for_b,
        source,
    }
}

#[inline]
fn clean_string(input: &str) -> String {
    input.trim().to_string()
}

#[inline]
fn non_empty_owned(input: &str) -> Option<String> {
    let trimmed = input.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

struct FriendBothContext {
    from_uid: i64,
    to_uid: i64,
    source: i32,
    nickname_for_from: Option<String>,
    remark_for_from: Option<String>,
    nickname_for_to: Option<String>,
    remark_for_to: Option<String>,
}

impl FriendBothContext {
    fn from_decision(stored: &FriendRequestRow, remark: &str, nickname: &str) -> Self {
        let peer_remark = non_empty_owned(remark).or_else(|| non_empty_owned(&stored.to_remark));
        let peer_nick =
            non_empty_owned(nickname).or_else(|| non_empty_owned(&stored.from_nickname));
        let requester_remark = non_empty_owned(&stored.from_remark);
        let requester_nick = non_empty_owned(&stored.to_nickname);

        FriendBothContext {
            from_uid: stored.from_uid,
            to_uid: stored.to_uid,
            source: stored.source,
            nickname_for_from: requester_nick,
            remark_for_from: requester_remark,
            nickname_for_to: peer_nick,
            remark_for_to: peer_remark,
        }
    }

    fn for_anyone(req: &msgpb::AddFriendAnyoneRequest) -> Self {
        let peer_nick = non_empty_owned(&req.to_nickname);
        let nick = non_empty_owned(&req.from_nickname);
        FriendBothContext {
            from_uid: req.from_uid,
            to_uid: req.to_uid,
            source: req.source,
            nickname_for_from: peer_nick.clone().or_else(|| nick.clone()),
            remark_for_from: non_empty_owned(&req.to_remark),
            nickname_for_to: nick,
            remark_for_to: non_empty_owned(&req.from_remark),
        }
    }

    fn into_req(self) -> AddFriendBothReq {
        build_add_friend_both_req(
            self.from_uid,
            self.to_uid,
            self.nickname_for_from,
            self.remark_for_from,
            self.nickname_for_to,
            self.remark_for_to,
            self.source,
        )
    }
}

async fn add_friend_both_once(
    client: &mut FriendServiceClient<Channel>,
    req: AddFriendBothReq,
    req_id: i64,
    ctx: &str,
) -> Result<(), Status> {
    client.add_friend_both(req).await.map(|_| ()).map_err(|e| {
        let level = if e.code() == tonic::Code::Unavailable {
            "retryable"
        } else {
            "error"
        };
        warn!(
            "{}: add_friend_both failed req_id={} level={} err={}",
            ctx, req_id, level, e
        );
        Status::internal(format!(
            "{ctx}: add_friend_both failed req_id={} err={e}",
            req_id
        ))
    })
}

async fn send_established_notify(from_uid: i64, to_uid: i64, at_ms: i64) -> Result<(), String> {
    let biz = msg_message::FriendBusinessContent {
        action: Some(msg_message::friend_business_content::Action::Established(
            msg_message::FriendEstablishedPayload {
                uid_a: from_uid,
                uid_b: to_uid,
                at_ms,
            },
        )),
    };
    // 双向发送系统消息，确保双方都能收到好友建立通知。
    let mut errors = Vec::new();

    if let Err(err) = send_friend_business_system_notify(biz.clone(), from_uid, to_uid).await {
        errors.push(format!("notify {}->{} failed: {}", from_uid, to_uid, err));
    }
    if let Err(err) = send_friend_business_system_notify(biz, to_uid, from_uid).await {
        errors.push(format!("notify {}->{} failed: {}", to_uid, from_uid, err));
    }

    if errors.is_empty() {
        Ok(())
    } else {
        Err(errors.join("; "))
    }
}

#[tonic::async_trait]
impl msgpb::friend_msg_service_server::FriendMsgService for Services {
    async fn list_friend_messages(
        &self,
        request: Request<msg_message::QueryFriendMessagesRequest>,
    ) -> Result<Response<msg_message::QueryMessagesResponse>, Status> {
        let req = request.into_inner();
        let requested = if req.limit == 0 { 20 } else { req.limit };
        let limit = requested.max(1).min(200);
        let fetch_limit = (limit as usize).saturating_add(1);

        let rows = list_conversation_messages(
            self.pool(),
            req.uid,
            req.friend_id,
            None,
            req.before_message_id.map(|id| id as i64),
            req.before_timestamp,
            fetch_limit,
        )
        .await
        .map_err(|e| Status::internal(format!("db error: {e}")))?;

        let mut messages = Vec::with_capacity(rows.len());
        let mut has_more = false;

        for (idx, rec) in rows.into_iter().enumerate() {
            if idx == limit as usize {
                has_more = true;
                break;
            }

            let content = msg_message::Content::decode(rec.content.as_slice())
                .map_err(|e| Status::internal(format!("decode message failed: {e}")))?;
            messages.push(content);
        }

        Ok(Response::new(msg_message::QueryMessagesResponse {
            messages,
            has_more,
        }))
    }

    async fn list_user_friend_messages(
        &self,
        request: Request<msgpb::ListUserFriendMessagesRequest>,
    ) -> Result<Response<msg_message::QueryMessagesResponse>, Status> {
        let req = request.into_inner();
        let requested = if req.limit == 0 { 200 } else { req.limit };
        let limit = requested.min(500);
        let since = if req.since_timestamp > 0 {
            Some(req.since_timestamp)
        } else {
            None
        };

        let friend_client = self
            .friend_client()
            .cloned()
            .ok_or_else(|| Status::failed_precondition("friend_service client unavailable"))?;

        let friends_resp = friend_client
            .clone()
            .get_friends_detailed(GetFriendsDetailedReq {
                uid: req.uid,
                apply_source: false,
                nickname: false,
                avatar: false,
            })
            .await
            .map_err(|e| {
                Status::internal(format!("friend_service get_friends_detailed failed: {e}"))
            })?
            .into_inner();

        let mut records = Vec::new();
        let per_friend_limit = (limit as usize).saturating_add(1);
        let mut exceeded = false;

        for entry in friends_resp.friends {
            let rows = list_conversation_messages(
                self.pool(),
                req.uid,
                entry.friend_id,
                since,
                None,
                None,
                per_friend_limit,
            )
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;
            if rows.len() == per_friend_limit {
                exceeded = true;
            }
            records.extend(rows);
        }

        records.sort_by(|a, b| b.msg_id.cmp(&a.msg_id));

        let mut has_more = exceeded || records.len() > limit as usize;
        if has_more {
            records.truncate(limit as usize);
            // recompute in case truncate removed the only indicator
            has_more = true;
        }

        let mut messages = Vec::with_capacity(records.len());
        for rec in records {
            let content = msg_message::Content::decode(rec.content.as_slice())
                .map_err(|e| Status::internal(format!("decode message failed: {e}")))?;
            messages.push(content);
        }

        Ok(Response::new(msg_message::QueryMessagesResponse {
            messages,
            has_more,
        }))
    }

    async fn list_friend_conversations(
        &self,
        request: Request<msgpb::ListFriendConversationsRequest>,
    ) -> Result<Response<msgpb::ListFriendConversationsResponse>, Status> {
        let req = request.into_inner();
        if req.owner_id == 0 {
            return Err(Status::invalid_argument("owner_id required"));
        }

        let requested = if req.limit == 0 { 20 } else { req.limit };
        let limit = requested.max(1).min(200);
        let fetch_limit = (limit as usize).saturating_add(1);
        let before_updated_at = if req.before_updated_at > 0 {
            Some(req.before_updated_at)
        } else {
            None
        };
        let before_conversation_id = if req.before_conversation_id > 0 {
            Some(req.before_conversation_id)
        } else {
            None
        };

        let rows = list_friend_conversation_snapshots(
            self.pool(),
            req.owner_id,
            before_updated_at,
            before_conversation_id,
            fetch_limit,
        )
        .await
        .map_err(|e| Status::internal(format!("db error: {e}")))?;

        let has_more = rows.len() > limit as usize;
        let mut snapshots = Vec::with_capacity(rows.len().min(limit as usize));
        for (idx, row) in rows.into_iter().enumerate() {
            if idx == limit as usize {
                break;
            }
            snapshots.push(msgpb::FriendConversationSnapshot {
                owner_id: row.owner_id,
                peer_id: row.peer_id,
                conversation_id: row.conversation_id,
                last_msg_id: row.last_msg_id,
                last_sender_id: row.last_sender_id,
                last_receiver_id: row.last_receiver_id,
                last_timestamp: row.last_timestamp,
                unread_count: row.unread_count.max(0) as u32,
                updated_at: row.updated_at,
                created_at: row.created_at,
            });
        }

        Ok(Response::new(msgpb::ListFriendConversationsResponse {
            snapshots,
            has_more,
        }))
    }

    async fn upsert_friend_conversation_snapshot(
        &self,
        request: Request<msgpb::UpsertFriendConversationSnapshotRequest>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        let snap = req
            .snapshot
            .ok_or_else(|| Status::invalid_argument("snapshot required"))?;

        if snap.owner_id == 0 || snap.peer_id == 0 {
            return Err(Status::invalid_argument("owner_id and peer_id required"));
        }

        let now = Utc::now().timestamp_millis();
        let updated_at = if snap.updated_at > 0 {
            snap.updated_at
        } else {
            now
        };
        let created_at = if snap.created_at > 0 {
            snap.created_at
        } else {
            updated_at
        };
        let conversation_id = if snap.conversation_id != 0 {
            snap.conversation_id
        } else {
            make_conversation_id(snap.owner_id, snap.peer_id)
        };

        let record = FriendConversationSnapshot {
            owner_id: snap.owner_id,
            peer_id: snap.peer_id,
            conversation_id,
            last_msg_id: snap.last_msg_id,
            last_sender_id: snap.last_sender_id,
            last_receiver_id: snap.last_receiver_id,
            last_timestamp: snap.last_timestamp,
            unread_count: snap.unread_count as i32,
            created_at,
            updated_at,
        };

        upsert_friend_conversation_snapshot(self.pool(), &record)
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;
        Ok(Response::new(()))
    }

    async fn delete_friend_conversation_snapshot(
        &self,
        request: Request<msgpb::DeleteFriendConversationSnapshotRequest>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        if req.owner_id == 0 || req.conversation_id == 0 {
            return Err(Status::invalid_argument(
                "owner_id and conversation_id required",
            ));
        }

        delete_friend_conversation_snapshot(self.pool(), req.owner_id, req.conversation_id)
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;

        Ok(Response::new(()))
    }

    async fn broadcast_profile_updates(
        &self,
        request: Request<msgpb::BroadcastProfileUpdatesReq>,
    ) -> Result<Response<()>, Status> {
        let req = request.into_inner();
        if req.sender_id == 0 {
            return Err(Status::invalid_argument("sender_id required"));
        }
        if req.contents.is_empty() {
            return Ok(Response::new(()));
        }
        let ts_ms = if req.ts_ms > 0 {
            req.ts_ms
        } else {
            Utc::now().timestamp_millis()
        };
        let require_ack = req.require_ack.unwrap_or(false);

        let mut tasks = FuturesUnordered::new();
        for fid in req.friend_ids {
            if fid == 0 {
                continue;
            }
            let contents = req.contents.clone();
            let svc = self.clone();
            tasks.push(async move {
                let mut attempt: u32 = 0;
                loop {
                    attempt += 1;
                    let domain = msg_message::DomainMessage {
                        message_id: Some(build_snow_id() as u64),
                        sender_id: req.sender_id,
                        receiver_id: fid,
                        timestamp: ts_ms,
                        ts_ms,
                        delivery: Some(msg_message::DeliveryOptions {
                            require_ack,
                            expire_ms: None,
                            max_retry: None,
                        }),
                        scene: msg_message::ChatScene::Profile as i32,
                        category: msg_message::MsgCategory::Friend as i32,
                        contents: contents.clone(),
                        friend_business: None,
                        group_business: None,
                        system_business: None,
                    };

                    let res = async {
                        svc.persist_contents(&domain).await?;
                        svc.process_contents(&domain.contents).await
                    }
                    .await;

                    match res {
                        Ok(_) => return Ok::<(), (i64, u32, Status)>(()),
                        Err(e) if attempt < 3 => {
                            warn!(
                                "broadcast_profile_updates retry {} for friend {}: {}",
                                attempt, fid, e
                            );
                            sleep(Duration::from_millis(50 * attempt as u64)).await;
                        }
                        Err(e) => {
                            return Err((fid, attempt, e));
                        }
                    }
                }
            });
        }
        while let Some(res) = tasks.next().await {
            if let Err((fid, attempt, e)) = res {
                warn!(
                    "broadcast_profile_updates failed for friend {} after {} attempts: {}",
                    fid, attempt, e
                );
            }
        }

        Ok(Response::new(()))
    }

    async fn handle_friend_message(
        &self,
        request: Request<msg_message::DomainMessage>,
    ) -> Result<Response<()>, Status> {
        let domain = request.into_inner();
        warn!(
            "handle_friend_message: scene={} message_id={:?}",
            domain.scene, domain.message_id
        );

        if !domain.contents.is_empty() {
            self.persist_contents(&domain).await?;
            self.process_contents(&domain.contents).await?;
        }

        let friend_business = domain.friend_business.as_ref();
        if domain.scene == msg_message::ChatScene::Single as i32 {
            if let Some(friend_business) = friend_business {
                process_friend_business(self, &domain, friend_business).await?;
            }
        }

        Ok(Response::new(()))
    }

    async fn get_friend_request(
        &self,
        request: Request<msgpb::GetFriendRequestRequest>,
    ) -> Result<Response<msgpb::GetFriendRequestResponse>, Status> {
        let req = request.into_inner();
        let Some(row) = get_friend_request_by_id(self.pool(), req.request_id as i64)
            .await
            .map_err(|e| Status::internal(format!("get friend request failed: {e}")))?
        else {
            return Err(Status::not_found("friend request not found"));
        };
        let resp = msgpb::GetFriendRequestResponse {
            request_id: row.id as u64,
            from_uid: row.from_uid,
            to_uid: row.to_uid,
            remark: row.from_remark,
            nickname: row.from_nickname,
            peer_remark: row.to_remark,
            peer_nickname: row.to_nickname,
            source: row.source,
        };
        Ok(Response::new(resp))
    }

    async fn submit_friend_request(
        &self,
        request: Request<msgpb::AddFriendRequestCommand>,
    ) -> Result<Response<msgpb::AddFriendRequestResponse>, Status> {
        let req = request.into_inner();
        if req.from_uid <= 0 || req.to_uid <= 0 {
            return Err(Status::invalid_argument("from_uid/to_uid must be positive"));
        }
        let ts_ms = Utc::now().timestamp_millis();
        let req_id = build_snow_id();
        let remark = req.remark.trim().to_string();
        let nickname = req.nickname.trim().to_string();
        let source = msg_message::FriendRequestSource::try_from(req.source)
            .unwrap_or(msg_message::FriendRequestSource::FrsUnknown);

        let row = FriendRequestRow {
            id: req_id,
            from_uid: req.from_uid,
            to_uid: req.to_uid,
            from_reason: req.reason,
            source: source as i32,
            from_remark: remark.clone(),
            from_nickname: nickname.clone(),
            to_remark: String::new(),
            to_nickname: String::new(),
            created_at: ts_ms,
            decided_at: None,
            accepted: None,
            notified_at: 0,
            notify_retry: 0,
        };
        upsert_friend_request(self.pool(), &row)
            .await
            .map_err(|e| Status::internal(format!("persist friend request failed: {e}")))?;

        let payload = msg_message::FriendRequestPayload {
            request_id: req_id as u64,
            from_uid: row.from_uid,
            to_uid: row.to_uid,
            reason: row.from_reason.clone(),
            source: row.source,
            created_at: row.created_at,
            remark: row.from_remark.clone(),
            nickname: row.from_nickname.clone(),
        };
        let biz = msg_message::FriendBusinessContent {
            action: Some(msg_message::friend_business_content::Action::Request(
                payload,
            )),
        };
        match send_friend_business_system_notify(biz, row.from_uid, row.to_uid).await {
            Ok(_) => {
                if let Err(err) = mark_friend_request_notified(self.pool(), row.id, ts_ms).await {
                    warn!(
                        "submit_friend_request: mark notified failed req_id={} err={}",
                        row.id, err
                    );
                }
            }
            Err(err) => {
                warn!(
                    "submit_friend_request: send notify failed req_id={} err={}",
                    row.id, err
                );
                let _ = increment_friend_request_notify_retry(self.pool(), row.id).await;
            }
        }

        Ok(Response::new(msgpb::AddFriendRequestResponse {
            request_id: req_id as u64,
        }))
    }

    //受理好友申请
    async fn decide_friend_request(
        &self,
        request: Request<msgpb::DecideFriendRequestCommand>,
    ) -> Result<Response<msgpb::DecideFriendRequestResponse>, Status> {
        let req = request.into_inner();
        // 基本校验：请求 ID 必填，批准人与存档的 to_uid 需一致（若提供）。
        if req.request_id == 0 {
            return Err(Status::invalid_argument("request_id required"));
        }

        let Some(stored) = get_friend_request_by_id(self.pool(), req.request_id as i64)
            .await
            .map_err(|e| Status::internal(format!("fetch friend request failed: {e}")))?
        else {
            return Err(Status::not_found("friend request not found"));
        };
        if req.approver_uid != 0 && req.approver_uid != stored.to_uid {
            return Err(Status::permission_denied("approver not match"));
        }
        let decided_at = Utc::now().timestamp_millis();
        let from_remark = clean_string(&req.remark);
        let from_nickname = clean_string(&req.nickname);

        // 落库受理结果，保持 remark/nickname 以便 UI 展示。
        mark_friend_request_decision(
            self.pool(),
            req.request_id as i64,
            decided_at,
            req.accept,
            stored.from_remark.clone(),
            from_remark.clone(),
            from_nickname.clone(),
        )
        .await
        .map_err(|e| Status::internal(format!("update friend request decision failed: {e}")))?;

        if req.accept {
            // 已通过：为审批方与申请方各写一条好友关系（双向）。
            let ctx = FriendBothContext::from_decision(
                &stored,
                from_remark.as_str(),
                from_nickname.as_str(),
            );
            let req_both = ctx.into_req();
            if let Some(mut friend_client) = self.friend_client().cloned() {
                if let Err(err) = add_friend_both_once(
                    &mut friend_client,
                    req_both,
                    req.request_id as i64,
                    "decide_friend_request",
                )
                .await
                {
                    warn!(
                        "decide_friend_request: add_friend_both failed req_id={} err={}",
                        req.request_id, err
                    );
                }
            } else {
                warn!(
                    "decide_friend_request: friend_service client unavailable req_id={}",
                    req.request_id
                );
            }

            // 同步“已建立好友关系”业务事件，驱动客户端入库好友。
            let mut notify_ok = true;
            if let Err(err) =
                send_established_notify(stored.from_uid, stored.to_uid, decided_at).await
            {
                warn!(
                    "decide_friend_request: send established failed req_id={} err={}",
                    req.request_id, err
                );
                notify_ok = false;
            }

            // 仅根据建立通知结果更新重试计数
            if notify_ok {
                if let Err(err) =
                    mark_friend_request_notified(self.pool(), req.request_id as i64, decided_at)
                        .await
                {
                    warn!(
                        "decide_friend_request: mark notified failed req_id={} err={}",
                        req.request_id, err
                    );
                    let _ = increment_friend_request_notify_retry(self.pool(), req.request_id as i64)
                        .await;
                }
            } else if let Err(err) =
                increment_friend_request_notify_retry(self.pool(), req.request_id as i64).await
            {
                warn!(
                    "decide_friend_request: mark notify retry failed req_id={} err={}",
                    req.request_id, err
                );
            }
        }

        Ok(Response::new(msgpb::DecideFriendRequestResponse { ok: true }))
    }

async fn add_friend_anyone(
    &self,
    request: Request<msgpb::AddFriendAnyoneRequest>,
) -> Result<Response<msgpb::AddFriendAnyoneResponse>, Status> {
    let req = request.into_inner();
    // Anyone 策略：收到即落申请、自动同意，保持与普通流程一致（请求+决策+建立）。
    if req.from_uid <= 0 || req.to_uid <= 0 {
        return Err(Status::invalid_argument("from_uid/to_uid must be positive"));
    }
        let mut friend_client = self
            .friend_client()
            .cloned()
            .ok_or_else(|| Status::failed_precondition("friend_service client unavailable"))?;
        let ts_ms = Utc::now().timestamp_millis();
        let req_id = build_snow_id();
        let from_remark = clean_string(&req.from_remark);
        let from_nickname = clean_string(&req.from_nickname);
        let to_remark = clean_string(&req.to_remark);
        let to_nickname = clean_string(&req.to_nickname);
        let source = msg_message::FriendRequestSource::try_from(req.source)
            .unwrap_or(msg_message::FriendRequestSource::FrsUnknown);

        let row = FriendRequestRow {
            id: req_id,
            from_uid: req.from_uid,
            to_uid: req.to_uid,
            from_reason: req.from_reason.clone(),
            source: source as i32,
            from_remark: from_remark.to_string(),
            from_nickname: from_nickname.clone(),
            to_remark: to_remark.to_string(),
            to_nickname: to_nickname.clone(),
            created_at: ts_ms,
            decided_at: Some(ts_ms),
            accepted: Some(true),
            notified_at: 0,
            notify_retry: 0,
        };
        // 1) 先把好友请求落库（用于重试/展示）
        upsert_friend_request(self.pool(), &row)
            .await
            .map_err(|e| Status::internal(format!("persist friend request failed: {e}")))?;

        // 2) 双向写入好友关系（幂等），保障通知与落库一致。
        let ctx = FriendBothContext::for_anyone(&req);
        let req_both = ctx.into_req();
        add_friend_both_once(&mut friend_client, req_both, row.id, "add_friend_anyone")
            .await
            .map_err(|e| {
                Status::internal(format!("add_friend_anyone: relation add failed: {e}"))
            })?;

        // 3) 省略请求通知（已自动通过）
        let mut notify_ok = true;

        // 自动通过：下发决策通知，复用客户端处理逻辑。
        if let Err(err) = send_established_notify(row.from_uid, row.to_uid, ts_ms).await {
            warn!(
                "add_friend_anyone: send established notify failed req_id={} err={}",
                row.id, err
            );
            notify_ok = false;
        }

        // 5) 根据通知结果重置或增加重试计数
        if notify_ok {
            if let Err(err) = mark_friend_request_notified(self.pool(), row.id, ts_ms).await {
                warn!(
                    "add_friend_anyone: mark notified failed req_id={} err={}",
                    row.id, err
                );
                // 标记失败也计入重试，让后台任务能再次尝试
                if let Err(e) = increment_friend_request_notify_retry(self.pool(), row.id).await {
                    warn!(
                        "add_friend_anyone: mark notify retry failed after mark error req_id={} err={}",
                        row.id, e
                    );
                }
            }
        } else {
            if let Err(err) = increment_friend_request_notify_retry(self.pool(), row.id).await {
                warn!(
                    "add_friend_anyone: mark notify retry failed req_id={} err={}",
                    row.id, err
                );
            }
        }

        Ok(Response::new(msgpb::AddFriendAnyoneResponse { ok: true }))
    }
}

/// 仅包装一次 add_friend_both 调用，带简单的错误分级日志。
impl Services {
    async fn persist_contents(&self, domain: &msg_message::DomainMessage) -> Result<(), Status> {
        let now = chrono::Utc::now().timestamp_millis();
        let msg_id = domain
            .message_id
            .map(|id| id as i64)
            .unwrap_or_else(build_snow_id);
        let msg_no = domain.message_id.unwrap_or(msg_id as u64) as i64;

        let content = msg_message::Content {
            // 确保下游拉取能拿到 message_id，用持久化后的 msg_id 回填。
            message_id: Some(msg_id as u64),
            sender_id: domain.sender_id,
            receiver_id: domain.receiver_id,
            timestamp: domain.timestamp,
            scene: domain.scene,
            contents: domain.contents.clone(),
            friend_business: domain.friend_business.clone(),
            group_business: domain.group_business.clone(),
            ..Default::default()
        };

        let mut buffer = Vec::with_capacity(content.encoded_len());
        content
            .encode(&mut buffer)
            .map_err(|e| Status::internal(format!("encode content failed: {e}")))?;

        let record = EncryptedMessageRecord {
            msg_id,
            sender_id: domain.sender_id,
            receiver_id: domain.receiver_id,
            created_at: now,
            scheme: String::new(),
            key_id: String::new(),
            nonce: Vec::new(),
            msg_no,
            aad: None,
            ciphertext: Vec::new(),
            content: buffer,
        };

        insert_encrypted_message(self.pool(), &record)
            .await
            .map_err(|e| Status::internal(format!("insert message failed: {e}")))?;

        let snapshot = FriendConversationSnapshot {
            owner_id: domain.sender_id,
            peer_id: domain.receiver_id,
            conversation_id: make_conversation_id(domain.sender_id, domain.receiver_id),
            last_msg_id: record.msg_id,
            last_sender_id: record.sender_id,
            last_receiver_id: record.receiver_id,
            last_timestamp: record.created_at,
            unread_count: 0,
            created_at: now,
            updated_at: now,
        };

        upsert_friend_conversation_snapshot(self.pool(), &snapshot)
            .await
            .map_err(|e| Status::internal(format!("update snapshot failed: {e}")))?;

        Ok(())
    }
}

impl Services {
    async fn process_contents(
        &self,
        contents: &[msg_message::MessageContent],
    ) -> Result<(), Status> {
        for segment in contents {
            if let Some(body) = &segment.content {
                match body {
                    msg_message::message_content::Content::Text(text) => {
                        info!("friend message text: {}", text.text);
                    }
                    msg_message::message_content::Content::Image(image) => {
                        info!("friend message image: {}", image.url);
                    }
                    msg_message::message_content::Content::FriendEvent(event) => {
                        self.handle_friend_event(event).await?;
                    }
                    _ => {
                        info!("friend message other segment");
                    }
                }
            }
        }
        Ok(())
    }

    async fn handle_friend_event(
        &self,
        event: &msg_message::FriendEventContent,
    ) -> Result<(), Status> {
        let friend_client = match self.friend_client() {
            Some(cli) => cli.clone(),
            None => {
                info!("friend event skipped; friend_service client missing");
                return Ok(());
            }
        };

        let event_type = msg_message::FriendEventType::try_from(event.r#type)
            .unwrap_or(msg_message::FriendEventType::FeUnspecified);
        match event_type {
            msg_message::FriendEventType::FeNicknameUpdated => {
                let nickname_value = event.nickname.clone().unwrap_or_default();
                let nickname_opt = if nickname_value.is_empty() {
                    None
                } else {
                    Some(nickname_value.clone())
                };
                let req = UpdateFriendNicknameReq {
                    uid: event.operator_id,
                    friend_id: event.friend_id,
                    nickname: nickname_opt.clone(),
                };
                friend_client
                    .clone()
                    .update_friend_nickname(Request::new(req))
                    .await
                    .map_err(|e| {
                        Status::internal(format!("update_friend_nickname failed: {}", e))
                    })?;
                info!(
                    "friend event: nickname updated operator={} friend={} nickname={:?}",
                    event.operator_id, event.friend_id, nickname_opt
                );
            }
            msg_message::FriendEventType::FeRemarkUpdated => {
                let remark_opt = event.remark.clone().filter(|s| !s.is_empty());
                let req = UpdateFriendRemarkReq {
                    uid: event.operator_id,
                    friend_id: event.friend_id,
                    remark: remark_opt.clone(),
                };
                friend_client
                    .clone()
                    .update_friend_remark(Request::new(req))
                    .await
                    .map_err(|e| Status::internal(format!("update_friend_remark failed: {}", e)))?;
                info!(
                    "friend event: remark update operator={} friend={} remark={:?}",
                    event.operator_id, event.friend_id, remark_opt
                );
            }
            msg_message::FriendEventType::FeBlacklistUpdated => {
                let blocked = parse_metadata_flag(&event.metadata, "blocked").unwrap_or(true);
                let reason_value = event.reason.clone();
                let reason_opt = if reason_value.trim().is_empty() {
                    None
                } else {
                    Some(reason_value)
                };
                let req = UpdateFriendBlacklistReq {
                    uid: event.operator_id,
                    friend_id: event.friend_id,
                    blocked,
                    reason: reason_opt.clone(),
                };
                friend_client
                    .clone()
                    .update_friend_blacklist(Request::new(req))
                    .await
                    .map_err(|e| {
                        Status::internal(format!("update_friend_blacklist failed: {}", e))
                    })?;
                info!(
                    "friend event: blacklist update operator={} friend={} blocked={} reason={:?}",
                    event.operator_id, event.friend_id, blocked, reason_opt
                );
            }
            _ => {
                info!(
                    "friend event: unknown type {:?} operator={} friend={}",
                    event_type, event.operator_id, event.friend_id
                );
            }
        }
        Ok(())
    }
}

async fn process_friend_business(
    svc: &Services,
    domain: &msg_message::DomainMessage,
    biz: &msg_message::FriendBusinessContent,
) -> Result<(), Status> {
    use msg_message::friend_business_content::Action;

    match &biz.action {
        Some(Action::Request(payload)) => {
            let remark = payload.remark.trim().to_string();
            let nickname = payload.nickname.trim().to_string();
            let row = FriendRequestRow {
                id: payload.request_id as i64,
                from_uid: payload.from_uid,
                to_uid: payload.to_uid,
                from_reason: payload.reason.clone(),
                source: payload.source as i32,
                from_remark: remark,
                from_nickname: nickname,
                to_remark: String::new(),
                to_nickname: String::new(),
                created_at: payload.created_at,
                decided_at: None,
                accepted: None,
                notified_at: 0,
                notify_retry: 0,
            };
            upsert_friend_request(svc.pool(), &row)
                .await
                .map_err(|e| Status::internal(format!("persist friend request failed: {e}")))?;

            let notify = msg_message::FriendBusinessContent {
                action: Some(Action::Request(payload.clone())),
            };
            let sender = if domain.sender_id != 0 {
                domain.sender_id
            } else {
                payload.from_uid
            };
            match send_friend_business_system_notify(notify, sender, payload.to_uid).await {
                Ok(_) => {
                    let ts = Utc::now().timestamp_millis();
                    if let Err(err) =
                        mark_friend_request_notified(svc.pool(), payload.request_id as i64, ts)
                            .await
                    {
                        warn!(
                            "friend_business: mark notified failed id={} err={}",
                            payload.request_id, err
                        );
                    } else {
                        info!(
                            "friend_business: stored request id={} from={} to={} notified_at={}",
                            payload.request_id, payload.from_uid, payload.to_uid, ts
                        );
                    }
                }
                Err(err) => {
                    warn!(
                        "friend_business: system notify failed id={} err={}",
                        payload.request_id, err
                    );
                    if let Err(e) =
                        increment_friend_request_notify_retry(svc.pool(), payload.request_id as i64)
                            .await
                    {
                        warn!(
                            "friend_business: notify retry mark failed id={} err={}",
                            payload.request_id, e
                        );
                    }
                }
            }
        }
        Some(Action::Decision(payload)) => {
            let decided_at = if payload.decided_at > 0 {
                payload.decided_at
            } else {
                Utc::now().timestamp_millis()
            };
            let stored = get_friend_request_by_id(svc.pool(), payload.request_id as i64)
                .await
                .map_err(|e| Status::internal(format!("fetch friend request failed: {e}")))?;
            let remark = stored
                .as_ref()
                .map(|r| r.from_remark.clone())
                .unwrap_or_else(|| payload.remark.clone());
            mark_friend_request_decision(
                svc.pool(),
                payload.request_id as i64,
                decided_at,
                payload.accepted,
                remark,
                payload.remark.clone(),
                payload.nickname.clone(),
            )
            .await
            .map_err(|e| Status::internal(format!("update friend request decision failed: {e}")))?;

            if payload.accepted {
                if let Some(friend_client) = svc.friend_client() {
                    let mut friend_client = friend_client.clone();
                    let (
                        from_uid,
                        to_uid,
                        source_val,
                        req_remark,
                        req_nick,
                        req_peer_remark,
                        req_peer_nick,
                    ) = if let Some(r) = stored.as_ref() {
                        (
                            r.from_uid,
                            r.to_uid,
                            r.source,
                            r.from_remark.clone(),
                            r.from_nickname.clone(),
                            r.to_remark.clone(),
                            r.to_nickname.clone(),
                        )
                    } else {
                        (
                            0,
                            0,
                            0,
                            String::new(),
                            String::new(),
                            String::new(),
                            String::new(),
                        )
                    };
                    let peer_remark = if !payload.remark.trim().is_empty() {
                        payload.remark.clone()
                    } else {
                        req_peer_remark.clone()
                    };
                    let approver_nick = if !payload.nickname.trim().is_empty() {
                        payload.nickname.clone()
                    } else {
                        req_nick.clone()
                    };
                    let requester_remark = req_remark;
                    let requester_nick = req_peer_nick;

                    if from_uid > 0 && to_uid > 0 {
                        let req_both = build_add_friend_both_req(
                            to_uid,
                            from_uid,
                            (!approver_nick.trim().is_empty()).then_some(approver_nick.clone()),
                            (!peer_remark.trim().is_empty()).then_some(peer_remark.clone()),
                            (!requester_nick.trim().is_empty()).then_some(requester_nick.clone()),
                            (!requester_remark.trim().is_empty())
                                .then_some(requester_remark.clone()),
                            source_val,
                        );
                        if let Err(err) = add_friend_both_once(
                            &mut friend_client,
                            req_both,
                            payload.request_id as i64,
                            "friend_business",
                        )
                        .await
                        {
                            warn!(
                                "friend_business: add_friend_both failed req_id={} err={}",
                                payload.request_id, err
                            );
                        }
                    }
                } else {
                    warn!("friend_business: friend_client unavailable, skip relation add");
                }
            }

            let notify = msg_message::FriendBusinessContent {
                action: Some(Action::Decision(payload.clone())),
            };
            let receiver = if domain.receiver_id != 0 {
                domain.receiver_id
            } else {
                domain.sender_id
            };
            match send_friend_business_system_notify(notify, domain.sender_id, receiver).await {
                Ok(_) => {
                    if let Err(err) = mark_friend_request_notified(
                        svc.pool(),
                        payload.request_id as i64,
                        decided_at,
                    )
                    .await
                    {
                        warn!(
                            "friend_business: mark decision notified failed id={} err={}",
                            payload.request_id, err
                        );
                    } else {
                        info!(
                            "friend_business: stored decision request_id={} accepted={} notified_at={}",
                            payload.request_id, payload.accepted, decided_at
                        );
                    }
                }
                Err(err) => {
                    warn!(
                        "friend_business: system notify decision failed id={} err={}",
                        payload.request_id, err
                    );
                    if let Err(e) =
                        increment_friend_request_notify_retry(svc.pool(), payload.request_id as i64)
                            .await
                    {
                        warn!(
                            "friend_business: decision notify retry mark failed id={} err={}",
                            payload.request_id, e
                        );
                    }
                }
            }

            // 受理通过后补发欢迎文本（各自根据语言生成）。
            if payload.accepted {
                if let Err(err) =
                    send_default_welcome_pair(svc, domain.sender_id, domain.receiver_id).await
                {
                    warn!(
                        "friend_business: send welcome text failed sender={} receiver={} err={}",
                        domain.sender_id, domain.receiver_id, err
                    );
                }
            }
        }
        _ => {
            warn!("friend_business: unknown action");
        }
    }

    Ok(())
}

async fn send_friend_text_message(
    svc: &Services,
    sender: i64,
    receiver: i64,
    text: &str,
) -> Result<(), Status> {
    if text.is_empty() {
        return Ok(());
    }
    let ts = now();
    let content = msg_message::MessageContent {
        content: Some(msg_message::message_content::Content::Text(
            msg_message::TextContent {
                text: text.to_string(),
                ..Default::default()
            },
        )),
    };
    let domain = msg_message::DomainMessage {
        message_id: Some(build_snow_id() as u64),
        sender_id: sender,
        receiver_id: receiver,
        timestamp: ts,
        ts_ms: ts,
        delivery: Some(msg_message::DeliveryOptions {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }),
        scene: msg_message::ChatScene::Single as i32,
        category: msg_message::MsgCategory::Friend as i32,
        contents: vec![content],
        friend_business: None,
        group_business: None,
        system_business: None,
    };
    svc.handle_friend_message(Request::new(domain))
        .await
        .map(|_| ())
        .map_err(|e| Status::internal(format!("send friend text failed: {e}")))
}

async fn send_default_welcome_pair(
    svc: &Services,
    sender: i64,
    receiver: i64,
) -> Result<(), String> {
    if sender <= 0 || receiver <= 0 {
        return Ok(());
    }
    let sender_lang = fetch_user_language(sender).await;
    let receiver_lang = fetch_user_language(receiver).await;
    let text_for_receiver = friend_welcome_text(receiver_lang.as_deref());
    let text_for_sender = friend_welcome_text(sender_lang.as_deref());

    send_friend_text_message(svc, sender, receiver, text_for_receiver)
        .await
        .map_err(|e| e.to_string())?;
    send_friend_text_message(svc, receiver, sender, text_for_sender)
        .await
        .map_err(|e| e.to_string())?;
    Ok(())
}

async fn fetch_user_language(uid: i64) -> Option<String> {
    let cfg = AppConfig::get();
    let now_ms = Utc::now().timestamp_millis();
    let ttl_ms: i64 = 5 * 60 * 1000;
    {
        let cache = user_lang_cache().lock().await;
        if let Some((lang, ts)) = cache.get(&uid) {
            if now_ms - *ts < ttl_ms {
                return Some(lang.clone());
            }
        }
    }

    let endpoint = match cfg
        .user_service_endpoints()
        .iter()
        .filter_map(|e| e.resolved_url())
        .next()
    {
        Some(ep) => ep,
        None => {
            warn!("user_service endpoint not configured; fallback to default language");
            return None;
        }
    };
    let endpoint = if endpoint.starts_with("http://") || endpoint.starts_with("https://") {
        endpoint
    } else {
        format!("http://{}", endpoint)
    };
    let client = match user_rpc_manager().get(&endpoint).await {
        Ok(c) => c,
        Err(err) => {
            warn!("user_service client unavailable: {err}");
            return None;
        }
    };
    let mut client = client.as_ref().clone();
    match client
        .find_user_by_id(Request::new(GetUserReq { id: uid }))
        .await
    {
        Ok(resp) => {
            let lang = resp.into_inner().language.unwrap_or_default();
            {
                let mut cache = user_lang_cache().lock().await;
                cache.insert(uid, (lang.clone(), now_ms));
            }
            if lang.is_empty() {
                None
            } else {
                Some(lang)
            }
        }
        Err(err) => {
            warn!(
                "user_service find_user_by_id failed uid={} err={}",
                uid, err
            );
            None
        }
    }
}

fn friend_welcome_text(lang: Option<&str>) -> &'static str {
    match lang.map(|s| s.to_lowercase()) {
        Some(ref l) if l.starts_with("zh") => "我们已经是好友了",
        Some(ref l) if l.starts_with("ja") => "私たちはすでに友達です",
        _ => "We are now friends",
    }
}

fn parse_metadata_flag(metadata: &HashMap<String, String>, key: &str) -> Option<bool> {
    metadata
        .get(key)
        .and_then(|value| match value.to_lowercase().as_str() {
            "0" | "false" => Some(false),
            "1" | "true" => Some(true),
            "" => Some(false),
            _ => None,
        })
}

async fn retry_friend_business_notifications(services: &Services) -> Result<(), String> {
    let now_ms = Utc::now().timestamp_millis();
    let max_retry = 5;
    let limit = 50;

    // 只挑未通知过的记录，按重试次数和时间排序，尽量按 FIFO 重试。
    let rows = list_friend_requests_pending_notify(services.pool(), max_retry, limit)
        .await
        .map_err(|e| format!("query pending notify failed: {e}"))?;

    for row in rows {
        // 已接受的请求：仅重试好友建立通知；未决策的保留请求通知。
        if let (Some(decided_at), Some(accepted)) = (row.decided_at, row.accepted) {
            if accepted {
                match send_established_notify(row.from_uid, row.to_uid, decided_at).await {
                    Ok(_) => {
                        if let Err(err) =
                            mark_friend_request_notified(services.pool(), row.id, now_ms).await
                        {
                            warn!(
                                "retry notify: mark notified failed id={} err={}",
                                row.id, err
                            );
                        } else {
                            info!(
                                "retry notify: success id={} sender={} receiver={}",
                                row.id, row.from_uid, row.to_uid
                            );
                        }
                    }
                    Err(err) => {
                        warn!(
                            "retry notify: send established failed id={} retry_count={} err={}",
                            row.id, row.notify_retry, err
                        );
                        if let Err(e) =
                            increment_friend_request_notify_retry(services.pool(), row.id).await
                        {
                            warn!(
                                "retry notify: increment retry failed id={} err={}",
                                row.id, e
                            );
                        }
                    }
                }
                continue;
            }
        }

        // 未决策的仍重试好友请求通知
        let source = msg_message::FriendRequestSource::try_from(row.source)
            .unwrap_or(msg_message::FriendRequestSource::FrsUnknown);
        let payload = msg_message::FriendRequestPayload {
            request_id: row.id as u64,
            from_uid: row.from_uid,
            to_uid: row.to_uid,
            reason: row.from_reason.clone(),
            source: source as i32,
            created_at: row.created_at,
            remark: row.from_remark.clone(),
            nickname: row.from_nickname.clone(),
        };
        let biz = msg_message::FriendBusinessContent {
            action: Some(msg_message::friend_business_content::Action::Request(
                payload,
            )),
        };
        match send_friend_business_system_notify(biz, row.from_uid, row.to_uid).await {
            Ok(_) => {
                if let Err(err) =
                    mark_friend_request_notified(services.pool(), row.id, now_ms).await
                {
                    warn!(
                        "retry notify: mark notified failed id={} err={}",
                        row.id, err
                    );
                } else {
                    info!(
                        "retry notify: success id={} sender={} receiver={}",
                        row.id, row.from_uid, row.to_uid
                    );
                }
            }
            Err(err) => {
                warn!(
                    "retry notify: send failed id={} retry_count={} err={}",
                    row.id, row.notify_retry, err
                );
                if let Err(e) = increment_friend_request_notify_retry(services.pool(), row.id).await
                {
                    warn!(
                        "retry notify: increment retry failed id={} err={}",
                        row.id, e
                    );
                }
            }
        }
    }

    Ok(())
}
