//! 群消息业务实现。
//!
//! - 负责把来自 app_socket 的消息写入 `message_info` 表。
//! - 目前 ACK/已读等接口保留占位逻辑，待补充表结构再完善。

use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use common::support::util::common_utils::build_snow_id;
use prost::Message;
use tonic::{Request, Response, Status};

use crate::dao::{insert_group_message, list_group_messages, GroupMessageRecord};
use crate::server::Services;
use common::infra::grpc::grpc_msg_group::msg_group_service::group_msg_service_server::GroupMsgService;
use common::infra::grpc::message::{
    message_content, Content, MsgDeliveredAck, MsgForward, MsgRead, MsgReadAck, MsgRecall,
    QueryGroupMessagesRequest, QueryMessagesResponse,
};

/// 群消息 gRPC 服务实现。
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
}

#[tonic::async_trait]
impl GroupMsgService for GroupMsgServiceImpl {
    /// 写入群消息，落地为 message_info 记录。
    async fn send_message(&self, request: Request<Content>) -> Result<Response<()>, Status> {
        let content = request.into_inner();
        let msg_id = content
            .message_id
            .map(|id| id as i64)
            .unwrap_or_else(|| build_snow_id());
        let msg_no = content
            .contents
            .iter()
            .find_map(|item| match &item.content {
                Some(message_content::Content::Encrypted(enc)) => Some(enc.msg_no as i64),
                _ => None,
            })
            .unwrap_or_default();
        let raw = content.encode_to_vec();

        let record = GroupMessageRecord {
            msg_id,
            group_id: content.receiver_id,
            sender_id: content.sender_id,
            msg_kind: content.msg_kind,
            timestamp_ms: content.timestamp,
            created_at_ms: Self::now_ms(),
            msg_no,
            content: raw,
        };

        insert_group_message(self.inner.pool(), &record)
            .await
            .map_err(|e| Status::internal(format!("insert_group_message: {e}")))?;
        Ok(Response::new(()))
    }

    /// 占位：后续补充已读落库逻辑。
    async fn report_msg_read(&self, _request: Request<MsgRead>) -> Result<Response<()>, Status> {
        Ok(Response::new(()))
    }

    async fn ack_msg_delivered(
        &self,
        _request: Request<MsgDeliveredAck>,
    ) -> Result<Response<()>, Status> {
        Ok(Response::new(()))
    }

    /// 占位：后续可在此放置推送/同步已读的逻辑。
    async fn ack_msg_read(&self, _request: Request<MsgReadAck>) -> Result<Response<()>, Status> {
        Ok(Response::new(()))
    }

    /// 占位：撤回消息，等待补充表结构再实现。
    async fn recall_msg(&self, _request: Request<MsgRecall>) -> Result<Response<()>, Status> {
        Ok(Response::new(()))
    }

    /// 占位：转发消息，当前仅返回成功。
    async fn forward_msg(&self, _request: Request<MsgForward>) -> Result<Response<()>, Status> {
        Ok(Response::new(()))
    }

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

            let mut content = Content::decode(rec.content.as_slice())
                .map_err(|e| Status::internal(format!("decode message failed: {e}")))?;
            if content.msg_kind == 0 {
                content.msg_kind = rec.msg_kind;
            }
            messages.push(content);
        }

        Ok(Response::new(QueryMessagesResponse { messages, has_more }))
    }
}
