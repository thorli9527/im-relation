//! msg_group server module: splits gRPC and HTTP endpoints across dedicated listeners.

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::NodeType;
use common::config::{get_db, AppConfig, MySqlPool};
use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_GROUP_TOPIC;
use common::service::arb_client;
use log::{info, warn};
use serde_json::json;
use tokio::signal;
use tokio_util::sync::CancellationToken;
use tonic::service::Routes;

use crate::service::hot_group_client::{connect as connect_hot_group, HgGroupClient};
use crate::service::{GroupBizServiceImpl, GroupMsgServiceImpl};
use common::grpc::grpc_msg_group::msg_group_service::group_biz_service_server::GroupBizServiceServer;
use common::grpc::grpc_msg_group::msg_group_service::group_msg_service_server::GroupMsgServiceServer;

mod server_grpc;
mod server_web;

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

    let kafka_cfg = cfg.kafka_cfg();
    let mut kafka_broker_for_arb = kafka_cfg.broker.clone();
    let kafka = if let Some(ref broker) = kafka_cfg.broker {
        kafka_broker_for_arb = Some(broker.clone());
        let topics = vec![MSG_SEND_GROUP_TOPIC.clone()];
        match KafkaInstanceService::new(broker, &topics).await {
            Ok(service) => Some(Arc::new(service)),
            Err(err) => {
                warn!("kafka init failed: {}", err);
                None
            }
        }
    } else {
        warn!("kafka.broker not configured for msg_group; kafka producer disabled");
        None
    };

    let arb_group_nodes = match arb_client::ensure_nodes(NodeType::GroupNode).await {
        Ok(nodes) => nodes,
        Err(err) => {
            warn!("fetch hot_group nodes from arb failed: {}", err);
            Vec::new()
        }
    };

    let hot_group_addr = arb_group_nodes
        .into_iter()
        .map(|node| node.kafka_addr.unwrap_or(node.node_addr))
        .find(|addr| addr != &advertise_addr);

    let group_client = match hot_group_addr {
        Some(addr) if addr == advertise_addr => {
            warn!(
                "arb hot_group addr {} matches local bind; skip hot_group client init",
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
            warn!("no remote hot_group address discovered via arb; skip client init");
            None
        }
    };

    let services = Arc::new(Services::new(pool, group_client, kafka));

    let http_router = Router::new()
        .route("/healthz", get(healthz))
        .merge(arb_client::http_router());

    let biz_service = GroupBizServiceImpl::new(services.clone());
    let msg_service = GroupMsgServiceImpl::new(services.clone());
    let routes = Routes::new(GroupBizServiceServer::new(biz_service))
        .add_service(GroupMsgServiceServer::new(msg_service));

    info!(
        "msg_group listening on grpc={} http={}",
        grpc_addr_str, http_addr_str
    );

    arb_client::register_node(
        NodeType::MesGroup,
        http_addr_str.clone(),
        kafka_broker_for_arb.clone(),
        None,
    )
    .await?;

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
