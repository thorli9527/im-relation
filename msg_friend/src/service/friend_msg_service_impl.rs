use prost::Message as _;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::hash::Hasher as _;
use tonic::{Request, Response, Status};

use chrono::Utc;
use common::support::util::common_utils::build_snow_id;
use log::info;

use crate::dao::{
    delete_friend_conversation_snapshot, insert_encrypted_message, list_conversation_messages,
    list_friend_conversation_snapshots, upsert_friend_conversation_snapshot,
    EncryptedMessageRecord, FriendConversationSnapshot,
};
use crate::server::Services;
use common::infra::grpc::grpc_friend::friend_service::{
    GetFriendsDetailedReq, UpdateFriendAliasReq, UpdateFriendBlacklistReq, UpdateFriendRemarkReq,
};
use common::infra::grpc::{grpc_msg_friend::msg_friend_service as msgpb, message as msg_message};

fn make_conversation_id(a: i64, b: i64) -> i64 {
    let (min_id, max_id) = if a <= b { (a, b) } else { (b, a) };
    let key = format!("{}:{}", min_id, max_id);
    let mut hasher = twox_hash::XxHash64::with_seed(0);
    hasher.write(key.as_bytes());
    hasher.finish() as i64
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
                alias: false,
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
            last_msg_kind: 0,
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

    async fn handle_friend_message(
        &self,
        request: Request<msg_message::DomainMessage>,
    ) -> Result<Response<()>, Status> {
        let domain = request.into_inner();
        info!(
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
                process_friend_business(friend_business);
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
            msg_kind: domain.category,
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
            last_msg_kind: record.msg_kind,
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
            msg_message::FriendEventType::FeAliasUpdated => {
                let alias_value = event.alias.clone().unwrap_or_default();
                let alias_opt = if alias_value.is_empty() {
                    None
                } else {
                    Some(alias_value.clone())
                };
                let req = UpdateFriendAliasReq {
                    uid: event.operator_id,
                    friend_id: event.friend_id,
                    alias: alias_opt.clone(),
                };
                friend_client
                    .clone()
                    .update_friend_alias(Request::new(req))
                    .await
                    .map_err(|e| Status::internal(format!("update_friend_alias failed: {}", e)))?;
                info!(
                    "friend event: alias updated operator={} friend={} alias={:?}",
                    event.operator_id, event.friend_id, alias_opt
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

fn process_friend_business(biz: &msg_message::FriendBusinessContent) {
    match &biz.action {
        Some(msg_message::friend_business_content::Action::Request(_)) => {
            info!("friend_business: request");
        }
        Some(msg_message::friend_business_content::Action::Decision(_)) => {
            info!("friend_business: decision");
        }
        _ => {
            info!("friend_business: unknown action");
        }
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
