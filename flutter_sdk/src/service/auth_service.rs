use std::time::{SystemTime, UNIX_EPOCH};

use crate::{
    api::app_api::{LoginRequest, LoginResult},
    generated::message::{DeviceType as SocketDeviceType},
    service::socket_client::{SocketClient, SocketConfig},
    service::user_service::UserService as LocalUserService,
};

pub fn handle_login(payload: &LoginRequest, result: &LoginResult) -> Result<i64, String> {
    // let validation = app_api::validate_session(SessionValidateRequest {
    //     session_token: result.token.clone(),
    // })?;
    // if !validation.ok {
    //     return Err("session validation failed".into());
    // }

    let device_type =
        SocketDeviceType::from_i32(payload.device_type).unwrap_or(SocketDeviceType::Unknown);

    // 缓存当前用户资料到本地 user_info 表，便于会话/好友展示。
    LocalUserService::get().upsert_from_login(result)?;

    let socket_config = SocketConfig {
        socket_addr: result.socket_addr.clone(),
        uid: result.uid,
        device_type,
        device_id: payload.device_id.clone(),
        token: result.token.clone(),
        heartbeat_secs: 60,
    };
    SocketClient::get().connect(socket_config)?;
    Ok(0)
}

pub fn logout() -> Result<(), String> {
    SocketClient::get().disconnect()?;
    Ok(())
}

fn current_secs() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|dur| dur.as_secs() as i64)
        .unwrap_or_default()
}
