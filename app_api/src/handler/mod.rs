pub mod auth;
mod common_handler;
mod socket_handler;
mod swagger;

use axum::Router;

pub fn router() -> Router {
    Router::new()
        .merge(common_handler::router())
        .merge(socket_handler::router())
        .merge(swagger::router())
        .merge(auth::register_handler::router())
        .merge(auth::login_handler::router())
}
