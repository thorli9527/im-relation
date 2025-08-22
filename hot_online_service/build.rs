fn main() -> Result<(), Box<dyn std::error::Error>> {
    build_server();
    build_client();
    Ok(())
}

fn build_server() {
    tonic_build::configure()
        .build_server(true) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        .out_dir("src/grpc/") // 输出 Rust 模块到该目录
        .compile_protos(
            &[
                "proto/online.proto",
                "proto/client_entity.proto",
            ],
            &["proto"], // proto 根目录
        )
        .expect("💥 Proto 编译失败，请检查路径和语法！");
}

fn build_client() {
    tonic_build::configure()
        .build_server(true) // 如无需生成 gRPC Server 代码
        .build_client(true) // 如无需生成 gRPC Client 代码
        .out_dir("../app_socket/src/grpc/") // 输出 Rust 模块到该目录
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
        .out_dir("../app_api/src/grpc/") // 输出 Rust 模块到该目录
        .compile_protos(
            &[
                "proto/auth.proto",
                "proto/online.proto",
                "proto/client_entity.proto",
            ],
            &["proto"], // proto 根目录
        )
        .expect("💥 Proto 编译失败，请检查路径和语法！");
}
