//! 服务入口聚合：统一暴露 TCP/Web/arb 客户端等启动函数。
//!
//! - `server_tcp`：核心 TCP 接入层（长度前缀 + Protobuf）；
//! - `server_web`：预留 Web/HTTP 服务入口，并负责与仲裁服务对接。
pub mod server_tcp;
pub mod server_web;

// Re-export only the functions that are used by consumers to avoid unused import warnings
pub use server_tcp::start_tcp_server;
