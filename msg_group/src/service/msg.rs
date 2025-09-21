use std::sync::Arc;

use tonic::{Request, Response, Status};

use crate::grpc_msg_group::msg_group_service::{
    group_msg_service_server::GroupMsgService, Content, MsgDeliveredAck, MsgForward, MsgRead,
    MsgReadAck, MsgRecall,
};
use crate::server::server_grpc::Services;

#[derive(Clone)]
pub struct GroupMsgServiceImpl {
    #[allow(dead_code)]
    inner: Arc<Services>,
}

impl GroupMsgServiceImpl {
    pub fn new(inner: Arc<Services>) -> Self {
        Self { inner }
    }

    fn not_impl(method: &str) -> Status {
        Status::unimplemented(method)
    }
}

#[tonic::async_trait]
impl GroupMsgService for GroupMsgServiceImpl {
    async fn send_message(&self, _request: Request<Content>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupMsgService.SendMessage"))
    }

    async fn report_msg_read(&self, _request: Request<MsgRead>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupMsgService.ReportMsgRead"))
    }

    async fn ack_msg_delivered(
        &self,
        _request: Request<MsgDeliveredAck>,
    ) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupMsgService.AckMsgDelivered"))
    }

    async fn ack_msg_read(&self, _request: Request<MsgReadAck>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupMsgService.AckMsgRead"))
    }

    async fn recall_msg(&self, _request: Request<MsgRecall>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupMsgService.RecallMsg"))
    }

    async fn forward_msg(&self, _request: Request<MsgForward>) -> Result<Response<()>, Status> {
        Err(Self::not_impl("GroupMsgService.ForwardMsg"))
    }
}
