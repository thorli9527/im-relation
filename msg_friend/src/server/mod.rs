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

    let advertise_addr = grpc_addr_str.clone();
    let overrides = cfg.msg_friend_cfg();

    let pool = get_db();

    let arb_friend_nodes = match arb_client::ensure_nodes(NodeType::FriendNode).await {
        Ok(nodes) => nodes,
        Err(err) => {
            warn!("fetch hot_friend nodes from arb failed: {}", err);
            Vec::new()
        }
    };

    let friend_client_addr = arb_friend_nodes
        .into_iter()
        .map(|node| node.kafka_addr.unwrap_or(node.node_addr))
        .find(|addr| addr != &advertise_addr);

    let friend_client = match friend_client_addr {
        Some(addr) if addr == advertise_addr => {
            warn!(
                "arb hot_friend addr {} matches service gRPC address; skip hot_friend client init",
                addr
            );
            None
        }
        Some(addr) => match connect_hot_friend(&addr).await {
            Ok(c) => Some(c),
            Err(e) => {
                warn!("friend client connect failed: {}", e);
                None
            }
        },
        None => {
            warn!("no remote hot_friend address discovered via arb; skip client init");
            None
        }
    };

    let socket_nodes = match arb_client::ensure_nodes(NodeType::SocketNode).await {
        Ok(nodes) => nodes,
        Err(err) => {
            warn!("fetch socket nodes from arb failed: {}", err);
            Vec::new()
        }
    };

    let kafka = match socket_nodes
        .into_iter()
        .filter_map(|node| node.kafka_addr)
        .next()
    {
        Some(broker) => {
            // A socket node advertised a Kafka broker; reuse it so msg_friend follows the same
            // routing metadata as clients.
            let topics = vec![MSG_SEND_FRIEND_TOPIC.clone()];
            match KafkaInstanceService::new(&broker, &topics).await {
                Ok(svc) => Some(Arc::new(svc)),
                Err(e) => {
                    warn!("kafka init failed: {}", e);
                    None
                }
            }
        }
        None => {
            // Without any broker information we fall back to a no-op producer and keep serving
            // gRPC; arbitration updates will repopulate this on the next refresh.
            warn!("no socket.kafka_addr discovered via arb; kafka disabled");
            None
        }
    };

    let shard_total: u32 = overrides.shard_total.unwrap_or(16);
    let shard_index: u32 = overrides.shard_index.unwrap_or(0);

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

    arb_client::register_node(
        NodeType::MsgFriend,
        http_addr_str.clone(),
        Some(grpc_addr_str.clone()),
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

/// 简易健康检查。
async fn healthz() -> Json<serde_json::Value> {
    Json(json!({"ok": true}))
}
