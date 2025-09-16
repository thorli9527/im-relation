//! msg_friend 模块：好友相关 gRPC 定义与客户端封装。
//!
//! - `msg_friend_service`：prost 自动生成的 protobuf 结构与 RPC 客户端；
//! - `client`：应用侧便捷封装，仅包含好友业务所需的连接函数。
pub mod client;
pub mod msg_friend_service;
