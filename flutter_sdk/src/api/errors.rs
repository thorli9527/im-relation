use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

/// 面向 Flutter 暴露的错误种类，便于按网络/超时/系统等维度区分。
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum ApiErrorKind {
    Network,
    Timeout,
    Io,
    System,
    HttpStatus,
    Backend,
    Parse,
    InvalidInput,
    Concurrency,
    Unknown,
}

/// 结构化错误，包含类别、HTTP 状态码、业务码，便于 Dart 侧统一解析。
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ApiError {
    pub kind: ApiErrorKind,
    pub message: String,
    pub status: Option<u16>,
    pub code: Option<i32>,
}

pub type ApiResult<T> = Result<T, ApiError>;

impl ApiError {
    /// 网络连接类错误（DNS/连接被拒等）。
    pub fn network(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::Network,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// 请求超时错误。
    pub fn timeout(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::Timeout,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// 本地 IO 错误（读写文件/创建 client 失败等）。
    pub fn io(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::Io,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// 系统/内部错误（数据库、线程等）。
    pub fn system(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::System,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// HTTP 状态非 2xx 的错误。
    pub fn http_status(status: u16, message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::HttpStatus,
            message: message.into(),
            status: Some(status),
            code: None,
        }
    }

    /// 后端业务码异常（code != 0）。
    pub fn backend(code: i32, message: impl Into<String>, status: Option<u16>) -> Self {
        Self {
            kind: ApiErrorKind::Backend,
            message: message.into(),
            status,
            code: Some(code),
        }
    }

    /// 序列化/反序列化错误。
    pub fn parse(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::Parse,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// 入参不合法构造。
    pub fn invalid_input(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::InvalidInput,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// 并发控制错误（锁中毒/重复初始化）。
    pub fn concurrency(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::Concurrency,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// 兜底未知错误。
    pub fn unknown(message: impl Into<String>) -> Self {
        Self {
            kind: ApiErrorKind::Unknown,
            message: message.into(),
            status: None,
            code: None,
        }
    }

    /// 序列化错误对象到字符串，Flutter 通过 JSON 解析 kind/status/code。
    pub fn into_string(self) -> String {
        serde_json::to_string(&self).unwrap_or_else(|_| {
            serde_json::to_string(&ApiError::unknown(self.message)).unwrap_or_else(|_| {
                "{\"kind\":\"unknown\",\"message\":\"serialization failed\"}".to_string()
            })
        })
    }

    /// 将字符串形式的错误还原为 ApiError，异常时降级为 unknown。
    pub fn from_serialized(error: String) -> Self {
        serde_json::from_str(&error).unwrap_or_else(|_| ApiError::unknown(error))
    }
}

/// Helper for the Dart side to decode the structured error string.
#[frb]
pub fn parse_api_error(error: String) -> ApiError {
    ApiError::from_serialized(error)
}
