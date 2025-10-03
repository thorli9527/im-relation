use anyhow::{anyhow, Result};
use common::grpc::grpc_hot_online::online_service::{
    DeviceType, SessionTokenStatus, ValidateSessionTokenRequest,
};

use crate::service::grpc_gateway;

#[derive(Debug, Clone, Copy)]
pub struct ActiveSession {
    pub user_id: i64,
    pub device_type: DeviceType,
}

/// Validate the session token via OnlineService and ensure it is active.
/// Returns the user id and device type associated with the session.
pub async fn ensure_active_session(session_token: &str) -> Result<ActiveSession> {
    let mut online_client = grpc_gateway::get_online_client()
        .await
        .map_err(|err| anyhow!("init online client: {err}"))?;

    let response = online_client
        .validate_session_token(ValidateSessionTokenRequest {
            session_token: session_token.to_string(),
        })
        .await
        .map_err(|err| anyhow!("validate session token: {err}"))?
        .into_inner();

    let status = SessionTokenStatus::try_from(response.status)
        .map_err(|_| anyhow!("invalid session token status"))?;
    if status != SessionTokenStatus::StsActive {
        return Err(anyhow!("session token inactive"));
    }

    let device_type =
        DeviceType::try_from(response.device_type).map_err(|_| anyhow!("invalid device type"))?;

    Ok(ActiveSession {
        user_id: response.user_id,
        device_type,
    })
}
