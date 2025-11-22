use serde::de::DeserializeOwned;
use serde::Serialize;

use crate::common::client;

/// 通用 POST 请求封装（不暴露给 Dart）。
pub(crate) fn post_request<TReq, TResp>(path: &str, body: &TReq) -> Result<TResp, String>
where
    TReq: Serialize + ?Sized,
    TResp: DeserializeOwned,
{
    client::with_app_api_client(|client| client.post_json(path, body))
}

/// 通用 GET 请求封装（不暴露给 Dart）。
pub(crate) fn get_request<TReq, TResp>(path: &str, params: &TReq) -> Result<TResp, String>
where
    TReq: Serialize + ?Sized,
    TResp: DeserializeOwned,
{
    client::with_app_api_client(|client| client.get_json(path, params))
}

/// 切换 app_api HTTP 客户端。
pub(crate) fn reload_http_client(base_url: String) -> Result<(), String> {
    client::reload_app_api_client(base_url)
}
