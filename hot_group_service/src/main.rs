use common::config::AppConfig;

mod grpc_arb;
mod grpc_arb_client;
mod grpc_msg_group;
mod hot_capacity;
mod hot_cold;
mod member;
mod profile;
mod server;
mod store;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    AppConfig::init_from_env("./config-group.toml").await;
    server::start().await
}
