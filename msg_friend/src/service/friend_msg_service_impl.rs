//! 好友消息 gRPC 服务实现：负责入库、Kafka 推送与分片控制。

use prost::Message as _;
use std::hash::Hasher as _;
use tonic::{Request, Response, Status};

use crate::dao::{
    copy_message_as_forward, insert_encrypted_message, mark_delivered, mark_read, recall_message,
    EncryptedMessageRecord,
};
use crate::server::server_grpc::Services;
use common::grpc::grpc_hot_friend::friend_service::IsFriendReq;
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
}
