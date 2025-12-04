use std::time::Duration;

use flutter_rust_bridge::frb;
use log::{error, info, warn};

use crate::api::errors::ApiError;
use crate::api::login_api_types::*;
use crate::api::utils::post_request;
use crate::common::Db;
use crate::service;
use crate::service::{auth_service, socket_client::SocketClient, user_service::UserService};

#[frb]
/// 登录并等待 socket 连接及鉴权完成，超时可配置。
/// - 入参：登录请求与可选超时时间（秒）
/// - 流程：HTTP /login -> 本地落库 -> 等待 socket 鉴权成功
/// - 返回：登录结果（token、用户信息等）
pub fn login(payload: LoginRequest, timeout_secs: Option<u64>) -> Result<LoginResult, String> {
    let (result, _) = perform_login(&payload).map_err(|err| {
        error!("login_and_wait_for_socket: login failed: {}", err);
        err
    })?;
    let receiver = SocketClient::get().subscribe_connection_success();
    let duration = Duration::from_secs(timeout_secs.unwrap_or(30));
    receiver
        .recv_timeout(duration)
        .map_err(|_| ApiError::timeout("socket connection timeout").into_string())?;
    info!("socket 鉴权已完成");
    Ok(result)
}

fn reset_local_data_preserve_device() -> Result<(), String> {
    use crate::common::db;
    use rusqlite::params;

    let device_id = crate::api::config_api::get_device_id()?;
    let conn = db::connection()?;
    // 调试：输出当前配置数据库路径，便于确认使用的 SQLite 文件。
    info!("login: config db path={}", db::Db::get().path());

    let tables = [
        "friend",
        "friend_request",
        "chat_group",
        "group_member",
        "message",
        "conversation",
        "sync_state",
        "read_cursor",
        "user_info",
        "group_request",
    ];
    for table in tables {
        warn!("table {} ",table );
    }
    for table in tables {
        let _ = conn
            .execute(&format!("DELETE FROM {} ", table), params![])
            .map_err(|e| e.to_string())?;
    }
    // 重置自增计数，避免旧的会话/消息 ID 残留。
    let seq_reset_tables = [
        "friend",
        "friend_request",
        "group",
        "group_member",
        "message",
        "conversation",
        "group_request",
        "user_info",
    ];
    for table in seq_reset_tables {
        let _ = conn
            .execute(
                "DELETE FROM sqlite_sequence WHERE name = ?1",
                params![table],
            )
            .map_err(|e| e.to_string())?;
    }
    conn.execute("DELETE FROM config WHERE code != 'device_id'", params![])
        .map_err(|e| e.to_string())?;
    // 确保必要的初始行存在，并重置游标/会话数据。
    let _ = service::sync_state_service::SyncStateService::ensure_row();
    let _ = service::sync_state_service::SyncStateService::update_seqs(0, 0, 0);
    // 触发 device_id 生成/校验
    let _ = crate::api::config_api::get_device_id();
    Ok(())
}


#[frb]
/// 登出并清理登录态。
/// - 若未被动下线，先请求后端 /logout
/// - 断开 socket，清理本地状态
pub fn logout() -> Result<(), String> {
    // 若已收到被动下线通知，跳过远程 /logout，避免重复调用。
    let passive_logout = SocketClient::get().take_passive_logout_flag();
    if !passive_logout {
        if let Some(user) = UserService::get().latest_user()? {
            if let Some(token) = user.session_token {
                if !token.trim().is_empty() {
                    match post_request::<LogoutRequest, LogoutResult>(
                        "/logout",
                        &LogoutRequest { session_token: token },
                    ) {
                        Ok(resp) => {
                            if !resp.ok {
                                warn!("logout failed on server");
                            }
                        }
                        Err(err) => warn!("logout request error: {}", err),
                    }
                }
            }
        }
    }

    // 主动断开 socket 连接，避免残留后台线程。
    let _ = SocketClient::get().disconnect();

    auth_service::logout().map_err(|err| ApiError::system(err).into_string())
}

#[frb]
/// 校验会话 token 是否有效。
pub fn validate_session(
    payload: SessionValidateRequest,
) -> Result<SessionValidationResult, String> {
    post_request("/session/validate", &payload)
}

/// 调用登录接口并写入本地登录状态。
/// 返回登录结果以及 auth 消息 id（待用）
fn perform_login(payload: &LoginRequest) -> Result<(LoginResult, i64), String> {
    // 若本地已有成功登录过的用户，记录其 uid 用于后续校验。
    let previous_uid = UserService::get()
        .latest_user()
        .ok()
        .flatten()
        .map(|u| u.uid);

    // 调试：输出当前配置数据库路径，便于确认使用的 SQLite 文件。
    info!("login: config db path={}", crate::common::db::Db::get().path());

    let login_result = post_request::<LoginRequest, LoginResult>("/login", payload)?;

    // 登录成功后，如与本机已登录用户 uid 不同，则清理本地缓存数据（保留 device_id）。
    if let Some(uid) = previous_uid {
        if uid != login_result.uid {
            info!(
                "perform_login: uid changed on same device, clearing local cache prev_uid={} new_uid={}",
                uid, login_result.uid
            );
            let _ = reset_local_data_preserve_device();
        }
    }

    let auth_message_id = auth_service::handle_login(payload, &login_result)
        .map_err(|err| ApiError::system(err).into_string())?;
    Ok((login_result, auth_message_id))
}
