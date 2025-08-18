use std::sync::Arc;

use actix_web::{
    delete, get, post,
    web::{Data, Json, Path, ServiceConfig},
    HttpResponse, Responder, Result,
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

#[derive(Debug, Serialize)]
pub struct ErrResp {
    pub ok: bool,
    pub code: &'static str,
    pub message: String,
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
#[get("/healthz")]
pub async fn healthz() -> impl Responder {
    HttpResponse::Ok().json(OkResp { ok: true })
}

/// 设置某用户在线/离线（幂等）
#[post("/online/{user_id}")]
pub async fn set_online(
    path: Path<i64>,
    state: Data<AppState>,
    body: Json<SetOnlineBody>,
) -> Result<impl Responder> {
    let uid: UserId = (*path) as UserId;
    state.store.set_online(uid, body.online);
    Ok(HttpResponse::Ok().json(OkResp { ok: true }))
}

/// 将用户置为离线（DELETE 语义）
#[delete("/online/{user_id}")]
pub async fn set_offline(path: Path<i64>, state: Data<AppState>) -> Result<impl Responder> {
    let uid: UserId = (*path) as UserId;
    state.store.set_online(uid, false);
    Ok(HttpResponse::Ok().json(OkResp { ok: true }))
}

/// 单查是否在线
#[get("/online/{user_id}")]
pub async fn check_online(path: Path<i64>, state: Data<AppState>) -> Result<impl Responder> {
    let uid: UserId = (*path) as UserId;
    let online = state.store.contains(uid);
    Ok(HttpResponse::Ok().json(serde_json::json!({ "online": online })))
}

/// 批量查询是否在线（返回顺序与请求 user_ids 对齐）
#[post("/online/batch/check")]
pub async fn check_online_batch(
    state: Data<AppState>,
    body: Json<BatchCheckReq>,
) -> Result<impl Responder> {
    // 为了兼容你的 OnlineStore 版本，这里逐个查询，保证顺序一致。
    // 若你实现了 contains_many_ordered，可直接用它替代下述 map。
    let results: Vec<bool> = body
        .user_ids
        .iter()
        .map(|&u| state.store.contains(u as UserId))
        .collect();

    Ok(HttpResponse::Ok().json(BatchCheckResp { results }))
}

/// 批量设置在线/离线（分片一次写锁，吞吐高）
#[post("/online/batch/set")]
pub async fn set_online_batch(
    state: Data<AppState>,
    body: Json<BatchSetReq>,
) -> Result<impl Responder> {
    // 先统计变更前的状态，计算真正的变更量（可选：也可以由 store 返回 delta）
    // 这里走两步法：读->写（在强一致要求不高的 REST 下通常够用）
    let mut added: u64 = 0;
    let mut removed: u64 = 0;

    // 收集项并计算预期 delta（仅用于响应统计，不影响幂等性）
    for it in &body.items {
        let uid = it.user_id as UserId;
        let cur = state.store.contains(uid);
        if it.online && !cur {
            added += 1;
        } else if !it.online && cur {
            removed += 1;
        }
    }

    // 真正落地：一次分片一次写锁，吞吐高
    state
        .store
        .set_online_many(body.items.iter().map(|it| (it.user_id as UserId, it.online)));

    Ok(HttpResponse::Ok().json(BatchSetResp {
        ok: true,
        added,
        removed,
    }))
}

/// 获取统计
#[get("/online/_stats")]
pub async fn get_stats(state: Data<AppState>) -> Result<impl Responder> {
    let s = state.store.stats();
    Ok(HttpResponse::Ok().json(StatsResp {
        total: s.total,
        per_shard: s.per_shard,
        max_shard_idx: s.max_shard.0,
        max_shard_count: s.max_shard.1,
    }))
}

/// 路由聚合
pub fn config(cfg: &mut ServiceConfig) {
    cfg.service(healthz)
        .service(set_online)
        .service(set_offline)
        .service(check_online)
        .service(check_online_batch)
        .service(set_online_batch)
        .service(get_stats);
}
