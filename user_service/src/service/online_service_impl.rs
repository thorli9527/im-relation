use async_trait::async_trait;
use std::sync::Arc;
use tonic::{Request, Response, Status};

use crate::db::traits::{SessionTokenRepo, SessionTokenUpsert};
use crate::online_store::OnlineStore;
use common::infra::grpc::grpc_user::online_service::online_service_server::OnlineService;
use common::infra::grpc::grpc_user::online_service::DeviceType as PbDeviceType;
use common::infra::grpc::grpc_user::online_service::{
    revoke_session_token_request, CheckOnlineBatchRequest, CheckOnlineBatchResponse,
    CheckOnlineRequest, CheckOnlineResponse, GetStatsRequest, GetStatsResponse,
    RevokeSessionTokenRequest, RevokeSessionTokenResponse, SessionTokenStatus, SetOnlineRequest,
    SetOnlineResponse, TouchSessionTokenRequest, TouchSessionTokenResponse,
    UpsertSessionTokenRequest, UpsertSessionTokenResponse, ValidateSessionTokenRequest,
    ValidateSessionTokenResponse,
};
use std::convert::TryFrom;
use log::{error, info, warn};

fn mask_token(token: &str) -> String {
    let len = token.len();
    if len <= 8 {
        return "***".to_string();
    }
    format!("{}***{}", &token[..4], &token[len - 4..])
}

#[derive(Clone)]
pub struct OnLineServiceImpl<R>
where
    R: SessionTokenRepo,
{
    store: Arc<OnlineStore>,
    session_repo: Arc<R>,
}

impl<R> OnLineServiceImpl<R>
where
    R: SessionTokenRepo,
{
    pub fn new(store: Arc<OnlineStore>, session_repo: Arc<R>) -> Self {
        Self {
            store,
            session_repo,
        }
    }
}

