//! 热好友服务客户端包装，负责补全协议头并创建 gRPC Channel。

use common::infra::grpc::grpc_friend::friend_service::friend_service_client::FriendServiceClient;
use tonic::transport::Endpoint;
use tonic::transport::{Channel, Error as TransportError};

/// 热好友 gRPC 客户端。
#[derive(Clone)]
pub struct HfFriendClient {
    inner: FriendServiceClient<Channel>,
}

impl HfFriendClient {
    /// 将裸地址补全为带协议的 Endpoint 字符串。
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

impl std::ops::Deref for HfFriendClient {
    type Target = FriendServiceClient<Channel>;

    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

impl std::ops::DerefMut for HfFriendClient {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.inner
    }
}

/// 创建一个热好友客户端实例。
pub async fn connect(addr: &str) -> Result<HfFriendClient, TransportError> {
    let channel = HfFriendClient::connect_channel(addr).await?;
    Ok(HfFriendClient {
        inner: FriendServiceClient::new(channel),
    })
}
