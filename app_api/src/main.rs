use common::config::AppConfig;

pub mod grpc;
pub mod handler;
pub mod service;
pub mod util;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1) 加载配置 & 初始化（内含 DB、日志等）
    let app_cfg = AppConfig::init("./config-api.toml").await;
    // gRPC server
    let grpc_manager = manager.clone();
    let grpc_server = tokio::spawn(async move {
        tonic::transport::Server::builder()
            .add_service(AuthServiceServer::new(AuthGrpc { manager: grpc_manager }))
            .serve("[::1]:50051".parse().unwrap())
            .await
            .unwrap();
    });

    // REST server
    let rest_manager = manager.clone();
    let rest_server = tokio::spawn(async move {
        HttpServer::new(move || {
            App::new()
                .app_data(web::Data::new(rest_manager.clone()))
                .service(register)
                .service(login)
        })
            .bind(("127.0.0.1", 8080)).unwrap()
            .run()
            .await.unwrap();
    });

    tokio::try_join!(grpc_server, rest_server)?;
    Ok(())
}
