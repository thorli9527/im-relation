//! 对外暴露的业务服务实现。

pub mod group_msg_service;
pub mod socket_push;

pub mod hot_group_client;

pub use group_msg_service::GroupMsgServiceImpl;
