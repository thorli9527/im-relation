use anyhow::Result;
use tonic::service::Routes;
use tonic::transport::Server as TonicServer;

pub async fn serve(
    addr: std::net::SocketAddr,
    routes: Routes,
    shutdown: impl std::future::Future<Output = ()> + Send + 'static,
) -> Result<()> {
    TonicServer::builder()
        .accept_http1(true)
        .add_routes(routes)
        .serve_with_shutdown(addr, shutdown)
        .await?;
    Ok(())
}
