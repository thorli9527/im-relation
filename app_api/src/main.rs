use actix_web::{App, HttpServer};
use actix_web::middleware::Logger;
use log::warn;
use tonic::transport::Server;
use common::config::AppConfig;
use crate::grpc::arb_server::arb_client_rpc_service_server::ArbClientRpcServiceServer;
use crate::service::arb_client_service_impl::ArbClientServiceImpl;

pub mod grpc;
pub mod handler;
pub mod service;
pub mod util;

#[actix_web::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1) 加载配置 & 初始化（内含 DB、日志等）
    let app_cfg = AppConfig::init("./config-api.toml").await;
    // 初始化服务
    service::init().await;
    // 读取配置文件
    let app_cfg = AppConfig::get();
    //初始化日志
    let address_and_port = format!("{}:{}", &app_cfg.get_server().host, &app_cfg.get_server().port);
    warn!("Starting server on {}", address_and_port);
    // 初始化 业务

    // 启用 ArbClientService gRPC 服务器
    let grpc_addr = format!("{}", &app_cfg.grpc.clone().unwrap().client_addr.unwrap()).parse()?;
    warn!("Starting gRPC server on {}", grpc_addr);

    let arb_client_service = ArbClientServiceImpl{};

    tokio::spawn(async move {
        println!("Starting ArbClientRpcService gRPC server on {:?}", grpc_addr);

        if let Err(e) = Server::builder()
            .add_service(ArbClientRpcServiceServer::new(arb_client_service))
            .serve(grpc_addr)
            .await
        {
            eprintln!("gRPC server error: {}", e);
        }
    });

    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            // 配置 控制器
            .configure(|cfg| {
                handler::configure(cfg);
            })
    })
        .keep_alive(actix_web::http::KeepAlive::Timeout(std::time::Duration::from_secs(60))) // 允许 1 分钟超时
        .bind(address_and_port)?
        .run()
        .await;
    Ok(())
}
