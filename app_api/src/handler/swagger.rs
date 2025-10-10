use axum::{routing::get, Json, Router};
use common::core::errors::AppError;
use serde_json::Value;
use tower_http::services::ServeDir;
use utoipa::OpenApi;

#[derive(OpenApi)]
#[openapi(tags((name = "im-swagger-api", description = "Example endpoints")))]
struct ApiDoc;

pub fn router() -> Router {
    Router::new()
        .route("/openapi.json", get(openapi_json))
        .nest_service("/swagger-ui", ServeDir::new("./static/swagger-ui"))
}

async fn openapi_json() -> Result<Json<Value>, AppError> {
    let doc = ApiDoc::openapi();
    serde_json::to_value(doc)
        .map(Json)
        .map_err(|e| AppError::Internal(e.to_string()))
}
