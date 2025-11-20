use std::path::PathBuf;
use std::{env, fs};

use prost_build::Config;

fn main() {
    println!("cargo:rerun-if-changed=src/generated");
    println!("cargo:rerun-if-changed=../common/proto/message.proto");
    println!("cargo:rerun-if-changed=../common/proto/socket.proto");

    if let Err(err) = run_build_proto() {
        panic!("failed to run proto builder: {}", err);
    }
}

fn run_build_proto() -> Result<(), String> {
    let manifest_dir = env::var("CARGO_MANIFEST_DIR").map_err(|e| e.to_string())?;
    let proto_source = env::var("PROTO_SOURCE_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|_| {
            PathBuf::from(&manifest_dir)
                .join("..")
                .join("common")
                .join("proto")
        });
    let out_dir = PathBuf::from(&manifest_dir).join("src").join("generated");
    fs::create_dir_all(&out_dir).map_err(|e| e.to_string())?;

    let protos = [
        proto_source.join("message.proto"),
        proto_source.join("socket.proto"),
    ];
    Config::new()
        .out_dir(&out_dir)
        .compile_protos(
            &protos.iter().map(|p| p.as_path()).collect::<Vec<_>>(),
            &[proto_source.as_path()],
        )
        .map_err(|e| e.to_string())
}
