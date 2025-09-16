//! Arb 客户端 gRPC 服务（供 arb-service 主动推送变更使用）
//!
//! 说明：
//! - 暴露 `ArbClientRpcService::sync_data` 接口，arb-service 在节点注册/变更时推送；
//! - 本实现收到推送后，通过 `NodeUtil` 刷新本地的目标节点地址缓存；
//! - 仅做轻量通知，不做持久化。

use crate::grpc_arb::arb_server::arb_client_rpc_service_server::{ArbClientRpcService, ArbClientRpcServiceServer};
use crate::grpc_arb::arb_server::{BytesBlob, CommonResp, NodeType};
use crate::util::node_util::fetch_node_addr;
use tonic::{Request, Response, Status};
use log::info;

#[derive(Clone, Default)]
pub struct ArbClientImpl;

#[tonic::async_trait]
impl ArbClientRpcService for ArbClientImpl {
    async fn sync_data(&self, request: Request<BytesBlob>) -> Result<Response<CommonResp>, Status> {
        let _blob = request.into_inner();
        // 简化：收到任何同步数据时，都尝试刷新 msg_friend 地址缓存
        if let Some(_new_addr) = fetch_node_addr(NodeType::MsgFriend).await {
            info!("arb-sync: refreshed msg_friend nodes via NodeUtil");
            // fetch_node_addr 已在成功时重置了 NodeUtil 列表
        }
        Ok(Response::new(CommonResp { success: true, message: "ok".to_string() }))
    }
}

/// 启动 arb-client gRPC 服务，在指定地址对外提供 `ArbClientRpcService`
pub async fn start_arb_client_server(bind: &str) -> Result<(), anyhow::Error> {
    let addr: std::net::SocketAddr = bind.parse()?;
    let svc = ArbClientImpl::default();
    tokio::spawn(async move {
        if let Err(e) = tonic::transport::Server::builder()
            .add_service(ArbClientRpcServiceServer::new(svc))
            .serve(addr)
            .await {
                log::warn!("arb client server exited: {}", e);
            }
    });
    Ok(())
}
