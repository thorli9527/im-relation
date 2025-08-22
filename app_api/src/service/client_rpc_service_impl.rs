use tonic::Status;
use crate::grpc::arb_server::arb_server_rpc_service_client::ArbServerRpcServiceClient;
use crate::grpc::client_service::client_rpc_service_client::ClientRpcServiceClient;
use std::sync::Arc;
use ahash::HashMap;
use arc_swap::ArcSwap;
use tokio::sync::{Mutex, OnceCell};
use tonic::transport::Channel;

static INSTANCE: OnceCell<Arc<ClientRpcServiceImpl>> = OnceCell::const_new();

pub struct ClientRpcServiceImpl {
    pub client: Arc<Mutex<ClientRpcServiceClient<Channel>>>,
}

impl ClientRpcServiceImpl {
    pub async fn new(address: &str) -> Result<ClientRpcServiceImpl, Status> {
        // 创建 gRPC 客户端连接
        let client = ClientRpcServiceClient::connect(address.to_string())
            .await
            .map_err(|e| Status::internal(format!("Failed to connect to gRPC server: {}", e)))?;

        Ok(ClientRpcServiceImpl {
            client: Arc::new(Mutex::new(client))
        })
    }

    // 实现单例懒加载
    pub async fn init(address: &str) -> Result<&'static Arc<ClientRpcServiceImpl>, Status> {
        let instance = INSTANCE.get_or_try_init(|| async {
            let service = ClientRpcServiceImpl::new(address).await?;
            Ok::<Arc<ClientRpcServiceImpl>, Status>(Arc::new(service))
        }).await?;

        Ok(instance)
    }


    // 提供获取实例的方法
    pub fn get() -> Arc<Self> {
        INSTANCE.get().unwrap().clone()
    }


}
