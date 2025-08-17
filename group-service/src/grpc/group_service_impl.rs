use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use log::{info, warn};
use sqlx::mysql::MySqlPool;
use tonic::{Request, Response, Status};

use crate::grpc::group_service::{group_service_server::GroupService as GrpcGroupService, CommonResp, CreateGroupReq, UpdateGroupProfileReq, DismissGroupReq, InsertReq, InsertResp, InsertManyReq, InsertManyResp, RemoveReq, RemoveResp, ChangeRoleReq, ChangeRoleResp, ChangeAliasReq, ChangeAliasResp, GetPageReq, GetPageResp, GetAllReq, GetAllResp, CountReq, CountResp, UserGroupsReq, UserGroupsResp, AllKeysReq, AllKeysResp, AllKeysByShardReq, AllKeysByShardResp, ClearReq, ClearResp, GroupRoleType, MemberRef, IdReq, GroupInfo};
use crate::hot_cold::HotColdFacade;
use crate::profile::{GroupProfileCache, MySqlGroupProfileStore};
use crate::store::GroupStorage; // 你的冷存储抽象

use common::MemberListError;
use crate::db::group::GroupEntity;

#[derive(Clone)]
pub struct GroupServiceImpl<S: GroupStorage> {
    facade:  Arc<HotColdFacade<S>>,                         // 成员热层（带写穿）
    profile: Arc<GroupProfileCache<MySqlGroupProfileStore>>, // 群信息 L1 写穿
}

impl<S: GroupStorage> GroupServiceImpl<S> {
    pub fn new(
        facade: Arc<HotColdFacade<S>>,
        profile: Arc<GroupProfileCache<MySqlGroupProfileStore>>,
    ) -> Self {
        Self { facade, profile }
    }

    #[inline]
    fn now_ms() -> u64 {
        SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_millis() as u64
    }

    #[inline]
    fn ok() -> CommonResp { CommonResp { success: true, message: String::new() } }

    #[inline]
    fn map_hot_err(e: MemberListError) -> Status {
        match e {
            MemberListError::AlreadyExists => Status::already_exists("already exists"),
            MemberListError::NotFound => Status::not_found("not found"),
            MemberListError::PermissionDenied(msg) => Status::permission_denied(msg),
            MemberListError::PreconditionFailed(msg) => Status::failed_precondition(msg),
            MemberListError::InvalidArgument(msg) => Status::invalid_argument(msg),
            MemberListError::InvalidUserId | MemberListError::InvalidGroupId =>
                Status::invalid_argument(e.to_string()),
            MemberListError::TooManyMembers => Status::resource_exhausted(e.to_string()),
            _ => Status::internal(e.to_string()),
        }
    }
}

// ============================ gRPC 实现 ============================

