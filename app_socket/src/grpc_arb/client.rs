//! gRPC 客户端封装：仲裁服务 (`arb_service`)
//!
//! socket 进程既需要主动向仲裁服务上报自身状态，也需要接收来自仲裁层的
//! 节点变更广播。为了避免在各业务模块中重复书写 tonic 的连接逻辑，这里
//! 将常用客户端别名与 `connect_*` 帮助函数集中到一个模块。

use crate::grpc_arb::arb_server::arb_client_rpc_service_client::ArbClientRpcServiceClient;
use crate::grpc_arb::arb_server::arb_server_rpc_service_client::ArbServerRpcServiceClient;
use crate::service::grpc_clients;
use tonic::transport::Channel;

/// 仲裁服务（服务端 RPC）客户端别名。
pub type ServerClient = ArbServerRpcServiceClient<Channel>;
/// 仲裁客户端 RPC（用于节点监听）客户端别名。
pub type ClientClient = ArbClientRpcServiceClient<Channel>;

/// 连接仲裁服务端 RPC，用于节点注册、同步等场景。
///
/// - `addr` 仅包含 `host:port`，函数内部拼接 `http://` 前缀；
/// - 返回的 tonic 客户端可直接调用服务端定义的 RPC；
/// - 任何网络解析或 TLS 错误都会按 `transport::Error` 暴露给调用方。
pub async fn connect_server(addr: &str) -> Result<ServerClient, tonic::transport::Error> {
    grpc_clients::arb_server_client(addr).await
}

/// 连接仲裁客户端 RPC，用于订阅节点状态更新。
///
/// 其余注意事项与 [`connect_server`] 相同。
pub async fn connect_client(addr: &str) -> Result<ClientClient, tonic::transport::Error> {
    grpc_clients::arb_client_client(addr).await
}
