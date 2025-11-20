use flutter_rust_bridge::frb;
use reqwest::Url;
use uuid::Uuid;

use crate::api::app_api;
use crate::service::config_service::ConfigService;

pub const DEFAULT_APP_API_BASE_URL: &str = "http://127.0.0.1:8004";
pub(crate) const APP_API_BASE_URL_KEY: &str = "app_api_base_url";
pub const DEFAULT_SOCKET_RECONNECT_LIMIT: u32 = 10;
pub(crate) const SOCKET_RECONNECT_LIMIT_KEY: &str = "socket_reconnect_limit";
pub(crate) const SOCKET_RECONNECT_ATTEMPTS_KEY: &str = "socket_reconnect_attempts";
pub(crate) const SOCKET_RECONNECT_MESSAGE_KEY: &str = "socket_reconnect_message";

/// 获取设备 ID（若无则自动生成并保存）。
#[frb]
pub fn get_device_id() -> Result<String, String> {
    let service = ConfigService::get();
    if let Some(val) = service.get_value("device_id")? {
        return Ok(val);
    }
    let device_id = Uuid::new_v4().to_string();
    service.upsert_value("device_id", &device_id)?;
    Ok(device_id)
}

/// 读取上次登录使用的账号（可为空）。
#[frb]
pub fn get_login_name() -> Result<Option<String>, String> {
    ConfigService::get().get_value("login_name")
}

/// 更新登录账号。
#[frb]
pub fn set_login_name(login_name: String) -> Result<(), String> {
    ConfigService::get().upsert_value("login_name", &login_name)
}

/// 获取显示用的用户名。
#[frb]
pub fn get_username() -> Result<Option<String>, String> {
    ConfigService::get().get_value("username")
}

/// 设置显示用的用户名。
#[frb]
pub fn set_username(username: String) -> Result<(), String> {
    ConfigService::get().upsert_value("username", &username)
}

/// 获取绑定邮箱。
#[frb]
pub fn get_email() -> Result<Option<String>, String> {
    ConfigService::get().get_value("profile_email")
}

/// 设置绑定邮箱。
#[frb]
pub fn set_email(email: String) -> Result<(), String> {
    ConfigService::get().upsert_value("profile_email", &email)
}

/// 获取绑定手机号。
#[frb]
pub fn get_phone() -> Result<Option<String>, String> {
    ConfigService::get().get_value("profile_phone")
}

/// 设置绑定手机号。
#[frb]
pub fn set_phone(phone: String) -> Result<(), String> {
    ConfigService::get().upsert_value("profile_phone", &phone)
}

/// 获取头像地址。
#[frb]
pub fn get_avatar() -> Result<Option<String>, String> {
    ConfigService::get().get_value("profile_avatar")
}

/// 设置头像地址。
#[frb]
pub fn set_avatar(avatar: String) -> Result<(), String> {
    ConfigService::get().upsert_value("profile_avatar", &avatar)
}

/// 获取登录 token。
#[frb]
pub fn get_token() -> Result<Option<String>, String> {
    ConfigService::get().get_value("token")
}

/// 写入登录 token。
#[frb]
pub fn set_token(token: String) -> Result<(), String> {
    ConfigService::get().upsert_value("token", &token)
}

/// 获取 token 失效时间（Unix 秒）。
#[frb]
pub fn get_token_expire_at() -> Result<Option<i64>, String> {
    Ok(ConfigService::get()
        .get_value("token_expire_at")?
        .and_then(|v| v.parse::<i64>().ok()))
}

/// 设置 token 失效时间（Unix 秒）。
#[frb]
pub fn set_token_expire_at(expire_at: i64) -> Result<(), String> {
    ConfigService::get().upsert_value("token_expire_at", &expire_at.to_string())
}

/// 获取应用版本号（用于展示）。
#[frb]
pub fn get_app_version() -> Result<Option<String>, String> {
    ConfigService::get().get_value("app_version")
}

/// 写入当前应用版本号。
#[frb]
pub fn set_app_version(version: String) -> Result<(), String> {
    ConfigService::get().upsert_value("app_version", &version)
}

/// 获取当前登录的 UID。
#[frb]
pub fn get_uid() -> Result<Option<i64>, String> {
    Ok(ConfigService::get()
        .get_value("uid")?
        .and_then(|v| v.parse::<i64>().ok()))
}

/// 设置当前登录的用户 ID。
#[frb]
pub fn set_uid(uid: i64) -> Result<(), String> {
    ConfigService::get().upsert_value("uid", &uid.to_string())
}

/// 获取最后一次成功登录时间（Unix 秒）。
#[frb]
pub fn get_last_login_at() -> Result<Option<i64>, String> {
    Ok(ConfigService::get()
        .get_value("last_login_at")?
        .and_then(|v| v.parse::<i64>().ok()))
}