#[tonic::async_trait]
impl<S> GrpcGroupService for GroupServiceImpl<S>
where
    S: GroupStorage + Send + Sync + 'static,
{
    // ---------- 群基础：创建/更新资料/解散 ----------

    async fn create_group(
        &self,
        request: Request<CreateGroupReq>,
    ) -> Result<Response<CommonResp>, Status> {
        let r = request.into_inner();
        let gid = r.id;
        let owner_uid = r.creator_uid;

        // 1) 热层：Owner + 初始成员（去重）
        let owner = MemberRef { id: owner_uid, alias: None, role: GroupRoleType::Owner as i32 };
        if let Err(e) = self.facade.insert(gid, owner).await {
            if !matches!(e, MemberListError::AlreadyExists) { return Err(Self::map_hot_err(e)); }
        }
        use std::collections::HashSet;
        let mut seen = HashSet::from([owner_uid]);
        let mut batch = Vec::new();
        for uid in r.members {
            if seen.insert(uid) {
                batch.push(MemberRef { id: uid, alias: None, role: GroupRoleType::Member as i32 });
            }
        }
        if !batch.is_empty() {
            if let Err(e) = self.facade.insert_many(gid, batch).await {
                if !matches!(e, MemberListError::AlreadyExists) { return Err(Self::map_hot_err(e)); }
            }
        }

        // 2) 群信息写穿
        let now = Self::now_ms();
        let entity = GroupEntity {
            id: gid,
            name: r.name,
            avatar: r.avatar.unwrap_or_default(),
            description: r.intro.unwrap_or_default(),
            notice: "".into(),
            join_permission: 0,
            owner_id: owner_uid,
            group_type: 0,
            allow_search: true,
            enable: true,
            create_time: now,
            update_time: now,
        };
        self.profile.upsert(entity, None).await
            .map_err(|e| Status::internal(format!("create_group profile upsert: {e}")))?;

        info!("create_group ok (write-through): gid={gid}, owner={owner_uid}");
        Ok(Response::new(Self::ok()))
    }

    async fn update_group_profile(
        &self,
        request: Request<UpdateGroupProfileReq>,
    ) -> Result<Response<CommonResp>, Status> {
        let r = request.into_inner();
        let gid = r.group_id;
        let operator = r.operator_uid;

        // 1) 权限：Owner/Admin
        if !auth_is_owner_or_admin(&self.facade, gid, operator).await? {
            return Err(Status::permission_denied("no permission to update group profile"));
        }

        // 2) 读当前资料（多数缓存返回 Arc<GroupEntity>）
        let cur = match self.profile.get_or_load(gid)
            .await
            .map_err(|e| Status::internal(e.to_string()))?
        {
            Some(x) => x,               // x: Arc<GroupEntity>
            None => return Err(Status::not_found("group not found")),
        };

        // 3) 克隆出可变实体（从 Arc<T> 拿出 T 的副本）
        // 等价写法：let mut patch: GroupEntity = cur.as_ref().clone();
        let mut patch: GroupEntity = (*cur).clone();
        let prev_update = cur.update_time;

        // 4) 规范化 + 比较后再赋值
        let mut changed = false;
        if let Some(v) = r.name.map(|s| s.trim().to_string()) {
            if v.is_empty() {
                return Err(Status::invalid_argument("name cannot be empty"));
            }
            if v != patch.name {
                patch.name = v;
                changed = true;
            }
        }
        if let Some(v) = r.avatar.map(|s| s.trim().to_string()) {
            if v != patch.avatar {
                patch.avatar = v;
                changed = true;
            }
        }
        if let Some(v) = r.intro.map(|s| s.trim().to_string()) {
            if v != patch.description {
                patch.description = v;
                changed = true;
            }
        }

        if !changed {
            return Ok(Response::new(CommonResp { success: true, message: "no changes".into() }));
        }

        // 如果由存储层自动更新时间，这里可以不设；否则本地更新
        patch.update_time = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as u64;

        // 5) CAS 写穿（传入旧的 update_time）
        self.profile
            .upsert(patch, Some(prev_update))   // ← 这里现在是 GroupEntity，不是 Arc<_>
            .await
            .map_err(|_| Status::failed_precondition("conflict, please retry"))?;

        Ok(Response::new(CommonResp { success: true, message: String::new() }))
    }

    async fn get_group(
        &self,
        request: Request<IdReq>,
    ) -> Result<Response<GroupInfo>, Status> {
        let req = request.into_inner();
        let gid = req.ref_id;

        // 1) 先从 L1/L2 取群资料（L1 miss 时 L2 加载）
        let profile = match self
            .profile
            .get_or_load(gid)
            .await
            .map_err(|e| Status::internal(e.to_string()))?
        {
            Some(p) => p,              // 通常是 Arc<GroupEntity>
            None => return Err(Status::not_found("group not found")),
        };

        // 2) 成员数从热层拿（若为冷群会自动 ensure_hot）
        let member_cnt = self.facade.count(gid).await as u32;

        // 3) 组装返回（字段名按你的 GroupInfo 定义调整）
        let gi = GroupInfo {
            id:            profile.id,
            name:          profile.name.clone(),
            avatar:        profile.avatar.clone(),
            description:   profile.description.clone(),
            notice:        profile.notice.clone(),
            join_permission: profile.join_permission,
            owner_id:      profile.owner_id,
            group_type:    profile.group_type,
            allow_search:  profile.allow_search,
            enable:        profile.enable,
            create_time:   profile.create_time,
            update_time:   profile.update_time,
            member_cnt, // 如果你的 GroupInfo 没这个字段，请删掉
        };

        log::info!("get_group ok: gid={}", gid);
        Ok(Response::new(gi))
    }

    async fn dismiss_group(
        &self,
        request: Request<DismissGroupReq>,
    ) -> Result<Response<CommonResp>, Status> {
        let r = request.into_inner();
        let gid = r.group_id; // 如果 proto 用 id，请对齐修改
        if !auth_is_owner(&self.facade, gid, r.owner_uid).await? {
            return Err(Status::permission_denied("only owner can dismiss group"));
        }
        // 1) 清成员（热层会触发冷侧清理）
        self.facade.clear(gid).await;
        // 2) 群信息删除
        self.profile.delete(gid).await
            .map_err(|e| Status::internal(e.to_string()))?;
        Ok(Response::new(Self::ok()))
    }

    // ---------- 成员写 ----------

    async fn insert(&self, req: Request<InsertReq>) -> Result<Response<InsertResp>, Status> {
        let r = req.into_inner();
        let gid = r.group_id;
        let member = r.member.ok_or_else(|| Status::invalid_argument("member is required"))?;
        self.facade.insert(gid, member).await.map_err(Self::map_hot_err)?;
        Ok(Response::new(InsertResp{}))
    }

    async fn insert_many(
        &self,
        req: Request<InsertManyReq>,
    ) -> Result<Response<InsertManyResp>, Status> {
        let r = req.into_inner();
        let gid = r.group_id;
        self.facade.insert_many(gid, r.members).await.map_err(Self::map_hot_err)?;
        Ok(Response::new(InsertManyResp{}))
    }

    async fn remove(&self, req: Request<RemoveReq>) -> Result<Response<RemoveResp>, Status> {
        let r = req.into_inner();
        let removed = self.facade.remove(r.group_id, r.user_id).await.map_err(Self::map_hot_err)?;
        Ok(Response::new(RemoveResp { removed }))
    }

    async fn change_role(
        &self,
        req: Request<ChangeRoleReq>,
    ) -> Result<Response<ChangeRoleResp>, Status> {
        let r = req.into_inner();
        let Some(role) = GroupRoleType::from_i32(r.role) else {
            return Err(Status::invalid_argument("invalid role"));
        };
        self.facade.change_role(r.group_id, r.user_id, role).await.map_err(Self::map_hot_err)?;
        Ok(Response::new(ChangeRoleResp{}))
    }

    async fn change_alias(
        &self,
        req: Request<ChangeAliasReq>,
    ) -> Result<Response<ChangeAliasResp>, Status> {
        let r = req.into_inner();
        self.facade.change_alias(r.group_id, r.user_id, r.alias).await.map_err(Self::map_hot_err)?;
        Ok(Response::new(ChangeAliasResp{}))
    }

    // ---------- 成员读 ----------

    async fn get_page(&self, req: Request<GetPageReq>) -> Result<Response<GetPageResp>, Status> {
        let r = req.into_inner();
        let page = r.page as usize;
        let size = r.page_size as usize;
        let members = self.facade.get_page(r.group_id, page, size).await;
        Ok(Response::new(GetPageResp { members }))
    }

    async fn get_all(&self, req: Request<GetAllReq>) -> Result<Response<GetAllResp>, Status> {
        let r = req.into_inner();
        let members = self.facade.get_all(r.group_id).await;
        Ok(Response::new(GetAllResp { members }))
    }

    async fn count(&self, req: Request<CountReq>) -> Result<Response<CountResp>, Status> {
        let r = req.into_inner();
        let n = self.facade.count(r.group_id).await as u64;
        Ok(Response::new(CountResp { count: n }))
    }

    async fn user_groups(
        &self,
        req: Request<UserGroupsReq>,
    ) -> Result<Response<UserGroupsResp>, Status> {
        let r = req.into_inner();
        let gids = self.facade.user_groups(r.user_id).await;
        Ok(Response::new(UserGroupsResp { group_ids: gids }))
    }

    async fn all_keys(&self, _req: Request<AllKeysReq>) -> Result<Response<AllKeysResp>, Status> {
        let keys = self.facade.all_keys();
        Ok(Response::new(AllKeysResp { group_ids: keys }))
    }

    async fn all_keys_by_shard(
        &self,
        req: Request<AllKeysByShardReq>,
    ) -> Result<Response<AllKeysByShardResp>, Status> {
        let r = req.into_inner();
        let keys = self.facade.all_keys_by_shard(r.shard_idx as usize);
        Ok(Response::new(AllKeysByShardResp { group_ids: keys }))
    }

    async fn clear(&self, req: Request<ClearReq>) -> Result<Response<ClearResp>, Status> {
        let r = req.into_inner();
        self.facade.clear(r.group_id).await;
        Ok(Response::new(ClearResp{}))
    }
}

// ---------------- 权限辅助 ----------------

async fn auth_is_owner_or_admin<S: GroupStorage>(
    facade: &HotColdFacade<S>, gid: i64, uid: i64,
) -> Result<bool, Status> {
    let members = facade.get_all(gid).await;
    for m in members {
        if m.id == uid {
            if let Some(role) = GroupRoleType::from_i32(m.role) {
                return Ok(matches!(role, GroupRoleType::Owner | GroupRoleType::Admin));
            }
        }
    }
    Ok(false)
}

async fn auth_is_owner<S: GroupStorage>(
    facade: &HotColdFacade<S>, gid: i64, uid: i64,
) -> Result<bool, Status> {
    let members = facade.get_all(gid).await;
    for m in members {
        if m.id == uid {
            if let Some(role) = GroupRoleType::from_i32(m.role) {
                return Ok(matches!(role, GroupRoleType::Owner));
            }
        }
    }
    Ok(false)
}
