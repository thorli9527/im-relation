use anyhow::Result;
use log::warn;
use tonic::service::Routes;
use tonic::transport::Server;

use common::support::logging::GrpcInfoLayer;

pub async fn serve(
    addr: std::net::SocketAddr,
    routes: Routes,
    shutdown: impl std::future::Future<Output = ()> + Send + 'static,
) -> Result<()> {
    warn!("gRPC server (user_service) listening on {}", addr);

    Server::builder()
        .layer(GrpcInfoLayer::new())
        .accept_http1(true)
        .add_routes(routes)
        .serve_with_shutdown(addr, shutdown)
        .await?;
    Ok(())
}
