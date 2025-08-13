
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use common::UserId;
use dashmap::DashMap;
use parking_lot::RwLock;
use serde::{Serialize, Deserialize};
use std::collections::BTreeSet;
use std::sync::Arc;
use tracing_subscriber::{EnvFilter, fmt};

#[derive(Clone)]
struct AppState {
    friends: Arc<DashMap<UserId, Arc<RwLock<BTreeSet<UserId>>>>>,
    online_base: Option<String>,
    client: reqwest::Client,
}

impl AppState {
    fn get_or_create(&self, uid: UserId) -> Arc<RwLock<BTreeSet<UserId>>> {
        if let Some(v) = self.friends.get(&uid) { return v.clone(); }
        let entry = Arc::new(RwLock::new(BTreeSet::new()));
        let e2 = entry.clone(); self.friends.insert(uid, entry); e2
    }
}

#[derive(Serialize)]
struct FriendListResp {
    friends: Vec<UserId>,
    total: u64,
    online: Option<Vec<UserId>>,
}

#[derive(Deserialize)]
struct PageQ { page: Option<usize>, size: Option<usize>, include_online: Option<u8> }

async fn add_friend(state: web::Data<AppState>, path: web::Path<(UserId, UserId)>) -> impl Responder {
    let (uid, fid) = path.into_inner();
    if uid == fid { return HttpResponse::BadRequest().body("uid == fid"); }
    let a = state.get_or_create(uid); let b = state.get_or_create(fid);
    { a.write().insert(fid); } { b.write().insert(uid); }
    HttpResponse::Ok().finish()
}
async fn remove_friend(state: web::Data<AppState>, path: web::Path<(UserId, UserId)>) -> impl Responder {
    let (uid, fid) = path.into_inner();
    if let Some(a) = state.friends.get(&uid) { a.write().remove(&fid); }
    if let Some(b) = state.friends.get(&fid) { b.write().remove(&uid); }
    HttpResponse::Ok().finish()
}
async fn list_friends(state: web::Data<AppState>, path: web::Path<(UserId,)>, q: web::Query<PageQ>) -> impl Responder {
    let uid = path.into_inner().0;
    let page = q.page.unwrap_or(1).max(1); let size = q.size.unwrap_or(50).min(1000);
    let start = (page - 1) * size;
    let set = state.get_or_create(uid); let guard = set.read();
    let total = guard.len() as u64;
    let items: Vec<UserId> = guard.iter().skip(start).take(size).copied().collect();
    let mut online: Option<Vec<UserId>> = None;
    if q.include_online.unwrap_or(0) == 1 {
        if let Some(base) = &state.online_base {
            if let Ok(resp) = state.client.post(format!("{}/online/batch_check", base))
                .json(&serde_json::json!({ "uids": items }))
                .send().await
            {
                if let Ok(v) = resp.json::<serde_json::Value>().await {
                    online = v.get("online").and_then(|x| x.as_array()).map(|arr| {
                        arr.iter().filter_map(|v| v.as_i64()).collect::<Vec<_>>()
                    });
                }
            }
        }
    }
    HttpResponse::Ok().json(serde_json::json!({ "friends": items, "total": total, "online": online }))
}
async fn healthz() -> impl Responder { HttpResponse::Ok().body("ok") }

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let _ = fmt().with_env_filter(EnvFilter::from_default_env()).try_init();
    let port: u16 = std::env::var("PORT").ok().and_then(|s| s.parse().ok()).unwrap_or(8083);
    let online_base = std::env::var("ONLINE_BASE_URL").ok();
    println!("friend-service listening on 0.0.0.0:{port}, ONLINE_BASE_URL={:?}", online_base);
    let state = AppState { friends: Arc::new(DashMap::new()), online_base, client: reqwest::Client::new() };
    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(state.clone()))
            .route("/friends/{uid}/{fid}", web::post().to(add_friend))
            .route("/friends/{uid}/{fid}", web::delete().to(remove_friend))
            .route("/friends/{uid}", web::get().to(list_friends))
            .route("/healthz", web::get().to(healthz))
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
