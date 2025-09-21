use crate::grpc_arb::arb_server::arb_client_rpc_service_client::ArbClientRpcServiceClient;
use common::grpc::GrpcClientManager;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

pub type ArbClient = ArbClientRpcServiceClient<Channel>;

fn normalize_endpoint(addr: &str) -> String {
    if addr.starts_with("http://") || addr.starts_with("https://") {
        addr.to_string()
    } else {
        format!("http://{}", addr)
    }
}

fn client_manager() -> &'static GrpcClientManager<ArbClient, TransportError> {
    static MANAGER: OnceCell<GrpcClientManager<ArbClient, TransportError>> = OnceCell::new();
    MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            ArbClientRpcServiceClient::connect(endpoint).await
        })
    })
}

pub async fn connect_client(addr: &str) -> Result<ArbClient, TransportError> {
    let endpoint = normalize_endpoint(addr);
    client_manager()
        .get(&endpoint)
        .await
        .map(|client| client.as_ref().clone())
}

pub fn invalidate_client(addr: &str) {
    client_manager().invalidate(&normalize_endpoint(addr));
}
