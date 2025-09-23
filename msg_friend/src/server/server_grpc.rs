//! 好友消息服务的 gRPC/HTTP 入口，负责仲裁注册与心跳。

use std::mem;
use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::{ArbHttpClient, BaseRequest, NodeType, RegisterRequest};
use common::config::{get_db, AppConfig};
use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_FRIEND_TOPIC;
use common::service::arb_client;
use log::{info, warn};
use serde_json::json;
use sqlx::{MySql, Pool};
use tokio::{signal, time};
use tonic::service::Routes;
use tonic::transport::Server as TonicServer;

use crate::hot_friend_client::{connect as connect_hot_friend, HfFriendClient};
use crate::service::friend_biz_service_impl::MsgFriendServiceImpl;
use common::grpc::grpc_msg_friend::msg_friend_service::friend_biz_service_server::FriendBizServiceServer;
use common::grpc::grpc_msg_friend::msg_friend_service::friend_msg_service_server::FriendMsgServiceServer;
use common::grpc::grpc_msg_friend::msg_friend_service::key_service_server::KeyServiceServer;

/// 运行时依赖集合。
#[derive(Clone)]
pub struct Services {
    /// MySQL 连接池。
    pool: Arc<Pool<MySql>>,
    /// 可选的热好友客户端。
    friend_client: Option<HfFriendClient>,
    /// 可选 Kafka 推送实例。
    kafka: Option<Arc<KafkaInstanceService>>,
    /// 当前节点的分片序号。
    shard_index: u32,
    /// 分片总数。
    shard_total: u32,
}

impl Services {
    /// 热好友客户端引用（如存在）。
    pub fn friend_client(&self) -> Option<&HfFriendClient> {
        self.friend_client.as_ref()
    }

    /// MySQL 连接池引用。
    pub fn pool(&self) -> &Pool<MySql> {
        &self.pool
    }

    /// Kafka 实例。
    pub fn kafka(&self) -> Option<&Arc<KafkaInstanceService>> {
        self.kafka.as_ref()
    }

    /// 返回分片序号。
    pub fn shard_index(&self) -> u32 {
        self.shard_index
    }

    /// 返回分片总数。
    pub fn shard_total(&self) -> u32 {
        self.shard_total
    }
}

/// 简易健康检查。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({"ok": true}))
}

/// 启动好友消息服务（HTTP + gRPC）并完成仲裁注册。
pub async fn run_server() -> Result<()> {
    let cfg = AppConfig::get();
    let server_cfg = cfg
        .server
        .as_ref()
        .ok_or_else(|| anyhow!("server config missing"))?;
    let bind_addr_str = format!("{}:{}", server_cfg.host, server_cfg.port);
    let bind_addr: SocketAddr = bind_addr_str
        .parse()
        .with_context(|| format!("invalid server bind address: {}", bind_addr_str))?;

    let arb_cfg = cfg.arb().ok_or_else(|| anyhow!("arb config missing"))?;

    let client_addr = bind_addr_str.clone();

    let pool = get_db();

    let friend_client_addr = std::env::var("HOT_FRIEND_GRPC_ADDR")
        .ok()
        .filter(|addr| !addr.is_empty())
        .unwrap_or_else(|| client_addr.clone());
    let friend_client = if friend_client_addr == bind_addr_str {
        warn!(
            "friend_client addr {} matches service bind address; skip hot_friend client init",
            friend_client_addr
        );
        None
    } else {
        match connect_hot_friend(&friend_client_addr).await {
            Ok(c) => Some(c),
            Err(e) => {
                warn!("friend client connect failed: {}", e);
                None
            }
        }
    };

    let socket_cfg = cfg.get_socket();
    let kafka = if let Some(broker) = socket_cfg.kafka_broker.clone() {
        let topics = vec![MSG_SEND_FRIEND_TOPIC.clone()];
        match KafkaInstanceService::new(&broker, &topics).await {
            Ok(svc) => Some(Arc::new(svc)),
            Err(e) => {
                warn!("kafka init failed: {}", e);
                None
            }
        }
    } else {
        None
    };

    let shard_total: u32 = std::env::var("FRIEND_SHARD_TOTAL")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(16);
    let shard_index: u32 = std::env::var("FRIEND_SHARD_INDEX")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(0);

    let services = Services {
        pool,
        friend_client,
        kafka,
        shard_index,
        shard_total,
    };

    let rest_router = Router::new().route("/healthz", get(healthz));

    let friend_biz_service_server =
        FriendBizServiceServer::new(MsgFriendServiceImpl::new(Arc::new(services.clone())));
    let msg_service_server = FriendMsgServiceServer::new(services.clone());
    let key_service_server = KeyServiceServer::new(services.clone());
    let mut routes = Routes::new(msg_service_server)
        .add_service(friend_biz_service_server)
        .add_service(key_service_server);
    arb_client::attach_http_gateway(&mut routes);

    let router_slot = routes.axum_router_mut();
    *router_slot = mem::take(router_slot).fallback_service(rest_router);

    info!("msg_friend listening on {} (HTTP + gRPC)", bind_addr_str);

    if let Some(server_addr) = &arb_cfg.server_addr {
        let arb_http = ArbHttpClient::new(server_addr.clone(), arb_cfg.access_token.clone())?;
        arb_http
            .register_node(&RegisterRequest {
                node_addr: client_addr.clone(),
                node_type: NodeType::MsgFriend as i32,
                kafka_addr: None,
            })
            .await?;
        spawn_heartbeat(arb_http.clone(), client_addr.clone());
    }

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

/// 启动后台心跳任务，保持仲裁活跃状态。
fn spawn_heartbeat(client: ArbHttpClient, node_addr: String) {
    tokio::spawn(async move {
        let mut interval = time::interval(Duration::from_secs(10));
        loop {
            interval.tick().await;
            if let Err(err) = client
                .heartbeat(&BaseRequest {
                    node_addr: node_addr.clone(),
                    node_type: NodeType::MsgFriend as i32,
                })
                .await
            {
                warn!("arb heartbeat failed: {}", err);
                time::sleep(Duration::from_secs(3)).await;
            }
        }
    });
}
