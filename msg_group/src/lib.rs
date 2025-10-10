//! msg_group crate：提供群聊业务 gRPC 服务实现及相关辅助模块。
//! - `dao`：封装群聊相关的数据访问逻辑；
//! - `server`：集成 gRPC + HTTP，对接仲裁中心；
//! - `service`：群业务与消息推送的具体实现；
//! - `socket`：复用公共 socket 协议定义。

/// 数据访问层：封装群聊相关的数据库操作。
pub mod dao;
/// 复用公共定义的 socket proto，保持对外兼容。
pub mod socket {
    pub use common::infra::grpc::grpc_socket::socket::*;
}
/// gRPC/HTTP 对外服务入口（健康检查、arb 注册等）。
pub mod server;
/// 群业务实现与消息下发逻辑。
pub mod service;
