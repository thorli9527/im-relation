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
    fn status_and_message(&self) -> (StatusCode, String) {
        match self {
            AppError::NotFound => (StatusCode::NOT_FOUND, self.to_string()),
            AppError::ConversionError => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
            AppError::Validation(_) => (StatusCode::BAD_REQUEST, self.to_string()),
            AppError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, msg.to_string()),
            AppError::Forbidden => (StatusCode::FORBIDDEN, self.to_string()),
            AppError::Conflict => (StatusCode::CONFLICT, self.to_string()),
            AppError::RateLimited => (StatusCode::TOO_MANY_REQUESTS, self.to_string()),
            AppError::FileUpload(_) | AppError::ExternalApi(_) => {
                (StatusCode::BAD_GATEWAY, self.to_string())
            }
            AppError::Io(e) => {
                error!("IO error: {e:?}");
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Service error".to_string(),
                )
            }
            AppError::Json(e) => {
                error!("JSON error: {e:?}");
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Service error".to_string(),
                )
            }
            AppError::Internal(e) => {
                error!("Internal error: {e:?}");
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Service error".to_string(),
                )
            }
            AppError::BizError(e) => {
                error!("Biz error: {e:?}");
                (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
            }
            other => {
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
    fn into_response(self) -> Response {
        let (status, message) = self.status_and_message();
        let body = Json(ErrorResponse {
            code: status.as_u16(),
            message,
        });
        (status, body).into_response()
    }
}
