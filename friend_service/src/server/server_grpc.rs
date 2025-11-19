use anyhow::Result;
use log::warn;
use tonic::transport::Server;

use common::infra::grpc::grpc_friend::friend_service::friend_service_server::FriendServiceServer;
use common::support::logging::GrpcInfoLayer;

use crate::service::friend_service_impl::FriendServiceImpl;
use crate::store::mysql::FriendStorage;

pub async fn serve(
    addr: std::net::SocketAddr,
    service: FriendServiceImpl<FriendStorage>,
    shutdown: impl std::future::Future<Output = ()> + Send + 'static,
) -> Result<()> {
    warn!("gRPC server (friend_service) listening on {}", addr);

    Server::builder()
        .layer(GrpcInfoLayer::new())
        .accept_http1(true)
        .add_service(FriendServiceServer::new(service))
        .serve_with_shutdown(addr, shutdown)
        .await?;
    Ok(())
}
