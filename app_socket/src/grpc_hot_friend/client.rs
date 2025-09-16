//! hot_friend_service gRPC 客户端封装。
//!
//! socket 需要与好友热点服务通信以获取增删查改能力，此处封装统一的
//! 连接逻辑，避免在业务代码重复构造 `http://{addr}` 字符串。

use crate::grpc_hot_friend::friend_service::friend_service_client::FriendServiceClient;
use tonic::transport::Channel;

/// 友链热点服务客户端别名。
pub type Client = FriendServiceClient<Channel>;

/// 建立到热点友链服务的 gRPC 连接。
pub async fn connect(addr: &str) -> Result<Client, tonic::transport::Error> {
    // 传入纯地址即可，函数内部负责拼接完整 URI。
    FriendServiceClient::connect(format!("http://{}", addr)).await
}
