mod db;
pub mod grpc;
pub mod persist;

use std::net::SocketAddr;
use crate::db::hash_shard_map::HashShardMap;
use crate::grpc::group_service::hash_shard_server::{HashShard, HashShardServer};
use crate::grpc::group_service::{
    AllKeysByShardReq, AllKeysByShardResp, AllKeysReq, AllKeysResp, ChangeRoleReq, ChangeRoleResp,
    ClearReq, ClearResp, CountReq, CountResp, GetAllReq, GetAllResp, GetPageReq, GetPageResp,
    GroupRoleType, InsertManyReq, InsertManyResp, InsertReq, InsertResp, MemberRef, RemoveReq,
    RemoveResp, UserGroupsReq, UserGroupsResp,
};
use anyhow::Result;
use std::sync::Arc;
use std::time::Duration;
use tonic::{Code, Request, Response, Status};
use crate::persist::snapshot::{read_snapshot_bincode, restore_from_snapshot};
use crate::persist::snapshot_task::SnapshotTask;

#[derive(Clone)]
struct HashShardSvc {
    map: Arc<HashShardMap>,
}

#[tonic::async_trait]
impl HashShard for HashShardSvc {
    async fn insert(&self, req: Request<InsertReq>) -> Result<Response<InsertResp>, Status> {
        let r = req.into_inner();
        let member = r.member.unwrap();
        let member = MemberRef {
            id: member.id,
            role: member.role as i32,
        };
        match self.map.insert(r.group_id, member) {
            Ok(()) => return Ok(Response::new(InsertResp {})),
            Err(e) => return Err(Status::new(Code::Internal, "insert error")),
        }
    }

    async fn insert_many(
        &self,
        req: Request<InsertManyReq>,
    ) -> Result<Response<InsertManyResp>, Status> {
        let r = req.into_inner();
        let members: Vec<MemberRef> = r
            .members
            .into_iter()
            .map(|m| MemberRef {
                id: m.id,
                role: m.role as i32,
            })
            .collect();
        match self.map.insert_many(r.group_id, members) {
            Ok(_) => Ok(Response::new(InsertManyResp {})),
            Err(e) => return Err(Status::internal("insert_many error")),
        }
    }

    async fn remove(&self, req: Request<RemoveReq>) -> Result<Response<RemoveResp>, Status> {
        let r = req.into_inner();
        match self.map.remove(r.group_id, r.user_id) {
            Ok(removed) => return Ok(Response::new(RemoveResp { removed })),
            Err(e) => return Err(to_status("remove.error")),
        }
    }

    async fn change_role(
        &self,
        req: Request<ChangeRoleReq>,
    ) -> Result<Response<ChangeRoleResp>, Status> {
        let r = req.into_inner();
        let role = match r.role {
            0 => GroupRoleType::Owner,
            1 => GroupRoleType::Admin,
            _ => GroupRoleType::Member,
        };
        match self.map.change_role(r.group_id, r.user_id, role) {
            Ok(_) => Ok(Response::new(ChangeRoleResp {})),
            Err(e) => Err(to_status("")),
        }
    }

    async fn get_page(&self, req: Request<GetPageReq>) -> Result<Response<GetPageResp>, Status> {
        let r = req.into_inner();
        let list = self
            .map
            .get_page(r.group_id, r.page as usize, r.page_size as usize)
            .unwrap_or_default();
        let out = list
            .into_iter()
            .map(|m| MemberRef {
                id: m.id,
                role: to_role_enum(m.role),
            })
            .collect::<Vec<_>>();
        Ok(Response::new(GetPageResp { members: out }))
    }

    async fn get_all(&self, req: Request<GetAllReq>) -> Result<Response<GetAllResp>, Status> {
        let gid = req.into_inner().group_id;
        let list = self.map.get_member_by_key(gid);
        let out = list
            .into_iter()
            .map(|m| MemberRef {
                id: m.id,
                role: to_role_enum(m.role),
            })
            .collect();
        Ok(Response::new(GetAllResp { members: out }))
    }

    async fn count(&self, req: Request<CountReq>) -> Result<Response<CountResp>, Status> {
        let gid = req.into_inner().group_id;
        let c = self.map.get_member_count_by_key(gid) as u64;
        Ok(Response::new(CountResp { count: c }))
    }

    async fn user_groups(
        &self,
        req: Request<UserGroupsReq>,
    ) -> Result<Response<UserGroupsResp>, Status> {
        let uid = req.into_inner().user_id;
        let v = self.map.user_group_list(uid);
        Ok(Response::new(UserGroupsResp { group_ids: v }))
    }

    async fn all_keys(&self, _req: Request<AllKeysReq>) -> Result<Response<AllKeysResp>, Status> {
        Ok(Response::new(AllKeysResp {
            group_ids: self.map.all_keys(),
        }))
    }

    async fn all_keys_by_shard(
        &self,
        req: Request<AllKeysByShardReq>,
    ) -> Result<Response<AllKeysByShardResp>, Status> {
        let idx = req.into_inner().shard_idx as usize;
        Ok(Response::new(AllKeysByShardResp {
            group_ids: self.map.all_keys_by_shard(idx),
        }))
    }

    async fn clear(&self, req: Request<ClearReq>) -> Result<Response<ClearResp>, Status> {
        let gid = req.into_inner().group_id;
        self.map.clear(gid);
        Ok(Response::new(ClearResp {}))
    }
}

// ---- 辅助：错误映射 & role 枚举转换 ----
fn to_status<E: std::fmt::Display>(e: E) -> Status {
    Status::internal(e.to_string())
}

fn to_role_enum(i: i32) -> i32 {
    match GroupRoleType::from_i32(i).unwrap_or(GroupRoleType::Member) {
        GroupRoleType::Owner => GroupRoleType::Owner as i32,
        GroupRoleType::Admin => GroupRoleType::Admin as i32,
        GroupRoleType::Member => GroupRoleType::Member as i32,
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    // 日志

    // === 启动加载 ===
    let snapshot_path = std::env::var("SNAPSHOT_PATH").unwrap_or_else(|_| "data/group.snapshot".to_string());
    let map = match read_snapshot_bincode(&snapshot_path) {
        Ok(snap) => {
            tracing::info!("snapshot found, restoring...");
            restore_from_snapshot(snap)
        }
        Err(e) => {
            tracing::warn!("no snapshot or failed to read ({}), creating empty map", e);
            HashShardMap::new(64, 1) // 默认分片数/每群分片参数，可按需配置
        }
    };
    let map = Arc::new(map);

    // === 定时落盘 ===
    let period_sec: u64 = std::env::var("SNAPSHOT_PERIOD_SECS")
        .ok().and_then(|s| s.parse().ok())
        .unwrap_or(30);
    SnapshotTask::new(map.clone(), &snapshot_path, Duration::from_secs(period_sec)).spawn();

    // === gRPC 服务 ===
    let addr: SocketAddr = "0.0.0.0:50051".parse().unwrap();
    let svc = HashShardSvc { map: map.clone() };

    tonic::transport::Server::builder()
        .add_service(HashShardServer::new(svc))
        .serve(addr)
        .await?;

    // (正常不会走到这)
    // 退出前也可手动再写一次快照：
    // let snap = build_snapshot(&map);
    // let _ = write_snapshot_bincode(&snap, &snapshot_path);

    Ok(())
}
