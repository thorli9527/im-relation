//! 热群服务客户端包装，负责处理地址拼接与连接复用。

use common::grpc::grpc_hot_group::group_service::group_service_client::GroupServiceClient;
use tonic::transport::Endpoint;
use tonic::transport::{Channel, Error as TransportError};

/// 热群服务 gRPC 客户端包装。
#[derive(Clone)]
pub struct HgGroupClient {
    inner: GroupServiceClient<Channel>,
}

impl HgGroupClient {
    /// 补全 gRPC 地址的协议头。
    fn normalize_endpoint(addr: &str) -> String {
        if addr.starts_with("http://") || addr.starts_with("https://") {
            addr.to_string()
        } else {
            format!("http://{}", addr)
        }
    }

    /// 建立底层 Channel。
    async fn connect_channel(addr: &str) -> Result<Channel, TransportError> {
        let endpoint = Endpoint::from_shared(Self::normalize_endpoint(addr))?;
        endpoint.connect().await
    }
}

impl std::ops::Deref for HgGroupClient {
    type Target = GroupServiceClient<Channel>;

    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

impl std::ops::DerefMut for HgGroupClient {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.inner
    }
}

/// 创建一个热群客户端实例。
pub async fn connect(addr: &str) -> Result<HgGroupClient, TransportError> {
    let channel = HgGroupClient::connect_channel(addr).await?;
    Ok(HgGroupClient {
        inner: GroupServiceClient::new(channel),
    })
}
