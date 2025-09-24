use anyhow::Result;
use tonic::transport::Server;

use common::grpc::grpc_hot_friend::friend_service::friend_service_server::FriendServiceServer;

use crate::service::friend_service_impl::FriendServiceImpl;
use crate::store::mysql::FriendStorage;

pub async fn serve(
    addr: std::net::SocketAddr,
    service: FriendServiceImpl<FriendStorage>,
    shutdown: impl std::future::Future<Output = ()> + Send + 'static,
) -> Result<()> {
    Server::builder()
        .accept_http1(true)
        .add_service(FriendServiceServer::new(service))
        .serve_with_shutdown(addr, shutdown)
        .await?;
    Ok(())
}
