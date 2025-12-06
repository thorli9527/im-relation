use crate::api::{config_api, errors::ApiError};
use log::{error, info};
use once_cell::sync::OnceCell;
use reqwest::blocking::{Client as HttpClient, Request, Response};
use serde::{de::DeserializeOwned, Deserialize, Serialize};
use serde_json::to_string;
use std::{env, sync::RwLock, time::Duration};

static APP_API_HTTP_CLIENT: OnceCell<RwLock<AppApiHttpClient>> = OnceCell::new();

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ApiResponse<T> {
    pub code: i32,
    pub message: String,
    pub data: Option<T>,
}

/// 统一入口：获取全局 HTTP 客户端并执行操作，自动处理初始化和锁错误。
pub fn with_app_api_client<T>(
    op: impl FnOnce(&AppApiHttpClient) -> Result<T, ApiError>,
) -> Result<T, String> {
    let lock = APP_API_HTTP_CLIENT.get_or_try_init(|| {
        let base = resolve_app_api_base_url()
            .map_err(|err| ApiError::from_serialized(err).into_string())?;
        let client = AppApiHttpClient::new(base).map_err(ApiError::into_string)?;
        Ok::<_, String>(RwLock::new(client))
    })?;
    let guard = lock
        .read()
        .map_err(|_| ApiError::concurrency("app_api http client lock poisoned").into_string())?;
    op(&guard).map_err(ApiError::into_string)
}

pub(crate) fn reload_app_api_client(base_url: String) -> Result<(), String> {
    if let Some(cell) = APP_API_HTTP_CLIENT.get() {
        let mut guard = cell.write().map_err(|_| {
            ApiError::concurrency("app_api http client lock poisoned").into_string()
        })?;
        *guard = AppApiHttpClient::new(base_url).map_err(ApiError::into_string)?;
        Ok(())
    } else {
        let client = AppApiHttpClient::new(base_url).map_err(ApiError::into_string)?;
        APP_API_HTTP_CLIENT.set(RwLock::new(client)).map_err(|_| {
            ApiError::concurrency("app_api http client already initialized").into_string()
        })
    }
}

pub fn resolve_app_api_base_url() -> Result<String, String> {
    if let Ok(value) = env::var("APP_API_HTTP_BASE") {
        if !value.trim().is_empty() {
            return config_api::normalize_app_api_base_url(&value);
        }
    }
    config_api::get_app_api_base_url_internal()
}

pub struct AppApiHttpClient {
    client: HttpClient,
    base_url: String,
}

impl AppApiHttpClient {
    /// 创建带超时的 blocking reqwest 客户端。
    fn new(base_url: String) -> Result<Self, ApiError> {
        let client = HttpClient::builder()
            .timeout(Duration::from_secs(15))
            .build()
            .map_err(|err| ApiError::io(format!("failed to create http client: {err}")))?;
        Ok(Self { client, base_url })
    }

    /// 发送 JSON POST，并统一记录日志与错误转换。
    pub fn post_json<TReq, TResp>(&self, path: &str, body: &TReq) -> Result<TResp, ApiError>
    where
        TReq: Serialize + ?Sized,
        TResp: DeserializeOwned,
    {
        let url = self.url(path);
        let body_text =
            to_string(body).unwrap_or_else(|_| "<failed to serialize request body>".to_string());
        let request = self.client.post(&url).json(body).build().map_err(|err| {
            ApiError::invalid_input(format!("failed to build http request: {err}"))
        })?;
        info!(
            "HTTP POST {} headers={:?} body={}",
            url,
            request.headers(),
            body_text
        );
        self.execute_request(request, "POST", &url)
    }

    /// 发送 JSON GET，自动拼装查询参数与日志。
    pub fn get_json<TReq, TResp>(&self, path: &str, params: &TReq) -> Result<TResp, ApiError>
    where
        TReq: Serialize + ?Sized,
        TResp: DeserializeOwned,
    {
        let url = self.url(path);
        let params_text =
            to_string(params).unwrap_or_else(|_| "<failed to serialize query params>".to_string());
        let request = self.client.get(&url).query(params).build().map_err(|err| {
            ApiError::invalid_input(format!("failed to build http request: {err}"))
        })?;
        info!(
            "HTTP GET {} headers={:?} params={}",
            url,
            request.headers(),
            params_text
        );
        self.execute_request(request, "GET", &url)
    }

    /// 拼装完整 URL，处理首尾斜杠。
    fn url(&self, path: &str) -> String {
        format!(
            "{}/{}",
            self.base_url.trim_end_matches('/'),
            path.trim_start_matches('/')
        )
    }

    /// 执行请求并按错误类型分类。
    fn execute_request<TResp>(
        &self,
        request: Request,
        method: &str,
        url: &str,
    ) -> Result<TResp, ApiError>
    where
        TResp: DeserializeOwned,
    {
        let req_headers = request.headers().clone();
        let response = self
            .client
            .execute(request)
            .map_err(|err| map_reqwest_error(err, method, url))?;
        parse_api_response(response, method, url, req_headers)
    }
}

fn parse_api_response<T: DeserializeOwned>(
    resp: Response,
    method: &str,
    url: &str,
    req_headers: reqwest::header::HeaderMap,
) -> Result<T, ApiError> {
    let status = resp.status();
    let headers = resp.headers().clone();
    let body = resp
        .text()
        .map_err(|err| ApiError::io(format!("failed to read http response body: {err}")))?;
    info!(
        "HTTP {} {} -> {} headers={:?} body={}",
        method, url, status, headers, body
    );
    if !status.is_success() {
        let err_msg = format!(
            "http {} {} failed with status={} body={} req_headers={:?}",
            method, url, status, body, req_headers
        );
        error!("{err_msg}");
        return Err(ApiError::http_status(status.as_u16(), err_msg));
    }
    let api_response: ApiResponse<T> = serde_json::from_str(&body).map_err(|err| {
        ApiError::parse(format!("failed to parse http response: {err}, body={body}"))
    })?;
    if api_response.code != 0 {
        let err_msg = format!(
            "http {} {} responded failure code={} message=\"{}\" status={} body={} req_headers={:?}",
            method, url, api_response.code, api_response.message, status, body, req_headers
        );
        error!("{err_msg}");
        return Err(ApiError::backend(
            api_response.code,
            api_response.message,
            Some(status.as_u16()),
        ));
    }
    api_response.data.ok_or_else(|| {
        ApiError::parse(format!(
            "http {} {} missing data field status={} body={}",
            method, url, status, body
        ))
    })
}

fn map_reqwest_error(err: reqwest::Error, method: &str, url: &str) -> ApiError {
    if err.is_timeout() {
        return ApiError::timeout(format!("http {} {} timed out: {err}", method, url));
    }
    if err.is_connect() {
        return ApiError::network(format!("http {} {} connection error: {err}", method, url));
    }
    if err.is_request() {
        return ApiError::invalid_input(format!("http {} {} request error: {err}", method, url));
    }
    if err.is_body() || err.is_decode() {
        return ApiError::parse(format!("http {} {} body error: {err}", method, url));
    }
    ApiError::io(format!("http {} {} failed: {err}", method, url))
}
