use std::str::FromStr;

use flutter_rust_bridge::frb;
use reqwest::Url;
use uuid::Uuid;

use crate::api::{app_api, errors::ApiError};
use crate::api::utils::reload_http_client;
use crate::service::config_service::ConfigService;

pub const DEFAULT_APP_API_BASE_URL: &str = "http://127.0.0.1:8004";
pub(crate) const APP_API_BASE_URL_KEY: &str = "app_api_base_url";
pub const DEFAULT_SOCKET_RECONNECT_LIMIT: u32 = 10;
pub(crate) const SOCKET_RECONNECT_LIMIT_KEY: &str = "socket_reconnect_limit";
pub(crate) const SOCKET_RECONNECT_ATTEMPTS_KEY: &str = "socket_reconnect_attempts";
pub(crate) const SOCKET_RECONNECT_MESSAGE_KEY: &str = "socket_reconnect_message";
const TOKEN_KEY: &str = "session_token";
const TOKEN_EXPIRE_AT_KEY: &str = "session_token_expire_at";
const UID_KEY: &str = "session_uid";
const USERNAME_KEY: &str = "session_username";
const LOGIN_NAME_KEY: &str = "session_login_name";
const EMAIL_KEY: &str = "session_email";
const PHONE_KEY: &str = "session_phone";
const AVATAR_KEY: &str = "session_avatar";
const LAST_LOGIN_AT_KEY: &str = "session_last_login_at";
const LAST_ALIVE_AT_KEY: &str = "session_last_alive_at";

fn map_config_err(err: String) -> String {
    ApiError::system(err).into_string()
}

fn get_value(key: &str) -> Result<Option<String>, String> {
    ConfigService::get().get_value(key).map_err(map_config_err)
}

fn set_value(key: &str, value: impl AsRef<str>) -> Result<(), String> {
    ConfigService::get()
        .upsert_value(key, value.as_ref())
        .map_err(map_config_err)
}

fn set_numeric_value<T: ToString>(key: &str, value: T) -> Result<(), String> {
    let repr = value.to_string();
    set_value(key, &repr)
}

fn parse_value<T>(key: &str) -> Result<Option<T>, String>
where
    T: FromStr,
{
    Ok(get_value(key)?.and_then(|v| v.parse::<T>().ok()))
}

fn get_or_set_u32(key: &str, default: u32) -> Result<u32, String> {
    if let Some(value) = parse_value::<u32>(key)? {
        return Ok(value);
    }
    set_numeric_value(key, default)?;
    Ok(default)
}

fn get_or_generate_value(
    key: &str,
    generator: impl FnOnce() -> String,
) -> Result<String, String> {
    if let Some(value) = get_value(key)? {
        if !value.trim().is_empty() {
            return Ok(value);
        }
    }
    let generated = generator();
    set_value(key, &generated)?;
    Ok(generated)
}

/// 获取设备 ID（若无则自动生成并保存）。
#[frb]
pub fn get_device_id() -> Result<String, String> {
    get_or_generate_value("device_id", || Uuid::new_v4().to_string())
}


/// 获取应用版本号（用于展示）。
#[frb]
pub fn get_app_version() -> Result<Option<String>, String> {
    get_value("app_version")
}

/// 写入当前应用版本号。
#[frb]
pub fn set_app_version(version: String) -> Result<(), String> {
    set_value("app_version", &version)
}

#[frb]
pub fn get_app_api_base_url() -> Result<String, String> {
    get_app_api_base_url_internal()
}

#[frb]
pub fn set_app_api_base_url(base_url: String) -> Result<(), String> {
    let normalized = normalize_app_api_base_url(&base_url)?;
    set_value(APP_API_BASE_URL_KEY, &normalized)?;
    reload_http_client(normalized)
}

pub(crate) fn get_app_api_base_url_internal() -> Result<String, String> {
    if let Some(value) = get_value(APP_API_BASE_URL_KEY)? {
        if !value.trim().is_empty() {
            return Ok(value);
        }
    }
    Ok(DEFAULT_APP_API_BASE_URL.to_string())
}

pub(crate) fn ensure_app_api_base_url_initialized() -> Result<(), String> {
    if get_value(APP_API_BASE_URL_KEY)?.is_none() {
        set_value(APP_API_BASE_URL_KEY, DEFAULT_APP_API_BASE_URL)?;
    }
    Ok(())
}

pub(crate) fn normalize_app_api_base_url(input: &str) -> Result<String, String> {
    let trimmed = input.trim();
    if trimmed.is_empty() {
        return Err(ApiError::invalid_input("base url cannot be empty").into_string());
    }
    let candidate = if trimmed.contains("://") {
        trimmed.to_string()
    } else {
        format!("http://{}", trimmed)
    };
    let parsed = Url::parse(&candidate)
        .map_err(|err| ApiError::invalid_input(format!("invalid base url: {err}")).into_string())?;
    Ok(parsed.into_string().trim_end_matches('/').to_string())
}

