use crate::grpc_hot_online::online_service::online_service_client::OnlineServiceClient;
use common::grpc::GrpcClientManager;
use once_cell::sync::OnceCell as SyncOnceCell;
use tokio::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};
use tonic::Status;

static MANAGER: OnceCell<GrpcClientManager<OnlineServiceClient<Channel>, TransportError>> =
    OnceCell::const_new();
static DEFAULT_ADDR: SyncOnceCell<String> = SyncOnceCell::new();

pub struct OnlineRpcServiceImpl;

impl OnlineRpcServiceImpl {
    pub async fn init(address: &str) -> Result<(), Status> {
        MANAGER
            .get_or_try_init(|| async {
                Ok::<GrpcClientManager<_, _>, Status>(GrpcClientManager::new(
                    |addr: String| async move { OnlineServiceClient::connect(addr).await },
                ))
            })
            .await?;
        DEFAULT_ADDR.get_or_init(|| address.to_string());

        let manager = MANAGER.get().unwrap();
        manager
            .get(address)
            .await
            .map_err(|e| Status::internal(format!("online client connect error: {}", e)))?;
        Ok(())
    }

    pub async fn get_default() -> Result<OnlineServiceClient<Channel>, Status> {
        let addr = DEFAULT_ADDR
            .get()
            .ok_or_else(|| Status::internal("OnlineRpcServiceImpl not initialized"))?
            .clone();
        Self::get(&addr).await
    }

    pub async fn get(address: &str) -> Result<OnlineServiceClient<Channel>, Status> {
        let manager = MANAGER
            .get()
            .ok_or_else(|| Status::internal("OnlineRpcServiceImpl not initialized"))?;
        let client = manager
            .get(address)
            .await
            .map_err(|e| Status::internal(format!("online client connect error: {}", e)))?;
        Ok(client.as_ref().clone())
    }

    pub fn invalidate(address: &str) {
        if let Some(manager) = MANAGER.get() {
            manager.invalidate(address);
        }
    }
}
