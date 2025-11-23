pub mod common_handler;
pub mod login_handler;
pub mod register_handler;
pub mod user_handler;
pub mod user_handler_types;
pub mod utils;

use axum::Router;

pub fn router() -> Router {
    Router::new()
        .merge(common_handler::router())
        .merge(register_handler::router())
        .merge(login_handler::router())
        .merge(user_handler::router())
}
