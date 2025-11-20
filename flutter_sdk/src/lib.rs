pub mod api;
pub mod common;
pub mod config;
pub mod domain;
mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
pub(crate) mod generated;
pub mod job;
pub mod service;
pub use serde_json::Value as JsonValue;
pub use service::init;
