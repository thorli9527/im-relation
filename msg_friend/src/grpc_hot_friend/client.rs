use tonic::transport::Channel;
use crate::grpc_hot_friend::friend_service::friend_service_client::FriendServiceClient;

pub type HfFriendClient = FriendServiceClient<Channel>;

pub async fn connect(addr: &str) -> Result<HfFriendClient, tonic::transport::Error> {
    FriendServiceClient::connect(format!("http://{}", addr)).await
}

