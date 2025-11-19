use axum::{routing::get, Router};
use common::core::errors::AppError;
use common::core::result::{result, ApiResponse};

pub fn router() -> Router {
    Router::new().route("/status", get(status))
}

#[utoipa::path(
    get,
    path = "/status",
    responses(
        (status = 200, description = "服务状态", body = ApiResponse<String>)
    ),
    tag = "app_api"
)]
async fn status() -> Result<ApiResponse<String>, AppError> {
    Ok(result())
}
