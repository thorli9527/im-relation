use std::error::Error;
use std::path::Path;

fn main() -> Result<(), Box<dyn Error>> {
    println!("cargo:rerun-if-changed=build.rs");

    generate_message()?;
    generate_socket()?;
    generate_grpc_with_serde(
        "src/grpc/grpc_hot_friend",
        &["proto/hot_friend.proto"],
        false,
    )?;
    generate_grpc_with_serde("src/grpc/grpc_hot_group", &["proto/hot_group.proto"], false)?;
    generate_hot_online()?;
    generate_grpc_with_serde(
        "src/grpc/grpc_msg_friend",
        &["proto/msg_friend.proto"],
        true,
    )?;
    generate_grpc_with_serde("src/grpc/grpc_msg_group", &["proto/msg_group.proto"], true)?;

    Ok(())
}

fn generate_message() -> Result<(), Box<dyn Error>> {
    let out_dir = Path::new("src/grpc");
    std::fs::create_dir_all(out_dir)?;

    let mut config = prost_build::Config::new();
    config.out_dir(out_dir);
    config.type_attribute(
        ".",
        "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
    );
    config.type_attribute(".", "#[serde(rename_all = \"camelCase\")]");
    config.compile_protos(&["proto/message.proto"], &["proto"])?;

    println!("cargo:rerun-if-changed=proto/message.proto");
    Ok(())
}

fn generate_socket() -> Result<(), Box<dyn Error>> {
    let out_dir = Path::new("src/grpc/grpc_socket");
    std::fs::create_dir_all(out_dir)?;

    let mut config = prost_build::Config::new();
    config.out_dir(out_dir);
    config.compile_protos(&["proto/socket.proto"], &["proto"])?;

    println!("cargo:rerun-if-changed=proto/socket.proto");
    Ok(())
}

fn generate_grpc_with_serde(
    out_dir: &str,
    protos: &[&str],
    extern_message: bool,
) -> Result<(), Box<dyn Error>> {
    std::fs::create_dir_all(out_dir)?;

    let mut builder = tonic_build::configure();
    builder = builder.build_server(true);
    builder = builder.build_client(true);
    builder = builder.type_attribute(
        ".",
        "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
    );
    builder = builder.type_attribute(".", "#[serde(rename_all = \"camelCase\")]");
    builder = builder.out_dir(out_dir);
    if extern_message {
        builder = builder.extern_path(".message", "crate::grpc::message");
    }

    builder.compile_protos(protos, &["proto"])?;

    for proto in protos {
        println!("cargo:rerun-if-changed={proto}");
    }

    Ok(())
}

fn generate_hot_online() -> Result<(), Box<dyn Error>> {
    let out_dir = "src/grpc/grpc_hot_online";
    std::fs::create_dir_all(out_dir)?;

    let mut builder = tonic_build::configure();
    builder = builder.build_server(true);
    builder = builder.build_client(true);
    builder = builder.type_attribute(
        "online_service.ClientEntity",
        "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
    );
    builder = builder.type_attribute(
        "online_service.ClientEntity",
        "#[serde(rename_all = \"camelCase\")]",
    );
    builder = builder.type_attribute(
        "online_service.DeviceType",
        "#[derive(serde::Serialize, serde::Deserialize, utoipa::ToSchema)]",
    );
    builder = builder.out_dir(out_dir);

    builder.compile_protos(&["proto/hot_online.proto"], &["proto"])?;
    println!("cargo:rerun-if-changed=proto/hot_online.proto");

    Ok(())
}