/// 设置最后一次成功登录时间（Unix 秒）。
#[frb]
pub fn set_last_login_at(timestamp: i64) -> Result<(), String> {
    ConfigService::get().upsert_value("last_login_at", &timestamp.to_string())
}

/// 获取客户端最后一次心跳/存活时间（Unix 秒）。
#[frb]
pub fn get_last_alive_at() -> Result<Option<i64>, String> {
    Ok(ConfigService::get()
        .get_value("last_alive_at")?
        .and_then(|v| v.parse::<i64>().ok()))
}

/// 更新客户端最后一次心跳/存活时间（Unix 秒）。
#[frb]
pub fn set_last_alive_at(timestamp: i64) -> Result<(), String> {
    ConfigService::get().upsert_value("last_alive_at", &timestamp.to_string())
}

#[frb]
pub fn get_app_api_base_url() -> Result<String, String> {
    get_app_api_base_url_internal()
}

#[frb]
pub fn set_app_api_base_url(base_url: String) -> Result<(), String> {
    let normalized = normalize_app_api_base_url(&base_url)?;
    ConfigService::get().upsert_value(APP_API_BASE_URL_KEY, &normalized)?;
    app_api::reload_http_client(normalized)
}

pub(crate) fn get_app_api_base_url_internal() -> Result<String, String> {
    if let Some(value) = ConfigService::get().get_value(APP_API_BASE_URL_KEY)? {
        if !value.trim().is_empty() {
            return Ok(value);
        }
    }
    Ok(DEFAULT_APP_API_BASE_URL.to_string())
}

pub(crate) fn ensure_app_api_base_url_initialized() -> Result<(), String> {
    if ConfigService::get()
        .get_value(APP_API_BASE_URL_KEY)?
        .is_none()
    {
        ConfigService::get().upsert_value(APP_API_BASE_URL_KEY, DEFAULT_APP_API_BASE_URL)?;
    }
    Ok(())
}

pub(crate) fn normalize_app_api_base_url(input: &str) -> Result<String, String> {
    let trimmed = input.trim();
    if trimmed.is_empty() {
        return Err("base url cannot be empty".into());
    }
    let candidate = if trimmed.contains("://") {
        trimmed.to_string()
    } else {
        format!("http://{}", trimmed)
    };
    let parsed = Url::parse(&candidate).map_err(|err| format!("invalid base url: {err}"))?;
    let mut normalized = parsed.into_string();
    while normalized.ends_with('/') {
        normalized.pop();
    }
    Ok(normalized)
}

fn parse_u32(value: &str) -> Option<u32> {
    value.parse::<u32>().ok()
}

fn ensure_limit_inner(limit: u32) -> Result<u32, String> {
    if let Some(current) = ConfigService::get().get_value(SOCKET_RECONNECT_LIMIT_KEY)? {
        if let Some(parsed) = parse_u32(&current) {
            return Ok(parsed);
        }
    }
    set_socket_reconnect_limit(limit)?;
    Ok(limit)
}

#[frb]
pub fn get_socket_reconnect_limit() -> Result<Option<u32>, String> {
    Ok(ConfigService::get()
        .get_value(SOCKET_RECONNECT_LIMIT_KEY)?
        .and_then(|v| parse_u32(&v)))
}

#[frb]
pub fn set_socket_reconnect_limit(limit: u32) -> Result<(), String> {
    ConfigService::get().upsert_value(SOCKET_RECONNECT_LIMIT_KEY, &limit.to_string())
}

#[frb]
pub fn ensure_socket_reconnect_limit() -> Result<u32, String> {
    ensure_limit_inner(DEFAULT_SOCKET_RECONNECT_LIMIT)
}

#[frb]
pub fn get_socket_reconnect_attempts() -> Result<Option<u32>, String> {
    Ok(ConfigService::get()
        .get_value(SOCKET_RECONNECT_ATTEMPTS_KEY)?
        .and_then(|v| parse_u32(&v)))
}

#[frb]
pub fn set_socket_reconnect_attempts(attempts: u32) -> Result<(), String> {
    ConfigService::get().upsert_value(SOCKET_RECONNECT_ATTEMPTS_KEY, &attempts.to_string())
}

pub(crate) fn get_or_init_attempts(limit: u32) -> Result<u32, String> {
    if let Some(current) = get_socket_reconnect_attempts()? {
        return Ok(current);
    }
    set_socket_reconnect_attempts(limit)?;
    Ok(limit)
}

pub(crate) fn ensure_attempts(limit: u32) -> Result<u32, String> {
    get_or_init_attempts(limit)
}

#[frb]
pub fn set_socket_reconnect_message(message: String) -> Result<(), String> {
    ConfigService::get().upsert_value(SOCKET_RECONNECT_MESSAGE_KEY, &message)
}

#[frb]
pub fn get_socket_reconnect_message() -> Result<Option<String>, String> {
    ConfigService::get().get_value(SOCKET_RECONNECT_MESSAGE_KEY)
}
