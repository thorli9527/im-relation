use actix_web::{Responder, get, web};
use common::errors::AppError;
use common::result::result;

pub fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(status);
}
#[utoipa::path(
    get,
    path = "/status",
    tag = "Common",
    summary = "Get the status of the service",
    responses(
        (status = 200, description = "Hello response", body = String)
    )
)]
#[get("/status")]
async fn status() -> Result<impl Responder, AppError> {
    Ok(result())
}
