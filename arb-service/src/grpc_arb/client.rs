use tonic::transport::Channel;
use crate::grpc_arb::arb_server::arb_client_rpc_service_client::ArbClientRpcServiceClient;

pub type ArbClient = ArbClientRpcServiceClient<Channel>;

pub async fn connect_client(uri: &str) -> Result<ArbClient, tonic::transport::Error> {
    ArbClientRpcServiceClient::connect(uri.to_string()).await
}

