//! 领域消息模块：分类、投递配置、消息结构体。

mod category;
mod delivery;
mod domain;

pub use category::MsgCategory;
pub use delivery::DeliveryOptions;
pub use domain::DomainMessage;
