//! Shared library surface for the `app_api` package.
//!
//! The binary target (`main.rs`) reuses these modules, and test crates can
//! depend on this library to exercise HTTP services directly.

pub mod handler;
pub mod server_web;
pub mod service;
pub mod swagger;
