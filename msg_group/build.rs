fn main() -> Result<(), Box<dyn std::error::Error>> {
    let out_dir = "src/grpc_msg_group/";
    std::fs::create_dir_all(out_dir).ok();

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .type_attribute(
            ".",
            "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
        )
        .type_attribute(".", "#[serde(rename_all = \"camelCase\")]")
        .out_dir(out_dir)
        .compile_protos(&["proto/group.proto"], &["proto"])?;

    println!("cargo:rerun-if-changed=proto/group.proto");

    std::fs::create_dir_all("src/grpc_arb/").ok();
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/grpc_arb/")
        .compile_protos(
            &["../arb_service/proto/arb_server.proto"],
            &["../arb_service/proto"],
        )?;
    println!("cargo:rerun-if-changed=../arb_service/proto/arb_server.proto");
    Ok(())
}
