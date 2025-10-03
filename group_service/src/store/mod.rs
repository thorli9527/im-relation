use anyhow::Result;
use async_trait::async_trait;
use common::grpc::grpc_hot_group::group_service::MemberRef;
use common::GroupId;

#[async_trait]
pub trait GroupStorage: Send + Sync + 'static {
    async fn load_group(&self, gid: GroupId) -> Result<Option<Vec<MemberRef>>>;
    async fn save_group(&self, gid: GroupId, members: &[MemberRef]) -> Result<()>;
    async fn delete_group(&self, gid: GroupId) -> Result<()>;
    async fn load_user_groups(&self, uid: i64) -> Result<Option<Vec<i64>>>;
}

pub mod mysql;
