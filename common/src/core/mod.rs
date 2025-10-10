//! 聚合领域核心能力：错误类型、消息模型、统一结果包装。

pub mod errors;
pub mod messaging;
pub mod result;

pub use errors::*;
pub use messaging::*;
pub use result::*;
