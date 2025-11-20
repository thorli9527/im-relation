use axum::Json;
use common::core::errors::AppError;
use common::core::result::ApiResponse;
use serde::Serialize;
use validator::ValidationError;

pub type HandlerResult<T> = Result<Json<ApiResponse<T>>, AppError>;

pub fn success<T: Serialize>(data: T) -> HandlerResult<T> {
    Ok(Json(ApiResponse::success(data)))
}

pub fn map_internal_error<E: ToString>(err: E) -> AppError {
    AppError::Internal(err.to_string())
}

pub fn map_session_error<E: ToString>(err: E) -> AppError {
    if err.to_string() == "session token inactive" {
        AppError::Unauthorized("session token inactive".into())
    } else {
        AppError::Internal(err.to_string())
    }
}

pub fn validation_msg(err: &ValidationError) -> String {
    if let Some(msg) = err.message.as_ref() {
        return msg.to_string();
    }
    let code = err.code.as_ref();
    if !code.is_empty() {
        return code.to_string();
    }
    "invalid".into()
}
