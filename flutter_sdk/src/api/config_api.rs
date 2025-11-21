use std::str::FromStr;

use flutter_rust_bridge::frb;
use reqwest::Url;
use uuid::Uuid;

use crate::api::{app_api, errors::ApiError};
use crate::service::config_service::ConfigService;

pub const DEFAULT_APP_API_BASE_URL: &str = "http://127.0.0.1:8004";
pub(crate) const APP_API_BASE_URL_KEY: &str = "app_api_base_url";
pub const DEFAULT_SOCKET_RECONNECT_LIMIT: u32 = 10;
pub(crate) const SOCKET_RECONNECT_LIMIT_KEY: &str = "socket_reconnect_limit";
pub(crate) const SOCKET_RECONNECT_ATTEMPTS_KEY: &str = "socket_reconnect_attempts";
pub(crate) const SOCKET_RECONNECT_MESSAGE_KEY: &str = "socket_reconnect_message";

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

/// 读取上次登录使用的账号（可为空）。
#[frb]
pub fn get_login_name() -> Result<Option<String>, String> {
    get_value("login_name")
}

/// 更新登录账号。
#[frb]
pub fn set_login_name(login_name: String) -> Result<(), String> {
    set_value("login_name", &login_name)
}

/// 获取显示用的用户名。
#[frb]
pub fn get_username() -> Result<Option<String>, String> {
    get_value("username")
}

/// 设置显示用的用户名。
#[frb]
pub fn set_username(username: String) -> Result<(), String> {
    set_value("username", &username)
}

/// 获取绑定邮箱。
#[frb]
pub fn get_email() -> Result<Option<String>, String> {
    get_value("profile_email")
}

/// 设置绑定邮箱。
#[frb]
pub fn set_email(email: String) -> Result<(), String> {
    set_value("profile_email", &email)
}

/// 获取绑定手机号。
#[frb]
pub fn get_phone() -> Result<Option<String>, String> {
    get_value("profile_phone")
}

/// 设置绑定手机号。
#[frb]
pub fn set_phone(phone: String) -> Result<(), String> {
    set_value("profile_phone", &phone)
}

/// 获取头像地址。
#[frb]
pub fn get_avatar() -> Result<Option<String>, String> {
    get_value("profile_avatar")
}

/// 设置头像地址。
#[frb]
pub fn set_avatar(avatar: String) -> Result<(), String> {
    set_value("profile_avatar", &avatar)
}

/// 获取登录 token。
#[frb]
pub fn get_token() -> Result<Option<String>, String> {
    get_value("token")
}

/// 写入登录 token。
#[frb]
pub fn set_token(token: String) -> Result<(), String> {
    set_value("token", &token)
}

/// 获取 token 失效时间（Unix 秒）。
#[frb]
pub fn get_token_expire_at() -> Result<Option<i64>, String> {
    parse_value("token_expire_at")
}

/// 设置 token 失效时间（Unix 秒）。
#[frb]
pub fn set_token_expire_at(expire_at: i64) -> Result<(), String> {
    set_numeric_value("token_expire_at", expire_at)
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

/// 获取当前登录的 UID。
#[frb]
pub fn get_uid() -> Result<Option<i64>, String> {
    parse_value("uid")
}

/// 设置当前登录的用户 ID。
#[frb]
pub fn set_uid(uid: i64) -> Result<(), String> {
    set_numeric_value("uid", uid)
}

/// 获取最后一次成功登录时间（Unix 秒）。
#[frb]
pub fn get_last_login_at() -> Result<Option<i64>, String> {
    parse_value("last_login_at")
}

/// 设置最后一次成功登录时间（Unix 秒）。
#[frb]
pub fn set_last_login_at(timestamp: i64) -> Result<(), String> {
    set_numeric_value("last_login_at", timestamp)
}

/// 获取客户端最后一次心跳/存活时间（Unix 秒）。
#[frb]
pub fn get_last_alive_at() -> Result<Option<i64>, String> {
    parse_value("last_alive_at")
}

/// 更新客户端最后一次心跳/存活时间（Unix 秒）。
#[frb]
pub fn set_last_alive_at(timestamp: i64) -> Result<(), String> {
    set_numeric_value("last_alive_at", timestamp)
}

#[frb]
pub fn get_app_api_base_url() -> Result<String, String> {
    get_app_api_base_url_internal()
}

#[frb]
pub fn set_app_api_base_url(base_url: String) -> Result<(), String> {
    let normalized = normalize_app_api_base_url(&base_url)?;
    set_value(APP_API_BASE_URL_KEY, &normalized)?;
    app_api::reload_http_client(normalized)
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

pub(crate) fn get_or_init_attempts(limit: u32) -> Result<u32, String> {
    get_or_set_u32(SOCKET_RECONNECT_ATTEMPTS_KEY, limit)
}

pub(crate) fn ensure_attempts(limit: u32) -> Result<u32, String> {
    get_or_init_attempts(limit)
}

#[frb]
pub fn set_socket_reconnect_message(message: String) -> Result<(), String> {
    set_value(SOCKET_RECONNECT_MESSAGE_KEY, &message)
}

#[frb]
pub fn get_socket_reconnect_message() -> Result<Option<String>, String> {
    get_value(SOCKET_RECONNECT_MESSAGE_KEY)
}
