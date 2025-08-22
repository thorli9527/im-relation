use std::error::Error;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    build_server();
    build_client();
    Ok(())
}

fn build_client()  {
    tonic_build::configure()
        .build_server(false) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        .type_attribute(".", "#[derive(serde::Serialize, serde::Deserialize,utoipa::ToSchema)]")
        .type_attribute(".", "#[serde(rename_all = \"camelCase\")]")
        .out_dir("../app_socket/src/grpc/") // 输出 Rust 模块到该目录
        .compile_protos(
            &[
                "proto/friend_service.proto",
            ],
            &["proto"], // proto 根目录
        ).expect("Failed to compile protobuf definitions");
}

fn build_server()  {
    tonic_build::configure()
        .build_server(true) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        .type_attribute(".", "#[derive(serde::Serialize, serde::Deserialize,utoipa::ToSchema)]")
        .type_attribute(".", "#[serde(rename_all = \"camelCase\")]")
        .out_dir("src/grpc/") // 输出 Rust 模块到该目录
        .compile_protos(
            &[
                "proto/friend_service.proto",
            ],
            &["proto"], // proto 根目录
        ).expect("Failed to compile protobuf definitions");


}
