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
use common::infra::grpc::grpc_msg_system::msg_system_service::system_msg_service_client::SystemMsgServiceClient;
use common::infra::grpc::{
    grpc_msg_friend::msg_friend_service as msgpb, message as msg_message, GrpcClientManager,
};
use common::support::util::common_utils::build_snow_id;
use futures::{stream::FuturesUnordered, StreamExt};
use log::{info, warn};
use once_cell::sync::OnceCell;
use std::time::Duration;
use tokio::time::sleep;

use crate::dao::{
    delete_friend_conversation_snapshot, increment_friend_request_notify_retry,
    insert_encrypted_message, list_conversation_messages, list_friend_conversation_snapshots,
    list_friend_requests_pending_notify, mark_friend_request_decision,
    mark_friend_request_notified, upsert_friend_conversation_snapshot, upsert_friend_request,
    EncryptedMessageRecord, FriendConversationSnapshot, FriendRequestRow,
};
use crate::server::Services;
use common::infra::grpc::grpc_friend::friend_service::{
    GetFriendsDetailedReq, UpdateFriendBlacklistReq, UpdateFriendNicknameReq, UpdateFriendRemarkReq,
};

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

fn system_msg_manager(
) -> &'static GrpcClientManager<SystemMsgServiceClient<Channel>, TransportError> {
    SYSTEM_MSG_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            SystemMsgServiceClient::connect(endpoint).await
        })
    })
}

/// 后台重试好友业务系统通知的简单 worker。
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
    };

    let mut client = client.as_ref().clone();
    client
        .handle_system_message(Request::new(domain))
        .await
        .map(|_| ())
        .map_err(|e| format!("send to msg_system failed: {e}"))
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
}

impl Services {
    async fn persist_contents(&self, domain: &msg_message::DomainMessage) -> Result<(), Status> {
        let now = chrono::Utc::now().timestamp_millis();
        let msg_id = domain
            .message_id
            .map(|id| id as i64)
            .unwrap_or_else(build_snow_id);
        let msg_no = domain.message_id.unwrap_or(msg_id as u64) as i64;

        let content = msg_message::Content {
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
                reason: payload.reason.clone(),
                source: payload.source as i32,
                remark,
                nickname,
                peer_remark: String::new(),
                peer_nickname: String::new(),
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
            mark_friend_request_decision(
                svc.pool(),
                payload.request_id as i64,
                decided_at,
                payload.accepted,
                payload.remark.clone(),
                payload.nickname.clone(),
                payload.nickname.clone(),
            )
            .await
            .map_err(|e| Status::internal(format!("update friend request decision failed: {e}")))?;

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
        }
        _ => {
            warn!("friend_business: unknown action");
        }
    }

    Ok(())
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
    // 至少间隔 30 秒后才重试，避免瞬时重复。
    let now_ms = Utc::now().timestamp_millis();
    let backoff_ms: i64 = 30_000;
    let before_ts = now_ms - backoff_ms;
    let max_retry = 5;
    let limit = 50;

    let rows = list_friend_requests_pending_notify(services.pool(), before_ts, max_retry, limit)
        .await
        .map_err(|e| format!("query pending notify failed: {e}"))?;

    for row in rows {
        // 根据是否已决策构造 action。
        let action = if let (Some(decided_at), Some(accepted)) = (row.decided_at, row.accepted) {
            let payload = msg_message::FriendRequestDecisionPayload {
                request_id: row.id as u64,
                accepted,
                remark: row.peer_remark.clone(),
                decided_at,
                send_default_message: false,
                default_message: String::new(),
                nickname: row.peer_nickname.clone(),
            };
            msg_message::friend_business_content::Action::Decision(payload)
        } else {
            let source = msg_message::FriendRequestSource::from_i32(row.source)
                .unwrap_or(msg_message::FriendRequestSource::FrsUnknown);
            let payload = msg_message::FriendRequestPayload {
                request_id: row.id as u64,
                from_uid: row.from_uid,
                to_uid: row.to_uid,
                reason: row.reason.clone(),
                source: source as i32,
                created_at: row.created_at,
                remark: row.remark.clone(),
                nickname: row.nickname.clone(),
            };
            msg_message::friend_business_content::Action::Request(payload)
        };

        let biz = msg_message::FriendBusinessContent {
            action: Some(action.clone()),
        };

        // 判定发送双方
        let (sender_id, receiver_id) = match action {
            msg_message::friend_business_content::Action::Decision(_) => (row.to_uid, row.from_uid),
            _ => (row.from_uid, row.to_uid),
        };

        match send_friend_business_system_notify(biz, sender_id, receiver_id).await {
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
                        row.id, sender_id, receiver_id
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
