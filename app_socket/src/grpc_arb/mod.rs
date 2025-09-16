//! 与仲裁服务 (`arb-service`) 交互的 gRPC 模块。
//!
//! - `arb_server`：prost/tonic 自动生成的 protobuf 定义与客户端实现；
//! - `client`：针对 socket 服务的轻量封装，提供易用的连接帮助函数。
pub mod arb_server;
pub mod client;
