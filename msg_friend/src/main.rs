use crate::grpc_arb::arb_server::NodeType;
use crate::grpc_arb_client::integration;
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
    let _cfg = AppConfig::init_from_env("./config-msg-friend.toml").await;
    integration::start(NodeType::MsgFriend).await?;

    server::run_server().await
}
