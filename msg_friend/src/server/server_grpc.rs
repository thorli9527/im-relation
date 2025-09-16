use std::hash::Hasher as _;
use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::Context;
use prost::Message as _;
use sqlx::{MySql, Pool};
use tonic::{Request, Response, Status};

use crate::grpc_msg_friend::msg_friend_service as msgpb;
use common::config::{get_db, AppConfig};
use common::kafka::kafka_producer::KafkaInstanceService;
use common::kafka::topic_info::MSG_SEND_FRIEND_TOPIC;

use crate::dao::{
    copy_message_as_forward, fetch_device_bundles, insert_encrypted_message, mark_delivered,
    mark_read, recall_message, DeviceKeysRow, EncryptedMessageRecord,
};
use crate::grpc_hot_friend::friend_service::friend_service_client::FriendServiceClient as HfFriendClient;
use crate::grpc_hot_friend::friend_service::IsFriendReq;
use crate::grpc_msg_friend::msg_friend_service::friend_biz_service_server::FriendBizServiceServer;
use crate::service::friend_biz_service_impl::MsgFriendServiceImpl;

use msgpb::friend_msg_service_server::{FriendMsgService, FriendMsgServiceServer};
use msgpb::key_service_server::{KeyService, KeyServiceServer};

#[derive(Clone)]
pub struct Services {
    pool: Arc<Pool<MySql>>,
    friend_client: Option<HfFriendClient<tonic::transport::Channel>>,
    kafka: Option<Arc<KafkaInstanceService>>,
    shard_index: u32,
    shard_total: u32,
}

impl Services {
    pub fn friend_client(&self) -> Option<&HfFriendClient<tonic::transport::Channel>> {
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

// NOTE: Services trait implementations moved to service/ modules

/// Start gRPC server on a bind address (e.g., "0.0.0.0:8090").
pub async fn start_grpc_server(bind: &str) -> anyhow::Result<()> {
    let addr: SocketAddr = bind.parse().context("invalid msg_friend grpc address")?;

    let pool = get_db();
    let friend_client = if let Some(addr) = AppConfig::get()
        .grpc
        .as_ref()
        .and_then(|g| g.client_addr.clone())
    {
        match HfFriendClient::connect(format!("http://{}", addr)).await {
            Ok(c) => Some(c),
            Err(e) => {
                log::warn!("friend client connect failed: {}", e);
                None
            }
        }
    } else {
        None
    };

    let kafka = if let Some(broker) = AppConfig::get().get_socket().kafka_broker {
        let topics = vec![common::kafka::topic_info::MSG_SEND_FRIEND_TOPIC.clone()];
        match KafkaInstanceService::new(&broker, &topics).await {
            Ok(svc) => Some(Arc::new(svc)),
            Err(e) => {
                log::warn!("kafka init failed: {}", e);
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

    let svc = Services {
        pool,
        friend_client,
        kafka,
        shard_index,
        shard_total,
    };

    tonic::transport::Server::builder()
        .add_service(FriendMsgServiceServer::new(svc.clone()))
        .add_service(FriendBizServiceServer::new(MsgFriendServiceImpl::new(
            svc.clone().into(),
        )))
        .add_service(KeyServiceServer::new(svc))
        .serve(addr)
        .await
        .map_err(anyhow::Error::from)
}

/// Read config and start gRPC server (keeps compatibility with previous `run_server`).
pub async fn run_server() -> anyhow::Result<()> {
    let app_cfg = AppConfig::get();
    let grpc_addr_str = app_cfg
        .grpc
        .as_ref()
        .and_then(|g| g.server_addr.clone())
        .unwrap_or_else(|| "0.0.0.0:8090".to_string());
    start_grpc_server(&grpc_addr_str).await
}
