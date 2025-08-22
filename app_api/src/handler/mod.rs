pub mod auth;
mod common_handler;
mod socket_handler;
mod swagger;

use actix_web::web;

pub fn configure(cfg: &mut web::ServiceConfig) {
    common_handler::configure(cfg);
    socket_handler::configure(cfg);
    swagger::configure(cfg);
    auth::register_handler::configure(cfg);
    auth::login_handler::configure(cfg);
}
