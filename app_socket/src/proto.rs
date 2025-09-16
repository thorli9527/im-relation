//! Proto 模块：统一 re-export build.rs 生成的 socket 协议定义。
//!
//! build.rs 会将 `socket.proto` 通过 prost 编译到 `OUT_DIR/socketpb.rs`，这里将其纳入
//! 模块体系并导出常用类型，方便业务模块以 `crate::proto::AuthMsg` 等形式引用。

pub mod socketpb {
    include!(concat!(env!("OUT_DIR"), "/socketpb.rs"));
}

pub use socketpb::{AuthMsg, ClientMsg, DeviceType, KafkaSocketMsg, MsgKind, ServerMsg};
