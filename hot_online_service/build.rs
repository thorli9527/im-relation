fn main() -> Result<(), Box<dyn std::error::Error>> {
    build_server();
    build_client();
    Ok(())
}

fn build_server() {
    std::fs::create_dir_all("src/grpc_arb/").ok();
    tonic_build::configure()
        .build_server(true) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        .out_dir("src/grpc_hot_online/") // 输出 Rust 模块到该目录
        .compile_protos(
            &["proto/online.proto", "proto/client_entity.proto"],
            &["proto"], // proto 根目录
        )
        .expect("💥 Proto 编译失败，请检查路径和语法！");

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/grpc_arb/")
        .compile_protos(
            &["../arb-service/proto/arb_server.proto"],
            &["../arb-service/proto"],
        )
        .expect("💥 Arb proto 编译失败！");
}

fn build_client() {
    tonic_build::configure()
        .build_server(true) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        // 移除跨 crate 输出，改由消费者自行生成
        .out_dir("src/grpc_hot_online/")
        .compile_protos(
            &[
                "proto/online.proto",
                "proto/auth.proto",
                "proto/client_entity.proto",
            ],
            &["proto"], // proto 根目录
        )
        .expect("💥 Proto 编译失败，请检查路径和语法！");

    tonic_build::configure()
        .build_server(true) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        // 移除跨 crate 输出，改由消费者自行生成
        .out_dir("src/grpc_hot_online/")
        .compile_protos(
            &[
                "proto/auth.proto",
                "proto/online.proto",
                "proto/client_entity.proto",
            ],
            &["proto"], // proto 根目录
        )
        .expect("💥 Proto 编译失败，请检查路径和语法！");

    println!("cargo:rerun-if-changed=../arb-service/proto/arb_server.proto");
    println!("cargo:rerun-if-changed=../arb-service/proto");
}
