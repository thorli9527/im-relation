use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use reqwest::Client;
use serde::de::DeserializeOwned;

use super::{BaseRequest, CommonResp, NodeInfo, NodeInfoList, QueryNodeReq, RegisterRequest};
use crate::arb::ACCESS_HEADER;

#[derive(Clone)]
pub struct ArbHttpClient {
    base_url: String,
    access_token: Option<String>,
    client: Client,
}

impl ArbHttpClient {
    pub fn new(addr: impl Into<String>, access_token: Option<String>) -> Result<Self> {
        let addr = addr.into();
        let base_url = if addr.starts_with("http://") || addr.starts_with("https://") {
            addr
        } else {
            format!("http://{}", addr)
        };

        let client = Client::builder()
            .connect_timeout(Duration::from_secs(5))
            .build()
            .context("build reqwest client")?;

        Ok(Self {
            base_url,
            access_token,
            client,
        })
    }

    pub async fn register_node(&self, payload: &RegisterRequest) -> Result<CommonResp> {
        self.post("/arb/server/register", payload).await
    }

    pub async fn heartbeat(&self, payload: &BaseRequest) -> Result<CommonResp> {
        self.post("/arb/server/heartbeat", payload).await
    }

    pub async fn update_shard_state(&self, payload: &BaseRequest) -> Result<CommonResp> {
        self.post("/arb/server/update-shard", payload).await
    }

    pub async fn graceful_leave(&self, payload: &NodeInfo) -> Result<CommonResp> {
        self.post("/arb/server/graceful-leave", payload).await
    }

    pub async fn list_all_nodes(&self, payload: &QueryNodeReq) -> Result<NodeInfoList> {
        self.post("/arb/server/list", payload).await
    }

    async fn post<T, R>(&self, path: &str, body: &T) -> Result<R>
    where
        T: serde::Serialize + ?Sized,
        R: DeserializeOwned,
    {
        let url = format!("{}{}", self.base_url, path);
        let mut request = self.client.post(&url).json(body);
        if let Some(token) = &self.access_token {
            request = request.header(ACCESS_HEADER, token);
        }
        let response = request.send().await.context("send arb request")?;
        if !response.status().is_success() {
            let status = response.status();
            let text = response
                .text()
                .await
                .unwrap_or_else(|_| "<empty>".to_string());
            return Err(anyhow!(
                "arb request failed: status={} body={}",
                status,
                text
            ));
        }
        response.json::<R>().await.context("decode arb response")
    }
}
