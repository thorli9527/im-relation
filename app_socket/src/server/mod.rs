//! Unified server module: TCP + optional Web/Arb gRPC starters

pub mod server_web;
pub mod server_tcp;

// Re-export only the functions that are used by consumers to avoid unused import warnings
pub use server_tcp::start_tcp_server;
