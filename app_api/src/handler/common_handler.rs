use axum::{routing::get, Router};
use common::errors::AppError;
use common::result::{result, ApiResponse};

pub fn router() -> Router {
    Router::new().route("/status", get(status))
}

async fn status() -> Result<ApiResponse<String>, AppError> {
    Ok(result())
}
