use anyhow::Result;
use tonic::service::Routes;
use tonic::transport::Server;

use common::support::logging::GrpcWarnLayer;

pub async fn serve(
    addr: std::net::SocketAddr,
    routes: Routes,
    shutdown: impl std::future::Future<Output = ()> + Send + 'static,
) -> Result<()> {
    Server::builder()
        .layer(GrpcWarnLayer::new())
        .accept_http1(true)
        .add_routes(routes)
        .serve_with_shutdown(addr, shutdown)
        .await?;
    Ok(())
}
