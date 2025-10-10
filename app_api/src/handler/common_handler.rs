use axum::{routing::get, Router};
use common::core::errors::AppError;
use common::core::result::{result, ApiResponse};

pub fn router() -> Router {
    Router::new().route("/status", get(status))
}

async fn status() -> Result<ApiResponse<String>, AppError> {
    Ok(result())
}
