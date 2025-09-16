use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_arb_client::integration;
use crate::grpc_arb_client::server::start_arb_client_server;
use crate::grpc_hot_friend::friend_service::friend_service_server::FriendServiceServer;
use crate::hot_cold::HotColdFriendFacade;
use crate::service::friend_service_impl::FriendServiceImpl;
use crate::store::mysql::FriendStorage;
use actix_web::{get, App, HttpResponse, HttpServer};
use anyhow::{anyhow, Context, Result};
use common::config::{get_db, AppConfig};
use common::UserId;
use log::warn;
use tokio::signal;
use tonic::transport::Server;

pub async fn start() -> Result<()> {
    let cfg = AppConfig::get();
    let grpc_cfg = cfg
        .grpc
        .as_ref()
        .ok_or_else(|| anyhow!("grpc config missing"))?;
    let client_addr = grpc_cfg
        .client_addr
        .as_ref()
        .ok_or_else(|| anyhow!("grpc.client_addr missing"))?;
    let grpc_addr: SocketAddr = client_addr.parse().context("Failed to parse GRPC_ADDR")?;

    let avg_key_bytes = std::mem::size_of::<UserId>();
    let avg_value_bytes = env_parse("AVG_VALUE_BYTES", 256usize);
    let shards = env_parse("SHARDS", 32usize);
    let reserve_ratio = env_parse("AUTOTUNE_RESERVE_RATIO", 0.40_f64);
    let max_use_ratio = env_parse("AUTOTUNE_MAX_USE_RATIO", 0.25_f64);
    let overhead_factor = env_parse("AUTOTUNE_OVERHEAD_FACTOR", 1.6_f64);
    let hot_ratio = env_parse("AUTOTUNE_HOT_RATIO", 0.20_f64);
    let tti_secs = env_parse("AUTOTUNE_TTI_SECS", 60u64);
    let refresh_secs = env_parse("AUTOTUNE_REFRESH_SECS", 0u64);

    let mut tune_cfg = crate::autotune::AutoTuneConfig::default();
    tune_cfg.shards = shards.max(1);
    tune_cfg.avg_key_bytes = avg_key_bytes;
    tune_cfg.avg_value_bytes = avg_value_bytes;
    tune_cfg.reserve_ratio = reserve_ratio;
    tune_cfg.max_use_ratio = max_use_ratio;
    tune_cfg.overhead_factor = overhead_factor;
    tune_cfg.hot_ratio = hot_ratio;
    tune_cfg.default_tti = Duration::from_secs(tti_secs);

    let plan: crate::autotune::CacheAutoTune = crate::autotune::auto_tune_cache(&tune_cfg);

    let pool = get_db();
    crate::db::apply_schema_from_ddl(&pool, include_str!("../migrations/mysql_schema.sql")).await?;

    let storage = Arc::new(FriendStorage::from_pool(pool.clone()));
    let facade = Arc::new(HotColdFriendFacade::new(
        storage.clone(),
        plan.clone(),
        tokio::runtime::Handle::current(),
    ));

    if refresh_secs > 0 {
        let facade_clone = facade.clone();
        tokio::spawn(async move {
            let interval = Duration::from_secs(refresh_secs);
            loop {
                tokio::time::sleep(interval).await;
                facade_clone.refresh_by_autotune(
                    avg_key_bytes,
                    avg_value_bytes,
                    reserve_ratio,
                    max_use_ratio,
                    overhead_factor,
                    hot_ratio,
                    Duration::from_secs(tti_secs),
                );
            }
        });
    }

    let http_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let http_addr: SocketAddr = format!("{}:{}", http_cfg.host, http_cfg.port)
        .parse()
        .context("invalid http host:port")?;

    #[get("/healthz")]
    async fn healthz() -> actix_web::HttpResponse {
        HttpResponse::Ok().json(serde_json::json!({"ok": true}))
    }
    actix_web::rt::System::new().block_on(async move {
        HttpServer::new(|| App::new().service(healthz))
            .bind(http_addr)
            .expect("http bind error")
            .run()
            .await
            .expect("http server error");
    });

    start_arb_client_server(client_addr).await?;
    integration::start(NodeType::FriendNode).await?;

    let svc = FriendServiceImpl::<FriendStorage> { facade };
    Server::builder()
        .add_service(FriendServiceServer::new(svc))
        .serve_with_shutdown(grpc_addr, async {
            let _ = signal::ctrl_c().await;
        })
        .await?;

    Ok(())
}

fn env_parse<T>(key: &str, default: T) -> T
where
    T: std::str::FromStr + Copy,
{
    std::env::var(key)
        .ok()
        .and_then(|s| s.parse::<T>().ok())
        .unwrap_or(default)
}
