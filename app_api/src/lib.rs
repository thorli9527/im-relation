//! Shared library surface for the `app_api` package.
//!
//! The binary target (`main.rs`) reuses these modules, and test crates can
//! depend on this library to exercise gRPC services directly.

pub mod grpc;
pub mod handler;
pub mod server_grpc;
pub mod server_web;
pub mod service;

pub use service::api_grpc_service::ApiGrpcService;
