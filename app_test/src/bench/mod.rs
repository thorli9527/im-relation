#![allow(unused_imports)]
//! 压测模块，提供批量注册和Socket连接压测功能
//!
//! 本模块包含两个主要功能：
//! 1. 批量用户注册：快速创建大量测试账号
//! 2. Socket连接压测：模拟大量客户端同时连接并发送消息

pub mod login;
pub mod login_socket;
pub mod register;
pub mod socket;

pub use login::{LoginResult, LoginType, login_and_get_socket};
pub use login_socket::{LoginSocketBenchConfig, login_socket_bench};
pub use register::{BatchRegisterConfig, BatchRegisterResult, batch_register, register_users};
pub use socket::{SocketBenchConfig, SocketBenchResult, run_socket_bench, websocket_bench};
