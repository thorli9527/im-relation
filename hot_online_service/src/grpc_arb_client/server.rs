use crate::grpc_arb::arb_server::arb_client_rpc_service_server::{
    ArbClientRpcService, ArbClientRpcServiceServer,
};
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

pub async fn start_arb_client_server(bind: &str) -> Result<(), anyhow::Error> {
    let addr: std::net::SocketAddr = bind.parse()?;
    let svc = ArbClientImpl::default();
    tokio::spawn(async move {
        if let Err(e) = tonic::transport::Server::builder()
            .add_service(ArbClientRpcServiceServer::new(svc))
            .serve(addr)
            .await
        {
            log::warn!("arb client server exited: {}", e);
        }
    });
    Ok(())
}