fn ensure_limit_inner(limit: u32) -> Result<u32, String> {
    get_or_set_u32(SOCKET_RECONNECT_LIMIT_KEY, limit)
}

#[frb]
pub fn get_socket_reconnect_limit() -> Result<Option<u32>, String> {
    parse_value(SOCKET_RECONNECT_LIMIT_KEY)
}

#[frb]
pub fn set_socket_reconnect_limit(limit: u32) -> Result<(), String> {
    set_numeric_value(SOCKET_RECONNECT_LIMIT_KEY, limit)
}

#[frb]
pub fn ensure_socket_reconnect_limit() -> Result<u32, String> {
    ensure_limit_inner(DEFAULT_SOCKET_RECONNECT_LIMIT)
}

#[frb]
pub fn get_socket_reconnect_attempts() -> Result<Option<u32>, String> {
    parse_value(SOCKET_RECONNECT_ATTEMPTS_KEY)
}

#[frb]
pub fn set_socket_reconnect_attempts(attempts: u32) -> Result<(), String> {
    set_numeric_value(SOCKET_RECONNECT_ATTEMPTS_KEY, attempts)
}


#[frb]
pub fn set_socket_reconnect_message(message: String) -> Result<(), String> {
    set_value(SOCKET_RECONNECT_MESSAGE_KEY, &message)
}

#[frb]
pub fn get_socket_reconnect_message() -> Result<Option<String>, String> {
    get_value(SOCKET_RECONNECT_MESSAGE_KEY)
}


pub(crate) fn get_or_init_attempts(limit: u32) -> Result<u32, String> {
    get_or_set_u32(SOCKET_RECONNECT_ATTEMPTS_KEY, limit)
}

pub(crate) fn ensure_attempts(limit: u32) -> Result<u32, String> {
    get_or_init_attempts(limit)
}

// ===== 兼容旧登录态存取 =====
#[frb]
pub fn get_token() -> Result<Option<String>, String> {
    get_value(TOKEN_KEY)
}

#[frb]
pub fn set_token(token: String) -> Result<(), String> {
    set_value(TOKEN_KEY, token)
}

#[frb]
pub fn get_token_expire_at() -> Result<Option<i64>, String> {
    parse_value(TOKEN_EXPIRE_AT_KEY)
}

#[frb]
pub fn set_token_expire_at(expire_at: i64) -> Result<(), String> {
    set_numeric_value(TOKEN_EXPIRE_AT_KEY, expire_at)
}

#[frb]
pub fn get_uid() -> Result<Option<i64>, String> {
    parse_value(UID_KEY)
}

#[frb]
pub fn set_uid(uid: i64) -> Result<(), String> {
    set_numeric_value(UID_KEY, uid)
}

#[frb]
pub fn get_username() -> Result<Option<String>, String> {
    get_value(USERNAME_KEY)
}

#[frb]
pub fn set_username(name: String) -> Result<(), String> {
    set_value(USERNAME_KEY, name)
}

#[frb]
pub fn get_login_name() -> Result<Option<String>, String> {
    get_value(LOGIN_NAME_KEY)
}

#[frb]
pub fn set_login_name(name: String) -> Result<(), String> {
    set_value(LOGIN_NAME_KEY, name)
}

#[frb]
pub fn get_email() -> Result<Option<String>, String> {
    get_value(EMAIL_KEY)
}

#[frb]
pub fn set_email(email: String) -> Result<(), String> {
    set_value(EMAIL_KEY, email)
}

#[frb]
pub fn get_phone() -> Result<Option<String>, String> {
    get_value(PHONE_KEY)
}

#[frb]
pub fn set_phone(phone: String) -> Result<(), String> {
    set_value(PHONE_KEY, phone)
}

#[frb]
pub fn get_avatar() -> Result<Option<String>, String> {
    get_value(AVATAR_KEY)
}

#[frb]
pub fn set_avatar(avatar: String) -> Result<(), String> {
    set_value(AVATAR_KEY, avatar)
}

#[frb]
pub fn get_last_login_at() -> Result<Option<i64>, String> {
    parse_value(LAST_LOGIN_AT_KEY)
}

#[frb]
pub fn set_last_login_at(ts: i64) -> Result<(), String> {
    set_numeric_value(LAST_LOGIN_AT_KEY, ts)
}

#[frb]
pub fn get_last_alive_at() -> Result<Option<i64>, String> {
    parse_value(LAST_ALIVE_AT_KEY)
}

#[frb]
pub fn set_last_alive_at(ts: i64) -> Result<(), String> {
    set_numeric_value(LAST_ALIVE_AT_KEY, ts)
}
