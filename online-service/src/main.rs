
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use dashmap::DashSet;
use std::sync::Arc;
use common::UserId;
use tracing_subscriber::{EnvFilter, fmt};

#[derive(Clone)]
struct AppState { online: Arc<DashSet<UserId>> }

#[derive(serde::Deserialize)]
struct BatchCheck { uids: Vec<UserId> }

async fn set_online(state: web::Data<AppState>, path: web::Path<(UserId,)>) -> impl Responder {
    let uid = path.into_inner().0; state.online.insert(uid); HttpResponse::Ok().finish()
}
async fn set_offline(state: web::Data<AppState>, path: web::Path<(UserId,)>) -> impl Responder {
    let uid = path.into_inner().0; state.online.remove(&uid); HttpResponse::Ok().finish()
}
async fn batch_check(state: web::Data<AppState>, body: web::Json<BatchCheck>) -> impl Responder {
    let online: Vec<UserId> = body.uids.iter().copied().filter(|u| state.online.contains(u)).collect();
    HttpResponse::Ok().json(serde_json::json!({ "online": online }))
}
async fn healthz() -> impl Responder { HttpResponse::Ok().body("ok") }

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let _ = fmt().with_env_filter(EnvFilter::from_default_env()).try_init();
    let state = AppState { online: Arc::new(DashSet::new()) };
    let port: u16 = std::env::var("PORT").ok().and_then(|s| s.parse().ok()).unwrap_or(8081);
    println!("online-service listening on 0.0.0.0:{port}");
    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(state.clone()))
            .route("/online/{uid}", web::post().to(set_online))
            .route("/online/{uid}", web::delete().to(set_offline))
            .route("/online/batch_check", web::post().to(batch_check))
            .route("/healthz", web::get().to(healthz))
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
