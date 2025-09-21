use std::sync::Arc;

use axum::{
    extract::{Path, State},
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};

use crate::online_store::OnlineStore;
use common::UserId;

/// 全局共享状态
#[derive(Clone)]
pub struct AppState {
    pub store: Arc<OnlineStore>,
}

/// 通用响应
#[derive(Debug, Serialize)]
pub struct OkResp {
    pub ok: bool,
}

/// 置在线/离线请求体
#[derive(Debug, Deserialize)]
pub struct SetOnlineBody {
    pub online: bool,
}

/// 批量查询请求体
#[derive(Debug, Deserialize)]
pub struct BatchCheckReq {
    pub user_ids: Vec<i64>,
}

/// 批量查询响应体（顺序与请求一致）
#[derive(Debug, Serialize)]
pub struct BatchCheckResp {
    pub results: Vec<bool>,
}

/// 批量设置请求体
#[derive(Debug, Deserialize)]
pub struct BatchSetReq {
    pub items: Vec<BatchSetItem>,
}

#[derive(Debug, Deserialize)]
pub struct BatchSetItem {
    pub user_id: i64,
    pub online: bool,
}

/// 批量设置响应体
#[derive(Debug, Serialize)]
pub struct BatchSetResp {
    pub ok: bool,
    pub added: u64,
    pub removed: u64,
}

/// 统计响应体
#[derive(Debug, Serialize)]
pub struct StatsResp {
    pub total: u64,
    pub per_shard: Vec<u64>,
    pub max_shard_idx: usize,
    pub max_shard_count: u64,
}

/// 健康检查
pub async fn healthz() -> impl IntoResponse {
    Json(OkResp { ok: true })
}

/// 设置某用户在线/离线（幂等）
pub async fn set_online(
    Path(user_id): Path<i64>,
    State(state): State<AppState>,
    Json(body): Json<SetOnlineBody>,
) -> impl IntoResponse {
    let uid: UserId = user_id as UserId;
    state.store.set_online(uid, body.online);
    Json(OkResp { ok: true })
}

/// 将用户置为离线（DELETE 语义）
pub async fn set_offline(
    Path(user_id): Path<i64>,
    State(state): State<AppState>,
) -> impl IntoResponse {
    let uid: UserId = user_id as UserId;
    state.store.set_online(uid, false);
    Json(OkResp { ok: true })
}

/// 单查是否在线
pub async fn check_online(
    Path(user_id): Path<i64>,
    State(state): State<AppState>,
) -> impl IntoResponse {
    let uid: UserId = user_id as UserId;
    let online = state.store.contains(uid);
    Json(serde_json::json!({ "online": online }))
}

/// 批量查询是否在线（返回顺序与请求 user_ids 对齐）
pub async fn check_online_batch(
    State(state): State<AppState>,
    Json(body): Json<BatchCheckReq>,
) -> impl IntoResponse {
    let results: Vec<bool> = body
        .user_ids
        .iter()
        .map(|&u| state.store.contains(u as UserId))
        .collect();

    Json(BatchCheckResp { results })
}

/// 批量设置在线/离线（分片一次写锁，吞吐高）
pub async fn set_online_batch(
    State(state): State<AppState>,
    Json(body): Json<BatchSetReq>,
) -> impl IntoResponse {
    let mut added: u64 = 0;
    let mut removed: u64 = 0;

    for it in &body.items {
        let uid = it.user_id as UserId;
        let cur = state.store.contains(uid);
        if it.online && !cur {
            added += 1;
        } else if !it.online && cur {
            removed += 1;
        }
    }

    state.store.set_online_many(
        body.items
            .iter()
            .map(|it| (it.user_id as UserId, it.online)),
    );

    Json(BatchSetResp {
        ok: true,
        added,
        removed,
    })
}

/// 获取统计
pub async fn get_stats(State(state): State<AppState>) -> impl IntoResponse {
    let s = state.store.stats();
    Json(StatsResp {
        total: s.total,
        per_shard: s.per_shard,
        max_shard_idx: s.max_shard.0,
        max_shard_count: s.max_shard.1,
    })
}

/// 构建 REST 路由
pub fn router(state: AppState) -> Router {
    Router::new()
        .route("/healthz", get(healthz))
        .route(
            "/online/:user_id",
            get(check_online).post(set_online).delete(set_offline),
        )
        .route("/online/batch/check", post(check_online_batch))
        .route("/online/batch/set", post(set_online_batch))
        .route("/online/_stats", get(get_stats))
        .with_state(state)
}
