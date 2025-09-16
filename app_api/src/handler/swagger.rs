use actix_web::{get, web, HttpResponse, Responder};

use handler::auth::login_handler::*;
use handler::auth::register_handler::*;
use utoipa::OpenApi;
use crate::handler;

#[derive(OpenApi)]
#[openapi(
    paths(
        //注册
        build_register_code,
        auth_register_verify,
    ),
    components(schemas(
    )),
    tags(
       (name = "im-swagger-api", description = "Example endpoints")
    )
)]
struct ApiDoc;

pub fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(openapi_json);
    cfg.service(actix_files::Files::new("/swagger-ui", "./static/swagger-ui").index_file("index.html")).service(openapi_json);
}
#[get("/openapi.json")]
async fn openapi_json() -> impl Responder {
    match ApiDoc::openapi().to_json() {
        Ok(json) => HttpResponse::Ok().content_type("application/json").body(json),
        Err(_) => HttpResponse::InternalServerError().body("OpenAPI generation error"),
    }
}
