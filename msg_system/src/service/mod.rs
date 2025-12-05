use chrono::Utc;
use prost::Message as _;
use tonic::{Request, Response, Status};

use common::infra::grpc::grpc_msg_system::msg_system_service::{
    system_msg_service_server::SystemMsgService, QuerySystemMessagesRequest,
};
use common::infra::grpc::message as msg_message;
use common::infra::grpc::message::DomainMessage;
use common::infra::kafka::topic_info::SYS_MSG_TOPIC_INFO;
use common::support::util::common_utils::build_snow_id;
use log::{info, warn};

use crate::server::Services;

pub mod dao;

pub struct SystemMsgServiceImpl {
    services: Services,
}

impl SystemMsgServiceImpl {
    pub fn new(services: Services) -> Self {
        Self { services }
    }

    fn map_record_to_content(
        rec: dao::SystemMessageRecord,
    ) -> Result<msg_message::Content, Status> {
        msg_message::Content::decode(rec.content.as_slice())
            .map_err(|e| Status::internal(format!("decode system message failed: {e}")))
    }
}

#[tonic::async_trait]
impl SystemMsgService for SystemMsgServiceImpl {
    async fn handle_system_message(
        &self,
        request: Request<msg_message::DomainMessage>,
    ) -> Result<Response<()>, Status> {
        let mut domain = request.into_inner();
        let msg_id = domain.message_id.unwrap_or_else(|| build_snow_id() as u64);
        domain.message_id = Some(msg_id);
        if domain.category == 0 {
            domain.category = msg_message::MsgCategory::System as i32;
        }

        let contents = domain.contents.clone();
        let friend_business = domain.friend_business.clone();
        let group_business = domain.group_business.clone();
        let system_business = domain.system_business.clone();

        let ts_ms = if domain.ts_ms > 0 {
            domain.ts_ms
        } else {
            Utc::now().timestamp_millis()
        };

        let content = msg_message::Content {
            message_id: domain.message_id,
            sender_id: domain.sender_id,
            receiver_id: domain.receiver_id,
            timestamp: domain.timestamp,
            scene: domain.scene,
            contents: contents.clone(),
            friend_business: friend_business.clone(),
            group_business: group_business.clone(),
            heartbeat: None,
            ack: None,
            system_business: system_business.clone(),
        };

        let mut buf = Vec::with_capacity(content.encoded_len());
        content
            .encode(&mut buf)
            .map_err(|e| Status::internal(format!("encode system message failed: {e}")))?;

        dao::insert_system_message(
            self.services.pool(),
            content.sender_id,
            content.receiver_id,
            msg_id as i64,
            ts_ms,
            buf,
        )
        .await
        .map_err(|e| Status::internal(format!("db insert failed: {e}")))?;

        info!(
            "msg_system: stored message_id={} to receiver={} from sender={}",
            msg_id, content.receiver_id, content.sender_id
        );

        if let Some(kafka) = self.services.kafka() {
            let mut dom_for_kafka = DomainMessage {
                message_id: Some(msg_id),
                sender_id: content.sender_id,
                receiver_id: content.receiver_id,
                timestamp: content.timestamp,
                ts_ms,
                delivery: domain.delivery.clone(),
                scene: content.scene,
                category: msg_message::MsgCategory::System as i32,
                contents,
                friend_business,
                group_business,
                system_business,
            };
            // 系统消息默认要求 ACK，设置默认投递策略。
            if dom_for_kafka.delivery.is_none() {
                dom_for_kafka.delivery = Some(msg_message::DeliveryOptions {
                    require_ack: true,
                    expire_ms: Some(24 * 3600 * 1000), // 默认 24h
                    max_retry: Some(5),
                });
            }
            if let Err(err) = kafka
                .send_message(
                    &dom_for_kafka,
                    &msg_id.to_string(),
                    &SYS_MSG_TOPIC_INFO.topic_name,
                )
                .await
            {
                warn!("msg_system: kafka produce failed: {err}");
            }
        }

        Ok(Response::new(()))
    }

    async fn list_system_messages(
        &self,
        request: Request<QuerySystemMessagesRequest>,
    ) -> Result<Response<msg_message::QueryMessagesResponse>, Status> {
        let req = request.into_inner();
        let requested = if req.limit == 0 { 20 } else { req.limit };
        let limit = requested.max(1).min(200);
        let fetch_limit = (limit as usize).saturating_add(1);

        let rows = dao::list_system_messages(
            self.services.pool(),
            req.uid,
            req.before_message_id.map(|id| id as i64),
            req.before_timestamp,
            fetch_limit,
        )
        .await
        .map_err(|e| Status::internal(format!("db query failed: {e}")))?;

        let mut messages = Vec::with_capacity(rows.len());
        let mut has_more = false;

        for (idx, rec) in rows.into_iter().enumerate() {
            if idx == limit as usize {
                has_more = true;
                break;
            }
            messages.push(Self::map_record_to_content(rec)?);
        }

        if has_more {
            warn!(
                "msg_system: uid={} has more messages beyond limit={}",
                req.uid, limit
            );
        }

        Ok(Response::new(msg_message::QueryMessagesResponse {
            messages,
            has_more,
        }))
    }
}
