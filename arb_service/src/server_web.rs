use axum::{
    routing::{get, post},
    Extension, Router,
};

use crate::handler::arb_handler::{
    context_arc, graceful_leave, healthz, heartbeat, list_all_nodes, register_node,
    update_shard_state,
};
use crate::service::arb_service::ArbService;

/// 构建仲裁服务的 HTTP 路由，将业务服务与鉴权上下文注入到 handler。
pub fn router(service: ArbService) -> Router {
    let ctx = context_arc(service);

    Router::new()
        .route("/healthz", get(healthz))
        .route("/arb/server/register", post(register_node))
        .route("/arb/server/heartbeat", post(heartbeat))
        .route("/arb/server/update-shard", post(update_shard_state))
        .route("/arb/server/graceful-leave", post(graceful_leave))
        .route("/arb/server/list", post(list_all_nodes))
        .layer(Extension(ctx))
}
