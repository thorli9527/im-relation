use crate::grpc_arb::arb_server::{
    arb_server_rpc_service_client::ArbServerRpcServiceClient, BaseRequest, NodeType,
    RegisterRequest,
};
use crate::service::grpc_clients;
use common::config::AppConfig;
use log::warn;
use tokio::time::{sleep, Duration};

pub async fn start(node_type: NodeType) -> anyhow::Result<()> {
    let cfg = AppConfig::get();
    let grpc_cfg = cfg
        .grpc
        .as_ref()
        .ok_or_else(|| anyhow::anyhow!("grpc config missing"))?;
    let server_addr = grpc_cfg
        .server_addr
        .as_ref()
        .ok_or_else(|| anyhow::anyhow!("arb server address missing"))?;
    let client_addr = grpc_cfg
        .client_addr
        .as_ref()
        .ok_or_else(|| anyhow::anyhow!("client address missing"))?;

    let mut client = grpc_clients::arb_server_client(server_addr).await?;
    register(&mut client, client_addr, node_type).await?;

    spawn_heartbeat(server_addr.clone(), client_addr.clone(), node_type);
    Ok(())
}

async fn register(
    client: &mut ArbServerRpcServiceClient<tonic::transport::Channel>,
    node_addr: &str,
    node_type: NodeType,
) -> Result<(), tonic::Status> {
    client
        .register_node(RegisterRequest {
            node_addr: node_addr.to_string(),
            node_type: node_type as i32,
            kafka_addr: None,
        })
        .await?;
    Ok(())
}

fn spawn_heartbeat(server_addr: String, node_addr: String, node_type: NodeType) {
    tokio::spawn(async move {
        let mut interval = tokio::time::interval(Duration::from_secs(10));
        loop {
            interval.tick().await;
            match grpc_clients::arb_server_client(&server_addr).await {
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
                    warn!("arb client connect failed: {}", e);
                    sleep(Duration::from_secs(3)).await;
                }
            }
        }
    });
}
