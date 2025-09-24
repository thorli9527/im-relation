//! msg_friend server module: split gRPC and HTTP endpoints with dedicated listeners.

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::arb::NodeType;
use common::config::{get_db, AppConfig};
use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_FRIEND_TOPIC;
use common::service::arb_client;
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

mod server_grpc;
mod server_web;

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

    let advertise_addr = std::env::var("MSG_FRIEND_GRPC_ADDR")
        .ok()
        .filter(|addr| !addr.is_empty())
        .unwrap_or_else(|| grpc_addr_str.clone());

    let pool = get_db();

    let friend_client_addr = std::env::var("HOT_FRIEND_GRPC_ADDR")
        .ok()
        .filter(|addr| !addr.is_empty())
        .unwrap_or_else(|| advertise_addr.clone());
    let friend_client = if friend_client_addr == advertise_addr {
        warn!(
            "friend_client addr {} matches service gRPC address; skip hot_friend client init",
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

    let http_router = Router::new()
        .route("/healthz", get(healthz))
        .merge(arb_client::http_router());

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

    arb_client::register_node(NodeType::MsgFriend, advertise_addr.clone(), None).await?;

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
