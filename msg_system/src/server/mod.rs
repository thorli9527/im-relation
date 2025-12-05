use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{anyhow, Context, Result};
use axum::{routing::get, Json, Router};
use common::config::{get_db, AppConfig};
use common::infra::kafka::kafka_producer::KafkaInstanceService;
use common::infra::kafka::topic_info::SYS_MSG_TOPIC_INFO;
use log::info;
use sqlx::{MySql, Pool};
use tokio::net::TcpListener;
use tokio::signal;
use tokio_util::sync::CancellationToken;

use common::infra::grpc::grpc_msg_system::msg_system_service::system_msg_service_server::SystemMsgServiceServer;

use crate::service::SystemMsgServiceImpl;

#[derive(Clone)]
pub struct Services {
    pool: Arc<Pool<MySql>>,
    kafka: Option<Arc<KafkaInstanceService>>,
}

impl Services {
    pub fn pool(&self) -> &Pool<MySql> {
        &self.pool
    }

    pub fn kafka(&self) -> Option<&KafkaInstanceService> {
        self.kafka.as_deref()
    }
}

/// 启动系统消息 gRPC/HTTP 服务。
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
        .with_context(|| format!("invalid server bind address: {}", http_addr_str))?;

    let pool = get_db();
    let kafka_cfg = cfg.kafka_cfg();
    let kafka = match (kafka_cfg.broker.as_ref(), kafka_cfg.replicas) {
        (Some(broker), Some(replicas)) => {
            let topics = vec![SYS_MSG_TOPIC_INFO.with_replicas(replicas)];
            match KafkaInstanceService::new(broker, &topics).await {
                Ok(instance) => Some(Arc::new(instance)),
                Err(err) => {
                    log::warn!("init kafka producer failed: {err}");
                    None
                }
            }
        }
        _ => None,
    };

    let services = Services { pool, kafka };

    let http_router = Router::new().route(
        "/healthz",
        get(|| async { Json(serde_json::json!({ "status": "ok" })) }),
    );

    let grpc_service = SystemMsgServiceServer::new(SystemMsgServiceImpl::new(services.clone()));

    info!(
        "msg_system listening on grpc={} http={}",
        grpc_addr_str, http_addr_str
    );

    let cancel_token = CancellationToken::new();
    let http_cancel = cancel_token.clone();
    let grpc_cancel = cancel_token.clone();

    let http_handle = tokio::spawn(async move {
        if let Ok(listener) = TcpListener::bind(http_addr).await {
            if let Err(err) = axum::serve(listener, http_router.into_make_service())
                .with_graceful_shutdown(async move {
                    http_cancel.cancelled().await;
                })
                .await
            {
                log::error!("http server error: {}", err);
            }
        } else {
            log::error!("bind http listener failed");
        }
    });

    let grpc_handle = tokio::spawn(async move {
        if let Err(err) = tonic::transport::Server::builder()
            .add_service(grpc_service)
            .serve_with_shutdown(grpc_addr, async move {
                grpc_cancel.cancelled().await;
            })
            .await
        {
            log::error!("grpc server error: {}", err);
        }
    });

    let _ = signal::ctrl_c().await;
    cancel_token.cancel();
    let _ = tokio::join!(http_handle, grpc_handle);
    Ok(())
}
