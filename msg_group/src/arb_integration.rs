use crate::grpc_arb::arb_server::{
    arb_server_rpc_service_client::ArbServerRpcServiceClient, BaseRequest, NodeType,
    RegisterRequest,
};
use common::config::AppConfig;
use common::grpc::GrpcClientManager;
use log::warn;
use once_cell::sync::OnceCell as SyncOnceCell;
use tokio::sync::OnceCell;
use tokio::time::{sleep, Duration};
use tonic::transport::{Channel, Error as TransportError};

static MANAGER: OnceCell<GrpcClientManager<ArbServerRpcServiceClient<Channel>, TransportError>> =
    OnceCell::const_new();
static ARB_ADDR: SyncOnceCell<String> = SyncOnceCell::new();

pub async fn start(node_type: NodeType) -> anyhow::Result<()> {
    let cfg = AppConfig::init_from_env("./config-group.toml").await;
    let grpc_cfg = cfg
        .grpc
        .clone()
        .ok_or_else(|| anyhow::anyhow!("grpc config missing"))?;
    let server_addr = grpc_cfg
        .server_addr
        .ok_or_else(|| anyhow::anyhow!("arb server addr missing"))?;
    let client_addr = grpc_cfg
        .client_addr
        .ok_or_else(|| anyhow::anyhow!("client addr missing"))?;

    MANAGER
        .get_or_try_init(|| async {
            Ok::<GrpcClientManager<_, _>, anyhow::Error>(GrpcClientManager::new(
                |endpoint: String| async move {
                    ArbServerRpcServiceClient::connect(endpoint).await
                },
            ))
        })
        .await?;
    ARB_ADDR.get_or_init(|| server_addr.clone());

    let endpoint = format!("http://{}", server_addr);
    let mut client = MANAGER
        .get()
        .unwrap()
        .get(&endpoint)
        .await
        .map_err(|e| anyhow::anyhow!(e))?
        .as_ref()
        .clone();

    client
        .register_node(RegisterRequest {
            node_addr: client_addr.clone(),
            node_type: node_type as i32,
            kafka_addr: None,
        })
        .await?;

    spawn_heartbeat(node_type, client_addr);
    Ok(())
}

fn spawn_heartbeat(node_type: NodeType, node_addr: String) {
    tokio::spawn(async move {
        let manager = MANAGER.get().unwrap().clone();
        let endpoint = format!("http://{}", ARB_ADDR.get().unwrap());
        let mut ticker = tokio::time::interval(Duration::from_secs(10));
        loop {
            ticker.tick().await;
            match manager.get(&endpoint).await {
                Ok(mut client) => {
                    if let Err(e) = client
                        .heartbeat(BaseRequest {
                            node_addr: node_addr.clone(),
                            node_type: node_type as i32,
                        })
                        .await
                    {
                        warn!("arb heartbeat failed: {}", e);
                    }
                }
                Err(e) => {
                    warn!("arb heartbeat connect failed: {}", e);
                    sleep(Duration::from_secs(3)).await;
                }
            }
        }
    });
}
