use crate::{handler, swagger};
use anyhow::{anyhow, Context, Result};
use axum::http;
use axum::{
    body::Body as AxumBody,
    http::{Request, StatusCode},
    middleware::{from_fn, Next},
    response::Html,
    routing::{get, post},
    Json, Router,
};
use common::config::AppConfig;
use log::{error, warn};
use serde_json::json;
use std::backtrace::Backtrace;
use tokio::net::TcpListener;
use tower_http::classify::ServerErrorsFailureClass;
use tower_http::trace::{DefaultMakeSpan, TraceLayer};
use utoipa::{openapi::OpenApi as OpenApiSpec, OpenApi};

const SWAGGER_UI_HTML: &str = r##"<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>App API Swagger UI</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist/swagger-ui.css" />
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist/swagger-ui-bundle.js"></script>
  <script>
    window.onload = function () {
      SwaggerUIBundle({
        url: "/swagger.json",
        dom_id: "#swagger-ui",
        presets: [SwaggerUIBundle.presets.apis],
        layout: "BaseLayout",
        deepLinking: true,
      });
    };
  </script>
</body>
</html>"##;

pub async fn start() -> Result<()> {
    let app_cfg = AppConfig::get();
    let server_cfg = app_cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let address_and_port = server_cfg
        .require_http_addr()
        .context("server.http missing host/port")?;
    warn!("HTTP server listening on {}", address_and_port);

    let trace_layer = TraceLayer::new_for_http()
        .make_span_with(DefaultMakeSpan::new().level(tracing::Level::INFO))
        .on_response(
            |res: &http::Response<_>, latency: std::time::Duration, _span: &tracing::Span| {
                let status = res.status();
                if status.is_server_error() {
                    error!("http response status={} latency={:?}", status, latency);
                } else if status.is_client_error() {
                    warn!("http response status={} latency={:?}", status, latency);
                }
            },
        )
        .on_failure(
            |error: ServerErrorsFailureClass,
             latency: std::time::Duration,
             _span: &tracing::Span| {
                let backtrace = Backtrace::force_capture();
                error!(
                    "http failure error={:?} latency={:?} backtrace={}",
                    error, latency, backtrace
                );
            },
        );

    let api_router: Router = handler::router()
        .route("/healthz", post(healthz))
        .layer(trace_layer)
        .layer(from_fn(auth_middleware));

    let swagger_routes = Router::new()
        .route("/swagger.json", get(swagger_json))
        .route("/swagger-ui", get(swagger_ui));

    let router = Router::new().merge(swagger_routes).merge(api_router);
    let listener = TcpListener::bind(&address_and_port).await?;

    axum::serve(listener, router.into_make_service()).await?;
    Ok(())
}

/// 简单健康检查，供负载均衡探测。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}

async fn auth_middleware(
    mut req: Request<AxumBody>,
    next: Next,
) -> Result<axum::response::Response, StatusCode> {
    // 这里可以放置统一鉴权逻辑，比如校验Header中的token
    // 当前先直接透传
    req.extensions_mut().insert("auth-skipped");
    Ok(next.run(req).await)
}

async fn swagger_json() -> Json<OpenApiSpec> {
    Json(swagger::ApiDoc::openapi())
}

async fn swagger_ui() -> Html<&'static str> {
    Html(SWAGGER_UI_HTML)
}
