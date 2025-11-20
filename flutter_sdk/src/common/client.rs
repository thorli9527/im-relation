use crate::api::config_api;
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

pub fn with_app_api_client<T>(
    op: impl FnOnce(&AppApiHttpClient) -> Result<T, String>,
) -> Result<T, String> {
    let lock = APP_API_HTTP_CLIENT.get_or_try_init(|| {
        let base = resolve_app_api_base_url()?;
        let client = AppApiHttpClient::new(base)?;
        Ok::<_, String>(RwLock::new(client))
    })?;
    let guard = lock
        .read()
        .map_err(|_| "app_api http client lock poisoned".to_string())?;
    op(&guard)
}

pub(crate) fn reload_app_api_client(base_url: String) -> Result<(), String> {
    if let Some(cell) = APP_API_HTTP_CLIENT.get() {
        let mut guard = cell
            .write()
            .map_err(|_| "app_api http client lock poisoned".to_string())?;
        *guard = AppApiHttpClient::new(base_url)?;
        Ok(())
    } else {
        let client = AppApiHttpClient::new(base_url)?;
        APP_API_HTTP_CLIENT
            .set(RwLock::new(client))
            .map_err(|_| "app_api http client already initialized".to_string())
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
    fn new(base_url: String) -> Result<Self, String> {
        let client = HttpClient::builder()
            .timeout(Duration::from_secs(15))
            .build()
            .map_err(|err| format!("failed to create http client: {err}"))?;
        Ok(Self { client, base_url })
    }

    pub fn post_json<TReq, TResp>(&self, path: &str, body: &TReq) -> Result<TResp, String>
    where
        TReq: Serialize + ?Sized,
        TResp: DeserializeOwned,
    {
        let url = self.url(path);
        let body_text =
            to_string(body).unwrap_or_else(|_| "<failed to serialize request body>".to_string());
        let request = self
            .client
            .post(&url)
            .json(body)
            .build()
            .map_err(|err| format!("failed to build http request: {err}"))?;
        info!(
            "HTTP POST {} headers={:?} body={}",
            url,
            request.headers(),
            body_text
        );
        self.execute_request(request, "POST", &url)
    }

    pub fn get_json<TReq, TResp>(&self, path: &str, params: &TReq) -> Result<TResp, String>
    where
        TReq: Serialize + ?Sized,
        TResp: DeserializeOwned,
    {
        let url = self.url(path);
        let params_text =
            to_string(params).unwrap_or_else(|_| "<failed to serialize query params>".to_string());
        let request = self
            .client
            .get(&url)
            .query(params)
            .build()
            .map_err(|err| format!("failed to build http request: {err}"))?;
        info!(
            "HTTP GET {} headers={:?} params={}",
            url,
            request.headers(),
            params_text
        );
        self.execute_request(request, "GET", &url)
    }

    fn url(&self, path: &str) -> String {
        format!(
            "{}/{}",
            self.base_url.trim_end_matches('/'),
            path.trim_start_matches('/')
        )
    }

    fn execute_request<TResp>(
        &self,
        request: Request,
        method: &str,
        url: &str,
    ) -> Result<TResp, String>
    where
        TResp: DeserializeOwned,
    {
        let response = self
            .client
            .execute(request)
            .map_err(|err| format!("http request failed: {err}"))?;
        parse_api_response(response, method, url)
    }
}

fn parse_api_response<T: DeserializeOwned>(
    resp: Response,
    method: &str,
    url: &str,
) -> Result<T, String> {
    let status = resp.status();
    let headers = resp.headers().clone();
    let body = resp
        .text()
        .map_err(|err| format!("failed to read http response body: {err}"))?;
    info!(
        "HTTP {} {} -> {} headers={:?} body={}",
        method, url, status, headers, body
    );
    let api_response: ApiResponse<T> = serde_json::from_str(&body)
        .map_err(|err| format!("failed to parse http response: {err}, body={body}"))?;
    if api_response.code != 0 {
        let err_msg = format!(
            "http {} {} responded failure code={} message=\"{}\" status={} body={}",
            method, url, api_response.code, api_response.message, status, body
        );
        error!("{err_msg}");
        return Err(err_msg);
    }
    api_response.data.ok_or_else(|| {
        let err_msg = format!(
            "http {} {} missing data field status={} body={}",
            method, url, status, body
        );
        error!("{err_msg}");
        err_msg
    })
}