#[async_trait]
impl<R> OnlineService for OnLineServiceImpl<R>
where
    R: SessionTokenRepo,
{
    async fn set_online(
        &self,
        request: Request<SetOnlineRequest>,
    ) -> Result<Response<SetOnlineResponse>, Status> {
        let req = request.into_inner();
        // 将 req.uid 转为你的 UID（通常是 i64）
        self.store.set_online(req.uid as _, req.online);
        Ok(Response::new(SetOnlineResponse { ok: true }))
    }

    async fn check_online(
        &self,
        request: Request<CheckOnlineRequest>,
    ) -> Result<Response<CheckOnlineResponse>, Status> {
        let req = request.into_inner();
        let online = self.store.contains(req.uid as _);
        Ok(Response::new(CheckOnlineResponse { online }))
    }

    async fn check_online_batch(
        &self,
        request: Request<CheckOnlineBatchRequest>,
    ) -> Result<Response<CheckOnlineBatchResponse>, Status> {
        let req = request.into_inner();
        let results = self
            .store
            .contains_many_ordered(req.uids.iter().cloned().map(|u| u as _));
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

    async fn upsert_session_token(
        &self,
        request: Request<UpsertSessionTokenRequest>,
    ) -> Result<Response<UpsertSessionTokenResponse>, Status> {
        let req = request.into_inner();
        let device_type = PbDeviceType::try_from(req.device_type).unwrap_or(PbDeviceType::Unknown);
        let payload = SessionTokenUpsert {
            uid: req.uid,
            device_type,
            device_id: req.device_id,
            login_ip: req.login_ip.map(|s| s.into_bytes()),
            user_agent: req.user_agent,
        };
        let res = self
            .session_repo
            .upsert_session_token(payload)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;

        let expires_at_ms = (res.expires_at.unix_timestamp_nanos() / 1_000_000) as u64;

        Ok(Response::new(UpsertSessionTokenResponse {
            session_token: res.session_token,
            expires_at: expires_at_ms,
            previous_token: res.previous_token,
        }))
    }

    async fn validate_session_token(
        &self,
        request: Request<ValidateSessionTokenRequest>,
    ) -> Result<Response<ValidateSessionTokenResponse>, Status> {
        let req = request.into_inner();
        info!(
            "validate_session_token: token_len={} masked={}",
            req.session_token.len(),
            mask_token(&req.session_token)
        );
        let record_opt = match self
            .session_repo
            .validate_session_token(&req.session_token)
            .await
        {
            Ok(res) => res,
            Err(e) => {
                error!("validate_session_token: repo error: {}", e);
                return Err(Status::internal(e.to_string()));
            }
        };

        if let Some(rec) = record_opt {
            let expires_at_ms = (rec.expires_at.unix_timestamp_nanos() / 1_000_000) as u64;
            let status = match rec.status {
                1 => SessionTokenStatus::StsActive,
                2 => SessionTokenStatus::StsRevoked,
                3 => SessionTokenStatus::StsExpired,
                _ => SessionTokenStatus::StsUnknown,
            } as i32;
            info!(
                "validate_session_token: found uid={} device_type={:?} device_id={} status={} expires_at_ms={}",
                rec.uid, rec.device_type, rec.device_id, status, expires_at_ms
            );
            return Ok(Response::new(ValidateSessionTokenResponse {
                status,
                uid: rec.uid,
                device_type: rec.device_type as i32,
                device_id: rec.device_id,
                expires_at: expires_at_ms,
            }));
        }

        warn!("validate_session_token: token not found or revoked");
        Ok(Response::new(ValidateSessionTokenResponse {
            status: SessionTokenStatus::StsRevoked as i32,
            uid: 0,
            device_type: PbDeviceType::Unknown as i32,
            device_id: String::new(),
            expires_at: 0,
        }))
    }

    async fn revoke_session_token(
        &self,
        request: Request<RevokeSessionTokenRequest>,
    ) -> Result<Response<RevokeSessionTokenResponse>, Status> {
        let req = request.into_inner();
        let revoked = match req.target {
            Some(revoke_session_token_request::Target::SessionToken(token)) => {
                info!(
                    "revoke_session_token: target=token token_len={} masked={}",
                    token.len(),
                    mask_token(&token)
                );
                match self.session_repo.revoke_session_token_by_token(&token).await {
                    Ok(res) => {
                        if res.is_some() {
                            info!("revoke_session_token: token revoked");
                        } else {
                            warn!("revoke_session_token: token not found in repo");
                        }
                        res
                    }
                    Err(e) => {
                        error!(
                            "revoke_session_token: revoke_session_token_by_token failed: {}",
                            e
                        );
                        return Err(Status::internal(e.to_string()));
                    }
                }
            }
            Some(revoke_session_token_request::Target::Device(device)) => {
                let device_type =
                    PbDeviceType::try_from(device.device_type).unwrap_or(PbDeviceType::Unknown);
                info!(
                    "revoke_session_token: target=device uid={} device_type={:?} device_id={}",
                    device.uid, device_type, device.device_id
                );
                match self
                    .session_repo
                    .revoke_session_token_by_device(device.uid, device_type, &device.device_id)
                    .await
                {
                    Ok(res) => {
                        if res.is_some() {
                            info!(
                                "revoke_session_token: device session revoked uid={} device_id={}",
                                device.uid, device.device_id
                            );
                        } else {
                            warn!(
                                "revoke_session_token: no session token found for uid={} device_id={}",
                                device.uid, device.device_id
                            );
                        }
                        res
                    }
                    Err(e) => {
                        error!(
                            "revoke_session_token: revoke_session_token_by_device failed uid={} device_id={} err={}",
                            device.uid, device.device_id, e
                        );
                        return Err(Status::internal(e.to_string()));
                    }
                }
            }
            None => {
                warn!("revoke_session_token: missing target");
                None
            }
        };

        Ok(Response::new(RevokeSessionTokenResponse {
            ok: revoked.is_some(),
            revoked_token: revoked,
        }))
    }

    async fn touch_session_token(
        &self,
        request: Request<TouchSessionTokenRequest>,
    ) -> Result<Response<TouchSessionTokenResponse>, Status> {
        let req = request.into_inner();
        let affected = self
            .session_repo
            .touch_tokens(&req.session_tokens)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;
        Ok(Response::new(TouchSessionTokenResponse {
            touched: affected as u32,
        }))
    }
}
