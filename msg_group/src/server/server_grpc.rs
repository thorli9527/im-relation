//! gRPC + HTTP 服务启动入口，同时负责仲裁注册与心跳。

use std::mem;
use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::{ArbHttpClient, BaseRequest, NodeType, RegisterRequest};
use common::config::{get_db, AppConfig, MySqlPool};
use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_GROUP_TOPIC;
use common::service::arb_client;
use log::{info, warn};
use serde_json::json;
use tokio::{signal, time};
use tonic::service::Routes;
use tonic::transport::Server as TonicServer;

use crate::service::hot_group_client::{connect as connect_hot_group, HgGroupClient};
use crate::service::{GroupBizServiceImpl, GroupMsgServiceImpl};
use common::grpc::grpc_msg_group::msg_group_service::group_biz_service_server::GroupBizServiceServer;
use common::grpc::grpc_msg_group::msg_group_service::group_msg_service_server::GroupMsgServiceServer;

/// 运行时依赖集合：数据库、热群服务客户端、Kafka 等。
#[derive(Clone)]
pub struct Services {
    /// 连接池，提供 MySQL 访问能力。
    pool: Arc<MySqlPool>,
    /// 可选的热群服务 gRPC 客户端，用于热点写分流。
    group_client: Option<HgGroupClient>,
    /// 可选 Kafka 生产者实例，用于消息推送。
    kafka: Option<Arc<KafkaInstanceService>>,
}

impl Services {
    /// 构造服务依赖集合。
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

    /// 返回数据库连接池。
    pub fn pool(&self) -> &MySqlPool {
        self.pool.as_ref()
    }

    /// 获取热群客户端引用（如存在）。
    pub fn group_client(&self) -> Option<&HgGroupClient> {
        self.group_client.as_ref()
    }

    /// 获取 Kafka 生产者引用（如存在）。
    pub fn kafka(&self) -> Option<&Arc<KafkaInstanceService>> {
        self.kafka.as_ref()
    }
}

/// 简单健康检查，供负载均衡探测。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}

/// 启动 msg_group 的 gRPC/HTTP 服务，并向仲裁中心注册。
pub async fn run_server() -> Result<()> {
    // cfg 为全局配置入口，需提前通过 main 初始化。
    let cfg = AppConfig::get();
    // server_cfg 提供 HTTP/gRPC 监听地址。
    let server_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let bind_addr_str = format!("{}:{}", server_cfg.host, server_cfg.port);
    let bind_addr: SocketAddr = bind_addr_str
        .parse()
        .with_context(|| format!("invalid server bind address: {}", bind_addr_str))?;

    // 仲裁中心客户端配置，包括访问地址与令牌。
    let arb_cfg = cfg.arb().ok_or_else(|| anyhow!("arb config missing"))?;
    // client_addr 是仲裁中心登记使用的地址。
    let client_addr = bind_addr_str.clone();

    // 数据库连接池（MySQL）由 common::config 提供。
    let pool = get_db();

    // socket_cfg 决定是否启用 Kafka 生产者（用于推送 socket 消息）。
    let socket_cfg = cfg.get_socket();
    let kafka = if let Some(broker) = socket_cfg.kafka_broker.clone() {
        let topics = vec![MSG_SEND_GROUP_TOPIC.clone()];
        match KafkaInstanceService::new(&broker, &topics).await {
            Ok(service) => Some(Arc::new(service)),
            Err(err) => {
                warn!("kafka init failed: {}", err);
                None
            }
        }
    } else {
        None
    };

    // HOT_GROUP_GRPC_ADDR 用于连接热点群服务；未配置则回退到本地地址。
    let hot_group_env = std::env::var("HOT_GROUP_GRPC_ADDR").ok();
    let hot_group_addr = hot_group_env
        .filter(|addr| !addr.is_empty())
        .unwrap_or_else(|| client_addr.clone());

    // 若目标地址与自身相同，则跳过以免死循环；否则尝试建立 gRPC 客户端。
    let group_client = if hot_group_addr == bind_addr_str {
        warn!(
            "HOT_GROUP_GRPC_ADDR {} matches local bind address; skip hot_group client init",
            hot_group_addr
        );
        None
    } else {
        match connect_hot_group(&hot_group_addr).await {
            Ok(cli) => Some(cli),
            Err(err) => {
                warn!("hot_group client connect failed: {}", err);
                None
            }
        }
    };

    // 汇总运行时依赖，供业务实现使用。
    let services = Arc::new(Services::new(pool, group_client, kafka));

    // HTTP 路由：目前仅提供 /healthz。
    let rest_router = Router::new().route("/healthz", get(healthz));

    // 构造 gRPC 服务实现
    let biz_service = GroupBizServiceImpl::new(services.clone());
    let msg_service = GroupMsgServiceImpl::new(services.clone());

    // 合并 gRPC 与 HTTP 路由，支持同端口服务（HTTP1/2）。
    let mut routes = Routes::new(GroupBizServiceServer::new(biz_service))
        .add_service(GroupMsgServiceServer::new(msg_service));
    // 注入仲裁 HTTP 网关，供 arb 节点调用。
    arb_client::attach_http_gateway(&mut routes);

    // 将 Axum router 插入 fallback，用于处理 HTTP REST。
    let router_slot = routes.axum_router_mut();
    *router_slot = mem::take(router_slot).fallback_service(rest_router);

    info!("msg_group listening on {} (HTTP + gRPC)", bind_addr_str);

    // 若配置了仲裁中心，则注册节点并启动心跳。
    if let Some(server_addr) = &arb_cfg.server_addr {
        let arb_http = ArbHttpClient::new(server_addr.clone(), arb_cfg.access_token.clone())?;
        arb_http
            .register_node(&RegisterRequest {
                node_addr: client_addr.clone(),
                node_type: NodeType::MesGroup as i32,
                kafka_addr: None,
            })
            .await?;
        spawn_heartbeat(arb_http.clone(), client_addr.clone());
    } else {
        warn!("arb.server_addr missing; skip arb registration");
    }

    // 启动 gRPC Server，支持优雅退出（Ctrl+C）。
    TonicServer::builder()
        .accept_http1(true)
        .add_routes(routes)
        .serve_with_shutdown(bind_addr, async {
            if let Err(err) = signal::ctrl_c().await {
                warn!("failed to listen for shutdown signal: {}", err);
            }
            warn!("Ctrl+C received, shutting down...");
        })
        .await
        .map_err(anyhow::Error::from)
}

/// 启动后台任务，定期向仲裁中心发送心跳。
fn spawn_heartbeat(client: ArbHttpClient, node_addr: String) {
    tokio::spawn(async move {
        let mut interval = time::interval(Duration::from_secs(10));
        loop {
            interval.tick().await;
            if let Err(err) = client
                .heartbeat(&BaseRequest {
                    node_addr: node_addr.clone(),
                    node_type: NodeType::MesGroup as i32,
                })
                .await
            {
                warn!("arb heartbeat failed: {}", err);
                time::sleep(Duration::from_secs(3)).await;
            }
        }
    });
}
