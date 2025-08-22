use tonic::Request;
use crate::grpc::arb_server::{NodeType, QueryNodeReq, RegisterRequest};
use crate::service::arb_server_service::ArbServerService;
use crate::service::client_rpc_service_impl::ClientRpcServiceImpl;
use crate::service::online_rpc_service_impl::OnlineRpcServiceImpl;
use crate::util::node_util::NodeUtil;

pub mod arb_server_service;
pub mod arb_client_service_impl;
pub mod user_service;
pub mod user_service_impl;
pub mod client_rpc_service_impl;
mod online_rpc_service_impl;

pub async fn init(){
    ArbServerService::init().await.expect("ArbServerService init");
    let arb_server_service=ArbServerService::get();
    let mut client = arb_server_service.client.lock().await;
    client.register_node(RegisterRequest{
        node_addr: "".to_string(),
        node_type: NodeType::ApiNode as i32,
        kafka_addr: None,
    }).await.unwrap();

    let arb_server_service=ArbServerService::get();
    let mut client = arb_server_service.client.lock().await;

    let list_rep=client.list_all_nodes(QueryNodeReq{node_type:NodeType::SocketNode as i32}).await.unwrap();

    let list=list_rep.into_inner();
    for node in list.nodes {
        NodeUtil::get().insert_node(NodeType::SocketNode, node);
    }

    let list_rep=client.list_all_nodes(QueryNodeReq{node_type:NodeType::OnlineNode as i32}).await.unwrap();
    let list=list_rep.into_inner();
    for node in list.nodes {
        ClientRpcServiceImpl::new(&node.node_addr).await.unwrap();
        OnlineRpcServiceImpl::init(&node.node_addr).await.unwrap();
        break
    }

}