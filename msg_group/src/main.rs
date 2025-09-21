use common::config::AppConfig;
use msg_group::grpc_arb::arb_server::NodeType;
use msg_group::grpc_arb_client::integration;
use msg_group::server;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let _cfg = AppConfig::init_from_env("./config-msg-group.toml").await;
    integration::start(NodeType::MesGroup).await?;

    server::run_server().await
}
