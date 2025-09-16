fn main() -> Result<(), Box<dyn std::error::Error>> {
    let out_dir = "src/grpc/";
    std::fs::create_dir_all(out_dir).ok();

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .type_attribute(".", "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]")
        .type_attribute(".", "#[serde(rename_all = \"camelCase\")]")
        .out_dir(out_dir)
        .compile_protos(&["proto/group.proto", "proto/group_message.proto"], &["proto"]) ?;

    println!("cargo:rerun-if-changed=proto/group.proto");
    println!("cargo:rerun-if-changed=proto/group_message.proto");
    Ok(())
}
