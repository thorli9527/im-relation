mod server;
mod dao;
mod grpc_hot_friend;
mod grpc_msg_friend;
mod service;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    server::run_server().await
}
