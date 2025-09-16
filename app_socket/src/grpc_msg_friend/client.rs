use tonic::transport::Channel;
use crate::grpc_msg_friend::msg_friend_service::friend_biz_service_client::FriendBizServiceClient;

pub type Client = FriendBizServiceClient<Channel>;

pub async fn connect(addr: &str) -> Result<Client, tonic::transport::Error> {
    FriendBizServiceClient::connect(format!("http://{}", addr)).await
}
