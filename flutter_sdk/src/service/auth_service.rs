use std::time::{SystemTime, UNIX_EPOCH};

use crate::{
    api::app_api::{LoginRequest, LoginResult},
    api::sync_api::{sync_messages, SyncRequest},
    domain::{MessageEntity, MessageScene, MessageSource},
    generated::message::DeviceType as SocketDeviceType,
    service::message_service::MessageService,
    service::socket_client::{SocketClient, SocketConfig},
    service::sync_state_service::SyncStateService,
    service::user_service::UserService as LocalUserService,
};
use base64::engine::general_purpose::STANDARD as BASE64;
use base64::Engine as _;
use prost::Message as ProstMessage;

pub fn handle_login(payload: &LoginRequest, result: &LoginResult) -> Result<i64, String> {
    // let validation = app_api::validate_session(SessionValidateRequest {
    //     session_token: result.token.clone(),
    // })?;
    // if !validation.ok {
    //     return Err("session validation failed".into());
    // }

    // Socket 鉴权所需的设备类型，默认 Unknown 防御。
    let device_type =
        SocketDeviceType::from_i32(payload.device_type).unwrap_or(SocketDeviceType::Unknown);

    // 如果本地已有缓存用户且 uid 不一致，清理本地数据（保留 device_id）
    if let Ok(Some(local)) = LocalUserService::get().latest_user() {
        if local.uid != result.uid {
            let _ = crate::api::app_api::reset_local_data_preserve_device();
        }
    }

    // 缓存当前用户资料到本地 user_info 表，便于会话/好友展示。
    LocalUserService::get().upsert_from_login(result)?;
    // 拉取增量消息并更新游标（仅更新游标，不在此落库）
    if let Ok(state) = SyncStateService::fetch() {
        let req = SyncRequest {
            session_token: result.token.clone(),
            friend_last_seq: Some(state.friend_last_seq),
            group_last_seq: Some(state.group_last_seq),
            system_last_seq: Some(state.system_last_seq as u64),
            limit: Some(200),
        };
        if let Ok(resp) = sync_messages(&req) {
            // 简单策略：更新游标到当前时间戳/最大 message_id，具体消费交由上层处理。
            let now_ms = current_secs() * 1000;
            let max_system = resp
                .system_messages
                .iter()
                .filter_map(|_| None::<u64>) // 无法解码 message_id，这里仅兜底为当前时间戳
                .max()
                .unwrap_or(now_ms as u64);
            let _ = SyncStateService::update_seqs(now_ms, now_ms, max_system as i64);
            // TODO: 把 base64 payload 交给上层解码入库。
        }
    }

    let socket_config = SocketConfig {
        socket_addr: result.socket_addr.clone(),
        uid: result.uid,
        device_type,
        device_id: payload.device_id.clone(),
        token: result.token.clone(),
        heartbeat_secs: 60,
    };
    // 建立 socket 连接，后续消息实时同步。
    SocketClient::get().connect(socket_config)?;

    // 同步增量消息并更新游标
    let _ = crate::service::sync_service::sync_incremental(&result.token);
    Ok(0)
}

/// 主动断开 socket 并返回。
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

fn persist_message(content: &crate::generated::message::Content) -> Result<(), String> {
    // 将服务端下发的消息按原 protobuf base64 落库，留给上层解码展示。
    let svc = MessageService::get();
    let entity = MessageEntity {
        id: None,
        conversation_id: content.receiver_id,
        scene: MessageScene::from(content.scene as i64),
        receiver_id: Some(content.receiver_id),
        sender_type: 1,
        sender_id: content.sender_id,
        is_session_message: true,
        is_chat_message: true,
        // 暂存原始 protobuf base64，便于上层解码展示
        content: serde_json::json!({
            "protobuf": BASE64.encode({
                let mut b = Vec::new();
                let _ = content.encode(&mut b);
                b
            })
        }),
        extra: String::new(),
        created_at: content.timestamp,
        data_source: MessageSource::Server,
        sending_status: true,
        ack_status: true,
        send_count: 0,
    };
    svc.insert(&entity)?;
    Ok(())
}
