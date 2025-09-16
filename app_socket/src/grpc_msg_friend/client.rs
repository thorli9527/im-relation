//! 好友业务 gRPC 客户端封装。
//!
//! msg_friend 进程对外同时提供消息与好友关系两个接口。对于 socket
//! 进程而言，这里仅封装好友关系相关的 `FriendBizServiceClient`，方便在
//! 不同 handler 中复用统一的连接逻辑。

use crate::grpc_msg_friend::msg_friend_service::friend_biz_service_client::FriendBizServiceClient;
use crate::service::grpc_clients;
use tonic::transport::Channel;

pub type Client = FriendBizServiceClient<Channel>;

pub async fn connect(addr: &str) -> Result<Client, tonic::transport::Error> {
    grpc_clients::friend_biz_client(addr).await
}
