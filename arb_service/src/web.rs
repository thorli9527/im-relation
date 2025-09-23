use std::sync::Arc;

use axum::{http::HeaderMap, routing::post, Extension, Json, Router};
use common::arb::{
    BaseRequest, CommonResp, NodeInfo, NodeInfoList, QueryNodeReq, RegisterRequest, ACCESS_HEADER,
};
use common::config::grpc_access_token;
use common::errors::AppError;

use crate::service::arb_service::ArbService;

/// 构建仲裁服务的 HTTP 路由，将业务服务与鉴权上下文注入到 handler。
pub fn router(service: ArbService) -> Router {
    // ctx 持有共享的服务实例与访问令牌，用 Extension 注入请求上下文。
    let ctx = Arc::new(WebContext {
        service,
        token: grpc_access_token(),
    });

    Router::new()
        .route("/arb/server/register", post(register_node))
        .route("/arb/server/heartbeat", post(heartbeat))
        .route("/arb/server/update-shard", post(update_shard_state))
        .route("/arb/server/graceful-leave", post(graceful_leave))
        .route("/arb/server/list", post(list_all_nodes))
        .layer(Extension(ctx))
}

/// Web 层上下文，封装仲裁服务实例及访问令牌。
struct WebContext {
    /// 业务逻辑核心，用于真正的节点管理操作。
    service: ArbService,
    /// arb 接口访问令牌，可缺省关闭鉴权。
    token: Option<String>,
}

impl WebContext {
    /// 校验请求头中的访问令牌，确保调用方具备权限。
    fn authorize(&self, headers: &HeaderMap) -> Result<(), AppError> {
        // expected 为配置项中的令牌，若未配置直接拒绝访问。
        let expected = self
            .token
            .as_deref()
            .ok_or_else(|| AppError::Unauthorized("arb access token not configured".into()))?;

        // provided 从请求头中读取客户端上送的令牌字符串。
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

async fn register_node(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<RegisterRequest>,
) -> Result<Json<CommonResp>, AppError> {
    // 先执行访问令牌校验，再转发至核心服务。
    ctx.authorize(&headers)?;
    ctx.service.register_node(payload).await.map(Json)
}

async fn heartbeat(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<BaseRequest>,
) -> Result<Json<CommonResp>, AppError> {
    // 即使是心跳请求也需要带上访问令牌，防止未授权节点汇报。
    ctx.authorize(&headers)?;
    ctx.service.heartbeat(payload).await.map(Json)
}

async fn update_shard_state(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<BaseRequest>,
) -> Result<Json<CommonResp>, AppError> {
    // 分片状态更新沿用同一套鉴权机制。
    ctx.authorize(&headers)?;
    ctx.service.update_shard_state(payload).await.map(Json)
}

async fn graceful_leave(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<NodeInfo>,
) -> Result<Json<CommonResp>, AppError> {
    // 节点下线需要验证身份，避免非法删除。
    ctx.authorize(&headers)?;
    ctx.service.graceful_leave(payload).await.map(Json)
}

async fn list_all_nodes(
    Extension(ctx): Extension<Arc<WebContext>>,
    headers: HeaderMap,
    Json(payload): Json<QueryNodeReq>,
) -> Result<Json<NodeInfoList>, AppError> {
    // 列表查询同样保护在访问令牌之下，防止泄露集群拓扑。
    ctx.authorize(&headers)?;
    ctx.service.list_all_nodes(payload).await.map(Json)
}
