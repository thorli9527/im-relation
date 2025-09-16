use arc_swap::ArcSwap;
use crate::grpc_hot_online::online_service::online_service_client::OnlineServiceClient;
use tonic::Status;
use crate::grpc_arb::arb_server::arb_server_rpc_service_client::ArbServerRpcServiceClient;
use crate::grpc_hot_online::client_service::client_rpc_service_client::ClientRpcServiceClient;
use std::sync::Arc;
use ahash::HashMap;
use tokio::sync::{Mutex, OnceCell};
use tonic::transport::Channel;

static INSTANCE: OnceCell<Arc<OnlineRpcServiceImpl>> = OnceCell::const_new();

pub struct OnlineRpcServiceImpl {
    pub client: Arc<Mutex<OnlineServiceClient<Channel>>>,
}

impl OnlineRpcServiceImpl {
    pub async fn new(address: &str) -> Result<OnlineRpcServiceImpl, Status> {
        // 创建 gRPC 客户端连接
        let client = OnlineServiceClient::connect(address.to_string())
            .await
            .map_err(|e| Status::internal(format!("Failed to connect to gRPC server: {}", e)))?;

        Ok(OnlineRpcServiceImpl {
            client: Arc::new(Mutex::new(client))
        })
    }

    // // 实现单例懒加载
    pub async fn init(address: &str) -> Result<&'static Arc<OnlineRpcServiceImpl>, Status> {
        let instance = INSTANCE.get_or_try_init(|| async {
            let service = OnlineRpcServiceImpl::new(address).await?;
            Ok::<Arc<OnlineRpcServiceImpl>, Status>(Arc::new(service))
        }).await?;

        Ok(instance)
    }


    // 提供获取实例的方法
    pub fn get() -> Arc<Self> {
        INSTANCE.get().unwrap().clone()
    }


}
