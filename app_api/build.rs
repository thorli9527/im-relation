fn main() {
    // 生成 hot_online_service 的客户端桩到固定目录
    std::fs::create_dir_all("src/grpc_hot_online/").ok();
    tonic_build::configure()
        .type_attribute(
            "client_service.ClientEntity",
            "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
        )
        .type_attribute(
            "client_service.ClientEntity",
            "#[serde(rename_all = \"camelCase\")]",
        )
        .type_attribute(
            "auth.DeviceType",
            "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
        )
        .build_server(false)
        .build_client(true)
        .out_dir("src/grpc_hot_online/")
        .compile_protos(
            &[
                "../hot_online_service/proto/online.proto",
                "../hot_online_service/proto/auth.proto",
                "../hot_online_service/proto/client_entity.proto",
            ],
            &["../hot_online_service/proto"],
        )
        .expect("Failed to compile online/auth/client_entity protos for app_api");
    println!("cargo:rerun-if-changed=../hot_online_service/proto/online.proto");
    println!("cargo:rerun-if-changed=../hot_online_service/proto/auth.proto");
    println!("cargo:rerun-if-changed=../hot_online_service/proto/client_entity.proto");

    // 生成 arb_service 的客户端桩到固定目录
    std::fs::create_dir_all("src/grpc_arb/").ok();
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/grpc_arb/")
        .compile_protos(
            &["../arb_service/proto/arb_server.proto"],
            &["../arb_service/proto"],
        )
        .expect("Failed to compile arb_server.proto for app_api");
    println!("cargo:rerun-if-changed=../arb_service/proto/arb_server.proto");
}
