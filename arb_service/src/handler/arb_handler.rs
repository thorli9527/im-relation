use std::sync::Arc;

use axum::{http::HeaderMap, Extension, Json};
use common::arb::{
    BaseRequest, CommonResp, NodeInfo, NodeInfoList, QueryNodeReq, RegisterRequest, ACCESS_HEADER,
};
use common::config::grpc_access_token;
use common::errors::AppError;
use serde_json::json;

use crate::service::arb_service::ArbService;

/// Web 层上下文，封装仲裁服务实例及访问令牌。
pub struct WebContext {
    service: ArbService,
    token: Option<String>,
}

impl WebContext {
    pub fn new(service: ArbService) -> Self {
        Self {
            service,
            token: grpc_access_token(),
        }
    }

    fn authorize(&self, headers: &HeaderMap) -> Result<(), AppError> {
        let expected = self
            .token
            .as_deref()
            .ok_or_else(|| AppError::Unauthorized("arb access token not configured".into()))?;

        let provided = headers
            .get(ACCESS_HEADER)
            .and_then(|value| value.to_str().ok())
            .ok_or_else(|| AppError::Unauthorized("missing arb access token".into()))?;

        if provided == expected {
            Ok(())
        } else {
            Err(AppError::Unauthorized("invalid arb access token".into()))
        }
    }
}

pub async fn register_node(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<RegisterRequest>,
) -> Result<Json<CommonResp>, AppError> {
    ctx.authorize(&headers)?;
    ctx.service.register_node(payload).await.map(Json)
}

pub async fn heartbeat(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<BaseRequest>,
) -> Result<Json<CommonResp>, AppError> {
    ctx.authorize(&headers)?;
    ctx.service.heartbeat(payload).await.map(Json)
}

pub async fn update_shard_state(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<BaseRequest>,
) -> Result<Json<CommonResp>, AppError> {
    ctx.authorize(&headers)?;
    ctx.service.update_shard_state(payload).await.map(Json)
}

pub async fn graceful_leave(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<NodeInfo>,
) -> Result<Json<CommonResp>, AppError> {
    ctx.authorize(&headers)?;
    ctx.service.graceful_leave(payload).await.map(Json)
}

pub async fn list_all_nodes(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<QueryNodeReq>,
) -> Result<Json<NodeInfoList>, AppError> {
    ctx.authorize(&headers)?;
    ctx.service.list_all_nodes(payload).await.map(Json)
}

pub async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}

pub fn context_arc(service: ArbService) -> Arc<WebContext> {
    Arc::new(WebContext::new(service))
}
