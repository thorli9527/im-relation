fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Generate hot_friend_service client stubs for friend relationship checks
    let out_hf = "src/grpc_hot_friend/";
    std::fs::create_dir_all(out_hf).ok();

    tonic_build::configure()
        .build_server(false)
        .build_client(true)
        .type_attribute(
            ".",
            "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
        )
        .type_attribute(".", "#[serde(rename_all = \"camelCase\")]")
        .out_dir(out_hf)
        .compile_protos(
            &["../hot_friend_service/proto/friend_service.proto"],
            &["../hot_friend_service/proto"],
        )?;
    println!("cargo:rerun-if-changed=../hot_friend_service/proto/friend_service.proto");

    // Generate FriendBizService (this crate's external API) server/client stubs
    let out_fb = "src/grpc_msg_friend/";
    std::fs::create_dir_all(out_fb).ok();
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .type_attribute(
            ".",
            "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
        )
        .type_attribute(".", "#[serde(rename_all = \"camelCase\")]")
        .out_dir(out_fb)
        .compile_protos(&["proto/friend.proto"], &["proto"])?;
    println!("cargo:rerun-if-changed=proto/friend.proto");

    std::fs::create_dir_all("src/grpc_arb/").ok();
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/grpc_arb/")
        .compile_protos(
            &["../arb-service/proto/arb_server.proto"],
            &["../arb-service/proto"],
        )?;
    println!("cargo:rerun-if-changed=../arb-service/proto/arb_server.proto");

    Ok(())
}
