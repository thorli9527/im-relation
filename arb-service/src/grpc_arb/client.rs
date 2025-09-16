use crate::grpc_arb::arb_server::arb_client_rpc_service_client::ArbClientRpcServiceClient;
use tonic::transport::Channel;

pub type ArbClient = ArbClientRpcServiceClient<Channel>;

pub async fn connect_client(uri: &str) -> Result<ArbClient, tonic::transport::Error> {
    ArbClientRpcServiceClient::connect(uri.to_string()).await
}
