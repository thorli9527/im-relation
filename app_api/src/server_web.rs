use crate::{handler, swagger};
use anyhow::{anyhow, Context, Result};
use axum::http;
use axum::{
    body::Body as AxumBody,
    body::{to_bytes, Bytes},
    http::{Request, StatusCode},
    middleware::{from_fn, Next},
    response::Html,
    routing::{get, post},
    Json, Router,
};
use common::config::AppConfig;
use log::{error, info, warn};
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
        .layer(from_fn(logging_middleware))
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

/// 统一日志拦截：打印请求体、响应体和异常堆栈。
async fn logging_middleware(
    req: Request<AxumBody>,
    next: Next,
) -> Result<axum::response::Response, StatusCode> {
    let method = req.method().clone();
    let uri = req.uri().clone();

    // 读取请求体（最多 1MB），再放回去
    let (parts, body) = req.into_parts();
    let body_bytes = to_bytes(body, 1_048_576)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    let req_body = String::from_utf8_lossy(&body_bytes);
    info!("request {} {} body={}", method, uri, req_body);
    let req = Request::from_parts(parts, AxumBody::from(body_bytes));

    let res = next.run(req).await;
    let status = res.status();
    let (res_parts, res_body) = res.into_parts();
    let res_bytes = to_bytes(res_body, 1_048_576)
        .await
        .unwrap_or_else(|_| Bytes::new());
    let res_body = String::from_utf8_lossy(&res_bytes);

    if status.is_server_error() {
        let backtrace = Backtrace::force_capture();
        error!(
            "response {} {} status={} body={} backtrace={}",
            method, uri, status, res_body, backtrace
        );
    } else {
        info!(
            "response {} {} status={} body={}",
            method, uri, status, res_body
        );
    }

    let res = http::Response::from_parts(res_parts, AxumBody::from(res_bytes));
    Ok(res)
}

async fn swagger_json() -> Json<OpenApiSpec> {
    Json(swagger::ApiDoc::openapi())
}

async fn swagger_ui() -> Html<&'static str> {
    Html(SWAGGER_UI_HTML)
}
