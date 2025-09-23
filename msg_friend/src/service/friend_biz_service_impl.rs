//! 好友业务 gRPC 服务实现：处理好友请求、删除、备注等逻辑。

use crate::dao::{
    get_friend_request_by_id, mark_friend_request_decision, upsert_friend_request, FriendRequestRow,
};
use crate::server::server_grpc::Services;
use common::grpc::grpc_msg_friend::msg_friend_service::{
    self, friend_biz_service_server::FriendBizService,
};
use log::{info, warn};
use std::sync::Arc;

/// MsgFriendServiceImpl
///
/// 职责与流向：
/// - 对外暴露“好友业务接口”（friend.proto::FriendBizService），由 app_socket 转发 201..205 到此；
/// - 在本服务内把调用落到 hot_friend_service（通过 HfFriendClient），实现好友关系的写入与维护；
/// - 该层不直接做鉴权和参数填充，假设上游网关/handler 已校验、限流与补齐上下文。
///
/// 方法与语义：
/// - SendFriendRequest(FriendRequest): 目前直接映射为 AddFriend(user_id, friend_id)，忽略 remark/source 等扩展；
/// - HandleFriendRequest(FriendRequestDecision): accept=true 预期应“将申请落地为好友关系”；当前缺少 request_id→(from,to) 映射，先占位；
/// - DeleteFriend(FriendDelete): 调用 RemoveFriend(user_id, friend_id)，幂等；
/// - UpdateFriendRemark(FriendUpdateRemark): 调用 UpdateFriendAlias(user_id, friend_id, alias)。
///
/// 错误处理：
/// - 下游 gRPC 失败统一转为 Status::internal，并记录日志；
/// - 当未配置 hot_friend_service 客户端时，仅告警并返回成功（可按需改为返回 Unavailable）。

/// 业务实现。持有到内部 `Services` 的引用，以复用数据库/客户端等资源。
pub struct MsgFriendServiceImpl {
    pub inner: Arc<Services>,
}

impl MsgFriendServiceImpl {
    /// 构造函数：传入共享的 `Services`（包含 HF 客户端、DB 连接等）。
    pub fn new(inner: Arc<Services>) -> Self {
        Self { inner }
    }
}

#[tonic::async_trait]
impl FriendBizService for MsgFriendServiceImpl {
    /// 发送好友申请
    ///
    /// 当前实现：仅持久化申请（friend_requests），不直接建立好友关系；
    /// HandleFriendRequest(accept=true) 时再调用 hot_friend_service.AddFriend 落地关系。
    async fn send_friend_request(
        &self,
        request: tonic::Request<msg_friend_service::FriendRequest>,
    ) -> Result<tonic::Response<()>, tonic::Status> {
        let r = request.into_inner();
        let gen_id = if r.id == 0 { r.created_at } else { r.id };
        let row = FriendRequestRow {
            id: gen_id,
            from_user_id: r.from_user_id,
            to_user_id: r.to_user_id,
            reason: r.reason,
            source: r.source,
            created_at: r.created_at,
            decided_at: None,
            accepted: None,
            remark: r.remark,
        };
        upsert_friend_request(self.inner.pool(), &row)
            .await
            .map_err(|e| tonic::Status::internal(format!("persist friend_request failed: {e}")))?;
        Ok(tonic::Response::new(()))
    }

    /// 处理好友申请（接受/拒绝）
    ///
    /// 当前实现：
    /// - accept=false：仅记录日志返回成功；
    /// - accept=true：由于缺少 `request_id` → (from_user_id, to_user_id) 的映射查询，暂不下沉到 AddFriend。
    /// 待办：落库好友申请，Handle 时按 request_id 查到 from/to 与 remark，再决定是否调用 AddFriend。
    async fn handle_friend_request(
        &self,
        request: tonic::Request<msg_friend_service::FriendRequestDecision>,
    ) -> Result<tonic::Response<()>, tonic::Status> {
        let r = request.into_inner();
        // 查询申请详情
        let req_row = get_friend_request_by_id(self.inner.pool(), r.request_id)
            .await
            .map_err(|e| tonic::Status::internal(format!("query friend_request failed: {e}")))?;
        if let Some(row) = req_row {
            // 记录决定
            let _ = mark_friend_request_decision(
                self.inner.pool(),
                row.id,
                r.decided_at,
                r.accept,
                r.remark.clone(),
            )
            .await
            .map_err(|e| {
                tonic::Status::internal(format!("update friend_request decision failed: {e}"))
            })?;

            if r.accept {
                if let Some(cli) = self.inner.friend_client() {
                    // 双方别名：
                    // - 申请时 remark（row.remark）作为 from->to 的别名
                    // - 受理时 remark（r.remark）作为 to->from 的别名
                    let req = common::grpc::grpc_hot_friend::friend_service::AddFriendReq {
                        user_id: row.from_user_id,
                        friend_id: row.to_user_id,
                        alias_for_user: row.remark.clone(),
                        alias_for_friend: r.remark.clone(),
                    };
                    let _ = cli.clone().add_friend(req).await.map_err(|e| {
                        tonic::Status::internal(format!("add_friend both failed: {e}"))
                    })?;
                } else {
                    warn!("FriendBizService: friend_client not configured; accept ignored for request_id={}", row.id);
                }
            } else {
                info!("FriendBizService: request rejected: id={}", row.id);
            }
        } else {
            warn!(
                "FriendBizService: HandleFriendRequest but request not found: id={}",
                r.request_id
            );
        }
        Ok(tonic::Response::new(()))
    }

    /// 删除好友关系（幂等）
    async fn delete_friend(
        &self,
        request: tonic::Request<msg_friend_service::FriendDelete>,
    ) -> Result<tonic::Response<()>, tonic::Status> {
        let r = request.into_inner();
        if let Some(cli) = self.inner.friend_client() {
            let req = common::grpc::grpc_hot_friend::friend_service::RemoveFriendReq {
                user_id: r.operator_user_id,
                friend_id: r.friend_user_id,
            };
            let _ = cli
                .clone()
                .remove_friend(req)
                .await
                .map_err(|e| tonic::Status::internal(format!("remove_friend failed: {e}")))?;
        } else {
            warn!("FriendBizService: friend_client not configured; DeleteFriend ignored");
        }
        Ok(tonic::Response::new(()))
    }

    /// 更新好友备注
    ///
    /// 约定：remark 传空字符串可视为“清除备注”。下游 UpdateFriendAlias 直接传递该值。
    async fn update_friend_remark(
        &self,
        request: tonic::Request<msg_friend_service::FriendUpdateRemark>,
    ) -> Result<tonic::Response<()>, tonic::Status> {
        let r = request.into_inner();
        if let Some(cli) = self.inner.friend_client() {
            let req = common::grpc::grpc_hot_friend::friend_service::UpdateFriendAliasReq {
                user_id: r.user_id,
                friend_id: r.friend_user_id,
                alias: Some(r.remark),
            };
            let _ =
                cli.clone().update_friend_alias(req).await.map_err(|e| {
                    tonic::Status::internal(format!("update_friend_alias failed: {e}"))
                })?;
        } else {
            warn!("FriendBizService: friend_client not configured; UpdateFriendRemark ignored");
        }
        Ok(tonic::Response::new(()))
    }
}
