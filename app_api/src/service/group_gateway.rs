use anyhow::{anyhow, Result};
use common::config::AppConfig;
use common::infra::grpc::grpc_group::group_service::{
    group_service_client::GroupServiceClient, GetAllReq, GetPageReq, MemberRef,
};
use common::infra::grpc::GrpcClientManager;
use common::support::node::{NodeType, NodeUtil};
use common::support::util::common_utils::hash_index;
use once_cell::sync::OnceCell;
use tonic::transport::{Channel, Error as TransportError};

pub struct GroupMembersPage {
    pub members: Vec<MemberRef>,
    pub has_more: bool,
}

static GROUP_CLIENT_MANAGER: OnceCell<
    GrpcClientManager<GroupServiceClient<Channel>, TransportError>,
> = OnceCell::new();

fn manager() -> &'static GrpcClientManager<GroupServiceClient<Channel>, TransportError> {
    GROUP_CLIENT_MANAGER.get_or_init(|| {
        GrpcClientManager::new(|endpoint: String| async move {
            GroupServiceClient::connect(endpoint).await
        })
    })
}

fn normalize_endpoint(addr: &str) -> String {
    if addr.starts_with("http://") || addr.starts_with("https://") {
        addr.to_string()
    } else {
        format!("http://{}", addr)
    }
}

async fn resolve_group_addr(group_id: i64) -> Result<String> {
    let node_util = NodeUtil::get();
    let mut nodes = node_util.get_list(NodeType::GroupNode as i32);

    if nodes.is_empty() {
        let configured = AppConfig::get().urls_for_node_type(NodeType::GroupNode);
        if configured.is_empty() {
            return Err(anyhow!("group node list empty"));
        }
        node_util.reset_list(NodeType::GroupNode as i32, configured.clone());
        nodes = configured;
    }

    let total = i32::try_from(nodes.len()).unwrap_or(0);
    if total <= 0 {
        return Err(anyhow!("group node list empty"));
    }
    let idx = hash_index(&group_id, total) as usize;
    nodes
        .into_iter()
        .nth(idx)
        .ok_or_else(|| anyhow!("group node index out of range"))
}

async fn connect_group_service(addr: &str) -> Result<GroupServiceClient<Channel>> {
    manager()
        .get(&normalize_endpoint(addr))
        .await
        .map(|client| client.as_ref().clone())
        .map_err(|err| anyhow!(err))
}

pub async fn list_members(group_id: i64, page: u32, page_size: u32) -> Result<GroupMembersPage> {
    let addr = resolve_group_addr(group_id).await?;
    let mut client = connect_group_service(&addr).await?;

    let fetch_size = page_size.saturating_add(1);
    let req = GetPageReq {
        group_id,
        page: page.saturating_sub(1) as u64,
        page_size: fetch_size as u64,
    };

    let mut members = client
        .get_page(req)
        .await
        .map_err(|status| anyhow!(status))?
        .into_inner()
        .members;

    let has_more = members.len() as u32 > page_size && page_size > 0;
    if has_more {
        members.truncate(page_size as usize);
    }

    Ok(GroupMembersPage { members, has_more })
}

pub async fn find_member(group_id: i64, member_id: i64) -> Result<Option<MemberRef>> {
    let addr = resolve_group_addr(group_id).await?;
    let mut client = connect_group_service(&addr).await?;

    let resp = client
        .get_all(GetAllReq { group_id })
        .await
        .map_err(|status| anyhow!(status))?
        .into_inner();

    Ok(resp.members.into_iter().find(|m| m.id == member_id))
}
