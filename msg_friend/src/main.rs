use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_arb_client::integration;
use crate::grpc_arb_client::server::start_arb_client_server;
use anyhow::anyhow;
use common::config::AppConfig;

mod dao;
mod grpc_arb;
mod grpc_arb_client;
mod grpc_hot_friend;
mod grpc_msg_friend;
mod server;
mod service;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let _cfg = AppConfig::init_from_env("./config-friend.toml").await;
    let cfg = AppConfig::get();

    let grpc_cfg = cfg
        .grpc
        .as_ref()
        .ok_or_else(|| anyhow!("grpc config missing"))?;
    let client_addr = grpc_cfg
        .client_addr
        .as_ref()
        .ok_or_else(|| anyhow!("grpc.client_addr missing"))?;

    start_arb_client_server(client_addr).await?;
    integration::start(NodeType::MsgFriend).await?;

    server::run_server().await
}
