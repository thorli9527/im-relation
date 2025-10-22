mod common_handler;

use axum::Router;

pub fn router() -> Router {
    Router::new().merge(common_handler::router())
}
