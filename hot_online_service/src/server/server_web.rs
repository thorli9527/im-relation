use anyhow::Result;
use axum::Router;
use tokio::net::TcpListener;

pub async fn serve(
    addr: std::net::SocketAddr,
    router: Router,
    shutdown: impl std::future::Future<Output = ()> + Send + 'static,
) -> Result<()> {
    let listener = TcpListener::bind(addr).await?;
    axum::serve(listener, router.into_make_service())
        .with_graceful_shutdown(shutdown)
        .await?;
    Ok(())
}
