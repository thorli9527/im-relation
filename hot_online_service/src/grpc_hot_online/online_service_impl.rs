use async_trait::async_trait;
use std::sync::Arc;
use tonic::{Request, Response, Status};

use crate::grpc_hot_online::online_service::online_service_server::OnlineService;
use crate::grpc_hot_online::online_service::{
    CheckOnlineBatchRequest, CheckOnlineBatchResponse,
    CheckOnlineRequest, CheckOnlineResponse,
    GetStatsRequest, GetStatsResponse,
    SetOnlineRequest, SetOnlineResponse,
};
use crate::online_store::OnlineStore;

#[derive(Clone)]
pub struct OnLineServiceImpl {
    store: Arc<OnlineStore>,
}

impl OnLineServiceImpl {
    pub fn new(store: Arc<OnlineStore>) -> Self {
        Self { store }
    }
}

#[async_trait]
impl OnlineService for OnLineServiceImpl {
    async fn set_online(
        &self,
        request: Request<SetOnlineRequest>,
    ) -> Result<Response<SetOnlineResponse>, Status> {
        let req = request.into_inner();
        // 将 req.user_id 转为你的 UserId（通常是 i64）
        self.store.set_online(req.user_id as _, req.online);
        Ok(Response::new(SetOnlineResponse { ok: true }))
    }

    async fn check_online(
        &self,
        request: Request<CheckOnlineRequest>,
    ) -> Result<Response<CheckOnlineResponse>, Status> {
        let req = request.into_inner();
        let online = self.store.contains(req.user_id as _);
        Ok(Response::new(CheckOnlineResponse { online }))
    }

    async fn check_online_batch(
        &self,
        request: Request<CheckOnlineBatchRequest>,
    ) -> Result<Response<CheckOnlineBatchResponse>, Status> {
        let req = request.into_inner();
        let results = self.store.contains_many_ordered(req.user_ids.iter().cloned().map(|u| u as _));
        Ok(Response::new(CheckOnlineBatchResponse { results }))
    }

    async fn get_stats(
        &self,
        _request: Request<GetStatsRequest>,
    ) -> Result<Response<GetStatsResponse>, Status> {
        let s = self.store.stats();
        Ok(Response::new(GetStatsResponse {
            total: s.total,
            per_shard: s.per_shard,
            max_shard_idx: s.max_shard.0 as u32,
            max_shard_count: s.max_shard.1,
        }))
    }
}
