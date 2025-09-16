use crate::grpc_hot_online::client_service::client_rpc_service_client::ClientRpcServiceClient;
use common::grpc::GrpcClientManager;
use once_cell::sync::OnceCell as SyncOnceCell;
use tokio::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};
use tonic::Status;

static CLIENT_MANAGER: OnceCell<
    GrpcClientManager<ClientRpcServiceClient<Channel>, TransportError>,
> = OnceCell::const_new();
static DEFAULT_ADDR: SyncOnceCell<String> = SyncOnceCell::new();

pub struct ClientRpcClients;

impl ClientRpcClients {
    pub async fn init(address: &str) -> Result<(), Status> {
        CLIENT_MANAGER
            .get_or_try_init(|| async {
                Ok::<GrpcClientManager<_, _>, Status>(GrpcClientManager::new(
                    |addr: String| async move { ClientRpcServiceClient::connect(addr).await },
                ))
            })
            .await?;
        DEFAULT_ADDR.get_or_init(|| address.to_string());

        let manager = CLIENT_MANAGER.get().unwrap();
        manager
            .get(address)
            .await
            .map_err(|e| Status::internal(format!("client connect error: {}", e)))?;
        Ok(())
    }

    pub async fn get_default() -> Result<ClientRpcServiceClient<Channel>, Status> {
        let addr = DEFAULT_ADDR
            .get()
            .ok_or_else(|| Status::internal("ClientRpcClients not initialized"))?
            .clone();
        Self::get(&addr).await
    }

    pub async fn get(address: &str) -> Result<ClientRpcServiceClient<Channel>, Status> {
        let manager = CLIENT_MANAGER
            .get()
            .ok_or_else(|| Status::internal("ClientRpcClients not initialized"))?;
        let client = manager
            .get(address)
            .await
            .map_err(|e| Status::internal(format!("client connect error: {}", e)))?;
        Ok(client.as_ref().clone())
    }

    pub fn invalidate(address: &str) {
        if let Some(manager) = CLIENT_MANAGER.get() {
            manager.invalidate(address);
        }
    }
}
