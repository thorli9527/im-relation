//! Common logging utilities shared across services.
//!
//! Currently provides a gRPC layer that emits `warn` level logs whenever
//! a request is received and when the corresponding response is sent (or
//! fails). This ensures that all inbound/outbound gRPC calls are visible
//! even when the global log level is set to `warn`, matching the default
//! system configuration shipped with the individual apps.

use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

use log::info;
use tonic::codegen::http::Request;
use tower::{Layer, Service};

/// Layer that instruments gRPC services with warn-level logs for request/response events.
#[derive(Clone, Copy, Debug, Default)]
pub struct GrpcWarnLayer;

impl GrpcWarnLayer {
    pub fn new() -> Self {
        Self
    }
}

impl<S> Layer<S> for GrpcWarnLayer {
    type Service = GrpcWarnService<S>;

    fn layer(&self, service: S) -> Self::Service {
        GrpcWarnService { inner: service }
    }
}

/// Service wrapper that logs warn messages for gRPC traffic.
pub struct GrpcWarnService<S> {
    inner: S,
}

impl<S> Clone for GrpcWarnService<S>
where
    S: Clone,
{
    fn clone(&self) -> Self {
        Self {
            inner: self.inner.clone(),
        }
    }
}

impl<S, B> Service<Request<B>> for GrpcWarnService<S>
where
    S: Service<Request<B>> + Send + 'static,
    S::Response: Send + 'static,
    S::Error: std::fmt::Debug + Send + 'static,
    S::Future: Send + 'static,
    B: Send + 'static,
{
    type Response = S::Response;
    type Error = S::Error;
    type Future =
        Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>> + Send + 'static>>;

    fn poll_ready(&mut self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.inner.poll_ready(cx)
    }

    fn call(&mut self, request: Request<B>) -> Self::Future {
        let path = request.uri().path().to_owned();
        info!("gRPC recv `{path}`");

        let fut = self.inner.call(request);
        Box::pin(async move {
            match fut.await {
                Ok(resp) => {
                    info!("gRPC send `{path}`");
                    Ok(resp)
                }
                Err(err) => {
                    info!("gRPC send `{path}` failed: {:?}", err);
                    Err(err)
                }
            }
        })
    }
}
