use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcService;
use crate::grpc_arb::arb_server::{BytesBlob, CommonResp};
use log::info;
use tonic::{Request, Response, Status};

#[derive(Clone, Default)]
pub struct ArbClientImpl;

#[tonic::async_trait]
impl ArbClientRpcService for ArbClientImpl {
    async fn sync_data(&self, request: Request<BytesBlob>) -> Result<Response<CommonResp>, Status> {
        let blob = request.into_inner();
        info!(
            "arb-sync: type={:?} payload_len={}",
            blob.sync_type,
            blob.data.len()
        );
        Ok(Response::new(CommonResp {
            success: true,
            message: "ok".to_string(),
        }))
    }
}
