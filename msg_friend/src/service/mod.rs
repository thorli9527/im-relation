//! 好友消息服务的业务实现模块。

pub mod friend_msg_service_impl;
pub use friend_msg_service_impl::spawn_friend_business_notify_retry_task;
