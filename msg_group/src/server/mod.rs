//! msg_group server module: splits gRPC and HTTP endpoints across dedicated listeners.

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::NodeType;
use common::config::{get_db, AppConfig, MySqlPool};
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

    let configured_group_nodes = AppConfig::get().urls_for_node_type(NodeType::GroupNode);
    let hot_group_addr = configured_group_nodes
        .into_iter()
        .find(|addr| addr != &advertise_addr);

    let group_client = match hot_group_addr {
        Some(addr) if addr == advertise_addr => {
            warn!(
                "configured hot_group addr {} matches local bind; skip hot_group client init",
                addr
            );
            None
        }
        Some(addr) => match connect_hot_group(&addr).await {
            Ok(cli) => Some(cli),
            Err(err) => {
                warn!("hot_group client connect failed: {}", err);
                None
            }
        },
        None => {
            warn!("no hot_group address provided in config; skip client init");
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
