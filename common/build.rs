use std::error::Error;
use std::path::Path;

fn main() -> Result<(), Box<dyn Error>> {
    println!("cargo:rerun-if-changed=build.rs");

    generate_message()?;
    generate_socket()?;
    generate_grpc_with_serde("src/infra/grpc/grpc_friend", &["proto/friend.proto"], false)?;
    generate_grpc_with_serde("src/infra/grpc/grpc_group", &["proto/group.proto"], false)?;
    generate_grpc_user()?;
    generate_grpc_with_serde(
        "src/infra/grpc/grpc_msg_friend",
        &["proto/msg_friend.proto"],
        true,
    )?;
    generate_grpc_with_serde(
        "src/infra/grpc/grpc_msg_group",
        &["proto/msg_group.proto"],
        true,
    )?;

    Ok(())
}

fn generate_message() -> Result<(), Box<dyn Error>> {
    let out_dir = Path::new("src/infra/grpc");
    std::fs::create_dir_all(out_dir)?;

    let mut config = prost_build::Config::new();
    config.out_dir(out_dir);
    config.compile_protos(&["proto/message.proto"], &["proto"])?;

    println!("cargo:rerun-if-changed=proto/message.proto");
    Ok(())
}

fn generate_socket() -> Result<(), Box<dyn Error>> {
    let out_dir = Path::new("src/infra/grpc/grpc_socket");
    std::fs::create_dir_all(out_dir)?;

    let mut config = prost_build::Config::new();
    config.out_dir(out_dir);
    config.extern_path(".message", "crate::infra::grpc::message");
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
    builder = builder.out_dir(out_dir);
    if extern_message {
        builder = builder.extern_path(".message", "crate::infra::grpc::message");
    }

    builder.compile_protos(protos, &["proto"])?;

    for proto in protos {
        println!("cargo:rerun-if-changed={proto}");
    }

    Ok(())
}

fn generate_grpc_user() -> Result<(), Box<dyn Error>> {
    let out_dir = "src/infra/grpc/grpc_user";
    std::fs::create_dir_all(out_dir)?;

    let mut builder = tonic_build::configure();
    builder = builder.build_server(true);
    builder = builder.build_client(true);
    builder = builder.type_attribute(
        "online_service.UserEntity",
        "#[derive(serde::Serialize, serde::Deserialize)]",
    );
    builder = builder.type_attribute(
        "online_service.UserEntity",
        "#[serde(rename_all = \"camelCase\")]",
    );
    builder = builder.type_attribute(
        "online_service.DeviceType",
        "#[derive(serde::Serialize, serde::Deserialize)]",
    );
    builder = builder.out_dir(out_dir);

    builder.compile_protos(&["proto/user.proto"], &["proto"])?;
    println!("cargo:rerun-if-changed=proto/user.proto");

    Ok(())
}
