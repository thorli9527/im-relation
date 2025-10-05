//! 好友消息 gRPC 服务实现：负责入库、Kafka 推送与分片控制。

use prost::Message as _;
use std::hash::Hasher as _;
use tonic::{Request, Response, Status};

use crate::dao::{
    copy_message_as_forward, insert_encrypted_message, list_conversation_messages, mark_delivered,
    mark_read, recall_message, EncryptedMessageRecord,
};
use crate::server::Services;
use common::grpc::grpc_hot_friend::friend_service::{GetFriendsDetailedReq, IsFriendReq};
use common::grpc::{grpc_msg_friend::msg_friend_service as msgpb, message as msg_message};
use common::kafka::topic_info::MSG_SEND_FRIEND_TOPIC;

#[tonic::async_trait]
impl msgpb::friend_msg_service_server::FriendMsgService for Services {
    async fn send_message(
        &self,
        request: Request<msg_message::Content>,
    ) -> Result<Response<()>, Status> {
        let content = request.into_inner();
        // 分片选择
        let (a, b) = if content.sender_id >= content.receiver_id {
            (content.sender_id, content.receiver_id)
        } else {
            (content.receiver_id, content.sender_id)
        };
        let key = format!("{}:{}", a, b);
        let mut hasher = twox_hash::XxHash64::with_seed(0);
        hasher.write(key.as_bytes());
        let shard = (hasher.finish() % (self.shard_total() as u64)) as u32;
        if shard != self.shard_index() {
            return Ok(Response::new(()));
        }

        // 好友关系校验
        if let Some(cli) = self.friend_client() {
            let req = IsFriendReq {
                user_id: content.sender_id,
                friend_id: content.receiver_id,
            };
            if let Ok(resp) = cli.clone().is_friend(req).await {
                if !resp.into_inner().is_friend {
                    return Err(Status::permission_denied("not friends"));
                }
            }
        }

        // 入库：仅在 Encrypted 内容时落库
        if content.message_type == msg_message::ContentType::Encrypted as i32 {
            if let Some(first) = content.contents.first() {
                if let Some(msg_message::message_content::Content::Encrypted(enc)) = &first.content
                {
                    let mut raw = Vec::with_capacity(256);
                    content.encode(&mut raw).ok();
                    let rec = EncryptedMessageRecord {
                        msg_id: content.message_id.unwrap_or_default() as i64,
                        sender_id: content.sender_id,
                        receiver_id: content.receiver_id,
                        content_type: content.message_type,
                        created_at: content.timestamp,
                        scheme: enc.scheme.clone(),
                        key_id: enc.key_id.clone(),
                        nonce: enc.nonce.clone(),
                        msg_no: enc.msg_no as i64,
                        aad: if enc.aad.is_empty() {
                            None
                        } else {
                            Some(enc.aad.clone())
                        },
                        ciphertext: enc.ciphertext.clone(),
                        content: raw,
                    };
                    insert_encrypted_message(self.pool(), &rec)
                        .await
                        .map_err(|e| Status::internal(format!("db error: {e}")))?;
                }
            }
        }

        // Kafka 通知
        if let Some(kafka) = self.kafka() {
            let _ = kafka
                .send_proto(
                    100,
                    &content,
                    &(content.message_id.unwrap_or_default() as i64),
                    &MSG_SEND_FRIEND_TOPIC.topic_name,
                )
                .await;
        }
        Ok(Response::new(()))
    }

    async fn report_msg_read(
        &self,
        request: Request<msg_message::MsgRead>,
    ) -> Result<Response<()>, Status> {
        let r = request.into_inner();
        let _ = mark_read(self.pool(), r.msg_id, r.read_at)
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;
        Ok(Response::new(()))
    }

    async fn ack_msg_delivered(
        &self,
        request: Request<msg_message::MsgDeliveredAck>,
    ) -> Result<Response<()>, Status> {
        let r = request.into_inner();
        let now = chrono::Utc::now().timestamp_millis();
        let _ = mark_delivered(self.pool(), r.msg_id, now)
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;
        Ok(Response::new(()))
    }

    async fn ack_msg_read(
        &self,
        _request: Request<msg_message::MsgReadAck>,
    ) -> Result<Response<()>, Status> {
        Ok(Response::new(()))
    }

    async fn recall_msg(
        &self,
        request: Request<msg_message::MsgRecall>,
    ) -> Result<Response<()>, Status> {
        let r = request.into_inner();
        let _ = recall_message(self.pool(), r.msg_id, r.recalled_at, r.reason.as_deref())
            .await
            .map_err(|e| Status::internal(format!("db error: {e}")))?;
        Ok(Response::new(()))
    }

    async fn forward_msg(
        &self,
        request: Request<msg_message::MsgForward>,
    ) -> Result<Response<()>, Status> {
        let r = request.into_inner();
        copy_message_as_forward(
            self.pool(),
            r.src_msg_id,
            r.new_msg_id.unwrap_or_default(),
            r.from_user_id,
            r.to_user_id,
            r.created_at,
        )
        .await
        .map_err(|e| Status::internal(format!("db error: {e}")))?;
        // Kafka 通知新消息
        if let Some(kafka) = self.kafka() {
            let c = msg_message::Content {
                message_id: Some(r.new_msg_id.unwrap_or_default() as u64),
                sender_id: r.from_user_id,
                receiver_id: r.to_user_id,
                timestamp: r.created_at,
                message_type: msg_message::ContentType::Encrypted as i32,
                scene: msg_message::ChatScene::Single as i32,
                contents: vec![],
            };
            let _ = kafka
                .send_proto(
                    100,
                    &c,
                    &(c.message_id.unwrap_or_default() as i64),
                    &MSG_SEND_FRIEND_TOPIC.topic_name,
                )
                .await;
        }
        Ok(Response::new(()))
    }

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
            req.user_id,
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
                user_id: req.user_id,
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
                req.user_id,
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
}
