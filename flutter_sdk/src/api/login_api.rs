use std::time::Duration;

use flutter_rust_bridge::frb;
use log::{error, info, warn};

use crate::api::errors::ApiError;
use crate::api::login_api_types::*;
use crate::api::utils::post_request;
use crate::service::{auth_service, socket_client::SocketClient, user_service::UserService};

#[frb]
/// 登录并等待 socket 连接及鉴权完成，超时可配置。
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

#[frb]
/// 登出并清理登录态。
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
fn perform_login(payload: &LoginRequest) -> Result<(LoginResult, i64), String> {
    let login_result = post_request::<LoginRequest, LoginResult>("/login", payload)?;
    let auth_message_id = auth_service::handle_login(payload, &login_result)
        .map_err(|err| ApiError::system(err).into_string())?;
    Ok((login_result, auth_message_id))
}
