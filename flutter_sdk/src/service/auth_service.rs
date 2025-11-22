use std::{
    collections::HashMap,
    time::{SystemTime, UNIX_EPOCH},
};

use log::warn;

use crate::{
    api::app_api::{LoginRequest, LoginResult},
    api::config_api,
    generated::message::{self as msgpb, DeviceType as SocketDeviceType},
    job::message_job,
    service::socket_client::{SocketClient, SocketConfig},
};

pub fn handle_login(payload: &LoginRequest, result: &LoginResult) -> Result<i64, String> {
    // let validation = app_api::validate_session(SessionValidateRequest {
    //     session_token: result.token.clone(),
    // })?;
    // if !validation.ok {
    //     return Err("session validation failed".into());
    // }

    config_api::set_login_name(payload.target.clone())?;
    config_api::set_token(result.token.clone())?;
    config_api::set_uid(result.uid)?;
    let now = current_secs();
    config_api::set_last_login_at(now)?;
    config_api::set_last_alive_at(now)?;
    let device_type =
        SocketDeviceType::from_i32(payload.device_type).unwrap_or(SocketDeviceType::Unknown);
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
    config_api::set_token(String::new())?;
    config_api::set_uid(0)?;
    Ok(())
}

fn current_secs() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|dur| dur.as_secs() as i64)
        .unwrap_or_default()
}

fn current_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|dur| dur.as_millis() as i64)
        .unwrap_or_default()
}
