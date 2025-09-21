use std::error::Error;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    build_server();
    Ok(())
}

// 去除跨 crate 输出客户端桩，改由消费者自行生成

fn build_server() {
    std::fs::create_dir_all("src/grpc_arb/").ok();
    tonic_build::configure()
        .build_server(true) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        .type_attribute(
            ".",
            "#[derive(serde::Serialize, serde::Deserialize,utoipa::ToSchema)]",
        )
        .type_attribute(".", "#[serde(rename_all = \"camelCase\")]")
        .out_dir("src/grpc_hot_friend/") // 输出 Rust 模块到该目录
        .compile_protos(
            &["proto/friend_service.proto"],
            &["proto"], // proto 根目录
        )
        .expect("Failed to compile protobuf definitions");

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/grpc_arb/")
        .compile_protos(
            &["../arb_service/proto/arb_server.proto"],
            &["../arb_service/proto"],
        )
        .expect("Failed to compile arb_server.proto");

    println!("cargo:rerun-if-changed=../arb_service/proto/arb_server.proto");
    println!("cargo:rerun-if-changed=../arb_service/proto");
}
