use tonic::transport::Channel;
use crate::grpc_arb::arb_server::arb_server_rpc_service_client::ArbServerRpcServiceClient;
use crate::grpc_arb::arb_server::arb_client_rpc_service_client::ArbClientRpcServiceClient;

pub type ServerClient = ArbServerRpcServiceClient<Channel>;
pub type ClientClient = ArbClientRpcServiceClient<Channel>;

pub async fn connect_server(addr: &str) -> Result<ServerClient, tonic::transport::Error> {
    ArbServerRpcServiceClient::connect(format!("http://{}", addr)).await
}

pub async fn connect_client(addr: &str) -> Result<ClientClient, tonic::transport::Error> {
    ArbClientRpcServiceClient::connect(format!("http://{}", addr)).await
}

