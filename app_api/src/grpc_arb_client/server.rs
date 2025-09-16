use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcService;
use crate::grpc_arb::arb_server::arb_server_rpc_service_client::ArbServerRpcServiceClient;
use crate::grpc_arb::arb_server::{BytesBlob, CommonResp, NodeType, QueryNodeReq};
use crate::service::arb_server_service::ArbServerService;
use crate::util::node_util::NodeUtil;
use async_trait::async_trait;
use tonic::{Request, Response, Status};

type ArbServerClient = ArbServerRpcServiceClient<tonic::transport::Channel>;

pub struct ArbClientServiceImpl;

impl ArbClientServiceImpl {
    pub fn new() -> Self {
        Self
    }
}

#[async_trait]
impl ArbClientRpcService for ArbClientServiceImpl {
    async fn sync_data(&self, request: Request<BytesBlob>) -> Result<Response<CommonResp>, Status> {
        let req = request.into_inner();
        if req.sync_type == NodeType::SocketNode as i32 {
            let arb_server_service = ArbServerService::get();
            let mut client = arb_server_service.client.lock().await;

            let list_rep = client
                .list_all_nodes(QueryNodeReq {
                    node_type: NodeType::SocketNode as i32,
                })
                .await?;
            let list = list_rep.into_inner();
            NodeUtil::get().reset_list(
                NodeType::SocketNode as i32,
                list.nodes.into_iter().map(|n| n.node_addr).collect(),
            );
        }
        Ok(Response::new(CommonResp {
            success: true,
            message: String::new(),
        }))
    }
}
