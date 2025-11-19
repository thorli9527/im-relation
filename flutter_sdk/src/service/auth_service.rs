use std::{
    collections::HashMap,
    time::{SystemTime, UNIX_EPOCH},
};

use log::warn;

use crate::{
    api::app_api::{self, LoginRequest, LoginResult, SessionValidateRequest},
    api::config_api,
    generated::{message as msgpb, socket::DeviceType as SocketDeviceType},
    job::message_job,
    service::socket_client::{SocketClient, SocketConfig},
};

pub fn handle_login(payload: &LoginRequest, result: &LoginResult) -> Result<(), String> {
    // let validation = app_api::validate_session(SessionValidateRequest {
    //     session_token: result.token.clone(),
    // })?;
    // if !validation.ok {
    //     return Err("session validation failed".into());
    // }

    config_api::set_login_name(payload.target.clone())?;
    config_api::set_token(result.token.clone())?;
    config_api::set_user_id(result.uid.clone())?;
    let now = current_secs();
    config_api::set_last_login_at(now)?;
    config_api::set_last_alive_at(now)?;
    let device_type =
        SocketDeviceType::from_i32(payload.device_type).unwrap_or(SocketDeviceType::Unknown);
    let socket_config = SocketConfig {
        socket_addr: result.socket_addr.clone(),
        user_id: result.uid.clone(),
        device_type,
        device_id: payload.device_id.clone(),
        token: result.token.clone(),
        heartbeat_secs: 60,
    };
    SocketClient::get().connect(socket_config)?;

    let auth_payload = build_auth_content(result.uid.clone());
    if let Err(err) = message_job::enqueue_outbound(auth_payload, 0) {
        warn!("auth message enqueue failed: {}", err);
    }

    Ok(())
}

pub fn logout() -> Result<(), String> {
    SocketClient::get().disconnect()?;
    config_api::set_token(String::new())?;
    config_api::set_user_id(0)?;
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

fn build_auth_content(user_id: i64) -> msgpb::Content {
    let mut content = msgpb::Content::default();
    content.scene = msgpb::ChatScene::Profile as i32;
    content.sender_id = user_id;
    content.receiver_id = user_id;
    content.timestamp = current_millis();
    let mut metadata = HashMap::new();
    metadata.insert("phase".to_string(), "auth".to_string());
    content.system_business = Some(msgpb::SystemBusinessContent {
        business_type: msgpb::SystemBusinessType::SystemBusinessUpgrade as i32,
        title: "client-auth".to_string(),
        detail: "client socket auth".to_string(),
        metadata,
        summary: Some("auth".to_string()),
        body: None,
        display_area: msgpb::system_business_content::DisplayArea::DisplayPopup as i32,
        action_url: None,
        valid_from: None,
        valid_to: None,
    });
    content
}
