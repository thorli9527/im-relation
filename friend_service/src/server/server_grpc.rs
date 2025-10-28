use anyhow::Result;
use tonic::transport::Server;

use common::infra::grpc::grpc_friend::friend_service::friend_service_server::FriendServiceServer;
use common::support::logging::GrpcWarnLayer;

use crate::service::friend_service_impl::FriendServiceImpl;
use crate::store::mysql::FriendStorage;

pub async fn serve(
    addr: std::net::SocketAddr,
    service: FriendServiceImpl<FriendStorage>,
    shutdown: impl std::future::Future<Output = ()> + Send + 'static,
) -> Result<()> {
    Server::builder()
        .layer(GrpcWarnLayer::new())
        .accept_http1(true)
        .add_service(FriendServiceServer::new(service))
        .serve_with_shutdown(addr, shutdown)
        .await?;
    Ok(())
}
