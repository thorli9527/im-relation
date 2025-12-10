//! Common logging utilities shared across services.
//!
//! Provides a gRPC layer that emits `info` level logs for requests/responses and
//! prints the request payload plus a backtrace whenever a response fails. All services
//! consuming this layer thus expose request arguments and stack traces for failed paths.

use std::backtrace::Backtrace;
use std::fmt::Debug;
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

use log::{error, info};
use serde_json::json;
use tonic::codegen::http::Request;
use tower::{Layer, Service};

/// Layer that instruments gRPC services with info-level request/response logs.
#[derive(Clone, Copy, Debug, Default)]
pub struct GrpcInfoLayer;

impl GrpcInfoLayer {
    pub fn new() -> Self {
        Self
    }
}

impl<S> Layer<S> for GrpcInfoLayer {
    type Service = GrpcInfoService<S>;

    fn layer(&self, service: S) -> Self::Service {
        GrpcInfoService { inner: service }
    }
}

/// Service wrapper that logs gRPC traffic at info level and prints request + backtrace on failure.
pub struct GrpcInfoService<S> {
    inner: S,
}

impl<S> Clone for GrpcInfoService<S>
where
    S: Clone,
{
    fn clone(&self) -> Self {
        Self {
            inner: self.inner.clone(),
        }
    }
}

impl<S, B> Service<Request<B>> for GrpcInfoService<S>
where
    S: Service<Request<B>> + Send + 'static,
    S::Response: Send + 'static,
    S::Error: std::fmt::Debug + Send + 'static,
    S::Future: Send + 'static,
    B: Send + 'static + Debug,
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
        let request_debug = format!("{request:?}");
        // info!(
        //     "{}",
        //     LogPayload::info("grpc_recv", path.clone(), &request_debug)
        // );

        let fut = self.inner.call(request);
        Box::pin(async move {
            match fut.await {
                Ok(resp) => {
                    // info!(
                    //     "{}",
                    //     LogPayload::info("grpc_send", path.clone(), &request_debug)
                    // );
                    Ok(resp)
                }
                Err(err) => {
                    let backtrace = Backtrace::capture();
                    error!(
                        "{}",
                        LogPayload::error(
                            "grpc_error",
                            path.clone(),
                            &request_debug,
                            LogError {
                                err: format!("{err:?}"),
                                backtrace: format!("{backtrace:?}"),
                            }
                        )
                    );
                    Err(err)
                }
            }
        })
    }
}

#[derive(serde::Serialize)]
struct LogPayload<'a> {
    level: &'static str,
    event: &'static str,
    path: String,
    request: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<LogError>,
}

impl<'a> LogPayload<'a> {
    fn new(
        level: &'static str,
        event: &'static str,
        path: String,
        request: &'a str,
        error: Option<LogError>,
    ) -> String {
        json!(LogPayload {
            level,
            event,
            path,
            request,
            error,
        })
        .to_string()
    }

    fn info(event: &'static str, path: String, request: &'a str) -> String {
        Self::new("info", event, path, request, None)
    }

    fn error(event: &'static str, path: String, request: &'a str, error: LogError) -> String {
        Self::new("error", event, path, request, Some(error))
    }
}

#[derive(serde::Serialize)]
struct LogError {
    err: String,
    backtrace: String,
}
