use std::mem;
use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::config::{get_db, AppConfig};
use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_FRIEND_TOPIC;
use log::{info, warn};
use serde_json::json;
use sqlx::{MySql, Pool};
use tokio::signal;
use tonic::service::Routes;
use tonic::transport::Server as TonicServer;

use crate::grpc_arb::arb_server::arb_client_rpc_service_server::ArbClientRpcServiceServer;
use crate::grpc_arb_client::server::ArbClientImpl;
use crate::grpc_hot_friend::client::{connect as connect_hot_friend, HfFriendClient};
use crate::grpc_msg_friend::msg_friend_service::friend_biz_service_server::FriendBizServiceServer;
use crate::grpc_msg_friend::msg_friend_service::friend_msg_service_server::FriendMsgServiceServer;
use crate::grpc_msg_friend::msg_friend_service::key_service_server::KeyServiceServer;
use crate::service::friend_biz_service_impl::MsgFriendServiceImpl;

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

async fn healthz() -> Json<serde_json::Value> {
    Json(json!({"ok": true}))
}

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

    let grpc_cfg = cfg
        .grpc
        .as_ref()
        .ok_or_else(|| anyhow!("grpc config missing"))?;

    if let Some(addr) = grpc_cfg.client_addr.as_ref() {
        if addr != &bind_addr_str {
            warn!(
                "grpc.client_addr ({}) != server bind address ({}); using HTTP port for binding",
                addr, bind_addr_str
            );
        }
    } else {
        info!(
            "grpc.client_addr missing; defaulting to HTTP port {} for registration",
            bind_addr_str
        );
    }

    let pool = get_db();

    let friend_client_addr = std::env::var("HOT_FRIEND_GRPC_ADDR")
        .ok()
        .or_else(|| grpc_cfg.client_addr.clone());
    let friend_client = if let Some(addr) = friend_client_addr {
        if addr == bind_addr_str {
            warn!(
                "friend_client addr {} matches service bind address; skip hot_friend client init",
                addr
            );
            None
        } else {
            match connect_hot_friend(&addr).await {
                Ok(c) => Some(c),
                Err(e) => {
                    warn!("friend client connect failed: {}", e);
                    None
                }
            }
        }
    } else {
        None
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
    let arb_client_rpc_service_server = ArbClientRpcServiceServer::new(ArbClientImpl::default());

    let mut routes = Routes::new(msg_service_server)
        .add_service(friend_biz_service_server)
        .add_service(key_service_server)
        .add_service(arb_client_rpc_service_server);

    let router_slot = routes.axum_router_mut();
    *router_slot = mem::take(router_slot).fallback_service(rest_router);

    info!("msg_friend listening on {} (HTTP + gRPC)", bind_addr_str);

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
