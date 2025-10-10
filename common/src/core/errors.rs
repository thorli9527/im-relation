//! 应用层错误定义与 HTTP 映射，统一对外响应格式。

use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::Json;
use log::error;
use serde::Serialize;
use std::io;
use thiserror::Error;
/// HTTP 错误响应结构
#[derive(Serialize)]
struct ErrorResponse {
    code: u16,
    message: String,
}

/// 应用错误类型
#[derive(Debug, Error)]
pub enum AppError {
    // ==== 常规业务错误 ====
    #[error("Resource not found")]
    NotFound,

    #[error("Bad request: {0}")]
    Validation(String),

    #[error("Unauthorized access")]
    Unauthorized(String),
    #[error("biz error: {0}")]
    BizError(String),

    #[error("Forbidden access")]
    Forbidden,

    #[error("Conflict: resource already exists")]
    Conflict,

    #[error("Too many requests")]
    RateLimited,

    #[error("File upload failed: {0}")]
    FileUpload(String),

    #[error("External API call failed: {0}")]
    ExternalApi(String),
    #[error("Redis pool error: {0}")]
    // ==== 系统错误 ====
    Json(#[from] serde_json::Error),
    #[error("IO error: {0}")]
    Io(#[from] io::Error),
    #[error("socket: {0}")]
    SocketError(String),
    #[error("Internal server error")]
    Internal(String),
    #[error("Conversion error")]
    ConversionError,
}
impl From<anyhow::Error> for AppError {
    fn from(e: anyhow::Error) -> Self {
        AppError::Internal(e.to_string())
    }
}
impl From<validator::ValidationErrors> for AppError {
    fn from(e: validator::ValidationErrors) -> Self {
        AppError::BizError(format!("参数验证失败: {}", e))
    }
}
impl AppError {
    /// 将错误分类映射到 HTTP 状态码与响应消息，必要时记录日志供排查。
    fn status_and_message(&self) -> (StatusCode, String) {
        match self {
            // 资源不存在直接返回 404。
            AppError::NotFound => (StatusCode::NOT_FOUND, self.to_string()),
            // 类型转换错误属于服务内部问题。
            AppError::ConversionError => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
            // 参数校验失败，返回 400。
            AppError::Validation(_) => (StatusCode::BAD_REQUEST, self.to_string()),
            // 鉴权失败保留原始提示。
            AppError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, msg.to_string()),
            // 无权限访问。
            AppError::Forbidden => (StatusCode::FORBIDDEN, self.to_string()),
            // 资源冲突或重复。
            AppError::Conflict => (StatusCode::CONFLICT, self.to_string()),
            // 速率限制命中。
            AppError::RateLimited => (StatusCode::TOO_MANY_REQUESTS, self.to_string()),
            AppError::FileUpload(_) | AppError::ExternalApi(_) => {
                (StatusCode::BAD_GATEWAY, self.to_string())
            }
            AppError::Io(e) => {
                // IO 错误多为环境问题，打印详细日志。
                error!("IO error: {e:?}");
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Service error".to_string(),
                )
            }
            AppError::Json(e) => {
                // JSON 序列化失败同样视为内部错误。
                error!("JSON error: {e:?}");
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Service error".to_string(),
                )
            }
            AppError::Internal(e) => {
                // 显式上报内部错误，以便观察。
                error!("Internal error: {e:?}");
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Service error".to_string(),
                )
            }
            AppError::BizError(e) => {
                // 业务错误保留原始文案，状态码仍然 500 以提示调用方关注。
                error!("Biz error: {e:?}");
                (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
            }
            other => {
                // 兜底分支防止遗漏，记录类型。
                error!("Unhandled error: {other:?}");
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Service error".to_string(),
                )
            }
        }
    }
}

impl IntoResponse for AppError {
    /// 便捷地把业务错误转成 axum 可返回的响应体。
    fn into_response(self) -> Response {
        // 先获取 HTTP 状态码与展示文案。
        let (status, message) = self.status_and_message();
        // 构造标准化的 JSON 错误体。
        let body = Json(ErrorResponse {
            code: status.as_u16(),
            message,
        });
        // 将状态码与 JSON 组合为最终响应。
        (status, body).into_response()
    }
}
