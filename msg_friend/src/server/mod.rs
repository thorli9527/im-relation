//! msg_friend server module: split gRPC and HTTP endpoints with dedicated listeners.

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::config::{get_db, AppConfig, ServiceEndpoint};
use common::kafka::kafka_producer::KafkaInstanceService;
use log::{info, warn};
use serde_json::json;
use sqlx::{MySql, Pool};
use tokio::signal;
use tokio_util::sync::CancellationToken;
use tonic::service::Routes;

use crate::hot_friend_client::{connect as connect_hot_friend, HfFriendClient};
use crate::service::friend_biz_service_impl::MsgFriendServiceImpl;
use common::grpc::grpc_msg_friend::msg_friend_service::friend_biz_service_server::FriendBizServiceServer;
use common::grpc::grpc_msg_friend::msg_friend_service::friend_msg_service_server::FriendMsgServiceServer;
use common::grpc::grpc_msg_friend::msg_friend_service::key_service_server::KeyServiceServer;

mod kafka_producer;
mod server_grpc;
mod server_web;

use kafka_producer::init_friend_kafka;

/// 运行时依赖集合。
#[derive(Clone)]
pub struct Services {
    pool: Arc<Pool<MySql>>,
    friend_client: Option<HfFriendClient>,
    kafka: Option<Arc<KafkaInstanceService>>,
    shard_index: u32,
    shard_total: u32,
}

impl Services {
    pub fn friend_client(&self) -> Option<&HfFriendClient> {
        self.friend_client.as_ref()
    }

    pub fn pool(&self) -> &Pool<MySql> {
        &self.pool
    }

    pub fn kafka(&self) -> Option<&Arc<KafkaInstanceService>> {
        self.kafka.as_ref()
    }

    pub fn shard_index(&self) -> u32 {
        self.shard_index
    }

    pub fn shard_total(&self) -> u32 {
        self.shard_total
    }
}

fn normalize_endpoint_str(endpoint: &str) -> &str {
    endpoint
        .strip_prefix("http://")
        .or_else(|| endpoint.strip_prefix("https://"))
        .unwrap_or(endpoint)
}

fn select_remote_endpoint(
    endpoints: &[ServiceEndpoint],
    advertise_addr: &str,
    service_name: &str,
) -> Result<String> {
    if endpoints.is_empty() {
        return Err(anyhow!(
            "{service_name} client endpoint missing in config; please configure at least one entry"
        ));
    }

    let advertise_norm = normalize_endpoint_str(advertise_addr);

    endpoints
        .iter()
        .filter_map(|endpoint| endpoint.resolved_url())
        .find(|url| normalize_endpoint_str(url) != advertise_norm)
        .ok_or_else(|| {
            anyhow!(
                "{service_name} client endpoint missing in config (only local address {advertise_addr} configured)"
            )
        })
}

/// 启动好友消息服务（HTTP + gRPC）并完成仲裁注册。
pub async fn run_server() -> Result<()> {
    let cfg = AppConfig::get();
    let server_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;

    let grpc_addr_str = server_cfg
        .require_grpc_addr()
        .context("server.grpc missing host/port")?;
    let http_addr_str = server_cfg
        .require_http_addr()
        .context("server.http missing host/port")?;

    let grpc_addr: SocketAddr = grpc_addr_str
        .parse()
        .with_context(|| format!("invalid server bind address: {}", grpc_addr_str))?;
    let http_addr: SocketAddr = http_addr_str
        .parse()
        .with_context(|| format!("invalid http bind address: {}", http_addr_str))?;

    let advertise_addr = grpc_addr_str.clone();
    let overrides = cfg.msg_friend_cfg();

    let pool = get_db();

    let friend_endpoint = select_remote_endpoint(
        cfg.friend_service_endpoints(),
        &advertise_addr,
        "friend_service",
    )?;

    let friend_client = match connect_hot_friend(&friend_endpoint).await {
        Ok(client) => Some(client),
        Err(err) => {
            warn!(
                "friend_service client connect to {} failed: {}",
                friend_endpoint, err
            );
            None
        }
    };

    let kafka_instance = init_friend_kafka(&cfg).await?;
    let kafka = Some(kafka_instance.clone());

    let shard_total: u32 = overrides.shard_total.unwrap_or(16);
    let shard_index: u32 = overrides.shard_index.unwrap_or(0);

    let services = Services {
        pool,
        friend_client,
        kafka,
        shard_index,
        shard_total,
    };

    let http_router = Router::new().route("/healthz", get(healthz));

    let friend_biz_service_server =
        FriendBizServiceServer::new(MsgFriendServiceImpl::new(Arc::new(services.clone())));
    let msg_service_server = FriendMsgServiceServer::new(services.clone());
    let key_service_server = KeyServiceServer::new(services.clone());
    let routes = Routes::new(msg_service_server)
        .add_service(friend_biz_service_server)
        .add_service(key_service_server);

    info!(
        "msg_friend listening on grpc={} http={}",
        grpc_addr_str, http_addr_str
    );

    info!(
        "msg_friend registration via arb removed; serving grpc={} http={}",
        grpc_addr_str, http_addr_str
    );

    let cancel_token = CancellationToken::new();
    let http_cancel = cancel_token.clone();
    let grpc_cancel = cancel_token.clone();

    let mut http_future = Box::pin(server_web::serve(http_addr, http_router, async move {
        http_cancel.cancelled().await;
    }));

    let mut grpc_future = Box::pin(server_grpc::serve(grpc_addr, routes, async move {
        grpc_cancel.cancelled().await;
        warn!("Ctrl+C received, shutting down...");
    }));

    tokio::select! {
        res = &mut http_future => {
            res.with_context(|| "http server exited unexpectedly")?;
            cancel_token.cancel();
        }
        res = &mut grpc_future => {
            res.with_context(|| "grpc server exited unexpectedly")?;
            cancel_token.cancel();
        }
        _ = signal::ctrl_c() => {
            warn!("Ctrl+C received, shutting down...");
            cancel_token.cancel();
        }
    }

    http_future
        .await
        .with_context(|| "http server shutdown failed")?;
    grpc_future
        .await
        .with_context(|| "grpc server shutdown failed")?;

    Ok(())
}

/// 简易健康检查。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({"ok": true}))
}
