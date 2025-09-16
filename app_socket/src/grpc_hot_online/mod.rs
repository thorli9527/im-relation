//! 热在线服务 gRPC 定义与客户端封装。
//!
//! - `auth`/`online_service`/`client_service` 为 prost 自动生成代码；
//! - 该模块主要用于聚合导出，方便其他模块统一引用。
pub mod auth;
pub mod client_service;
pub mod online_service;
