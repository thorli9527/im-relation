//! Placeholder server module for msg_group.
//!
//! This crate currently only exposes protobuf-generated structures. When the
//! msg_group service is ready to host a real gRPC/HTTP endpoint, extend the
//! functions below with the actual startup logic.

/// Start the gRPC server (placeholder).
pub async fn start_grpc_server(addr: &str) -> Result<(), Box<dyn std::error::Error>> {
    println!("msg_group gRPC server bootstrap requested at {}", addr);
    Ok(())
}

/// Start the HTTP server (placeholder).
pub async fn start_http_server(addr: &str) -> Result<(), Box<dyn std::error::Error>> {
    println!("msg_group HTTP server bootstrap requested at {}", addr);
    Ok(())
}
