//! 服务器入口模块（目前仅包含 gRPC + HTTP 复合服务）。

pub mod server_grpc;

/// 对外导出的服务启动函数。
pub use server_grpc::run_server;
