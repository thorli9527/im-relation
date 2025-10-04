//! msg_group server module: splits gRPC and HTTP endpoints across dedicated listeners.

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::config::{get_db, AppConfig, MySqlPool, ServiceEndpoint};
use common::kafka::kafka_producer::KafkaInstanceService;
use log::{info, warn};
use serde_json::json;
use tokio::signal;
use tokio_util::sync::CancellationToken;
use tonic::service::Routes;

use crate::service::hot_group_client::{connect as connect_hot_group, HgGroupClient};
use crate::service::{GroupBizServiceImpl, GroupMsgServiceImpl};
use common::grpc::grpc_msg_group::msg_group_service::group_biz_service_server::GroupBizServiceServer;
use common::grpc::grpc_msg_group::msg_group_service::group_msg_service_server::GroupMsgServiceServer;

mod kafka_producer;
mod server_grpc;
mod server_web;

use kafka_producer::init_group_kafka;

/// 运行时依赖集合：数据库、热群服务客户端、Kafka 等。
#[derive(Clone)]
pub struct Services {
    pool: Arc<MySqlPool>,
    group_client: Option<HgGroupClient>,
    kafka: Option<Arc<KafkaInstanceService>>,
}

impl Services {
    pub fn new(
        pool: Arc<MySqlPool>,
        group_client: Option<HgGroupClient>,
        kafka: Option<Arc<KafkaInstanceService>>,
    ) -> Self {
        Self {
            pool,
            group_client,
            kafka,
        }
    }

    pub fn pool(&self) -> &MySqlPool {
        self.pool.as_ref()
    }

    pub fn group_client(&self) -> Option<&HgGroupClient> {
        self.group_client.as_ref()
    }

    pub fn kafka(&self) -> Option<&Arc<KafkaInstanceService>> {
        self.kafka.as_ref()
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

/// 启动 msg_group 的 gRPC/HTTP 服务，并向仲裁中心注册。
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

    let pool = get_db();

    let kafka = Some(init_group_kafka(&cfg).await?);

    let group_endpoint = select_remote_endpoint(
        cfg.group_service_endpoints(),
        &advertise_addr,
        "group_service",
    )?;

    let group_client = match connect_hot_group(&group_endpoint).await {
        Ok(client) => Some(client),
        Err(err) => {
            warn!(
                "group_service client connect to {} failed: {}",
                group_endpoint, err
            );
            None
        }
    };

    let services = Arc::new(Services::new(pool, group_client, kafka));

    let http_router = Router::new().route("/healthz", get(healthz));

    let biz_service = GroupBizServiceImpl::new(services.clone());
    let msg_service = GroupMsgServiceImpl::new(services.clone());
    let routes = Routes::new(GroupBizServiceServer::new(biz_service))
        .add_service(GroupMsgServiceServer::new(msg_service));

    info!(
        "msg_group listening on grpc={} http={}",
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

/// 简单健康检查，供负载均衡探测。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}
