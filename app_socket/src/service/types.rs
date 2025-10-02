//! 基础类型与消息模型
//!
//! 约定与说明：
//! - 用户标识统一使用 `common::UserId`（i64）。
//! - Socket/TCP 层使用“长度前缀 + Protobuf”帧格式（详见 `tcp.rs`）。
//! - ServerMsg.id 用于客户端 ACK 对齐；需要可靠送达时结合 `SendOpts` 进行重试与超时控制。

use std::fmt;
use std::sync::Arc;
use std::time::Duration;

// 使用 common 中的 UserId 类型
/// 业务种类（与 TCP/Kafka 边界一致的枚举）
// Ensure the `common` crate is included in Cargo.toml and accessible in your project.
// If `common` is a local module, use `mod common;` at the crate root or adjust the path accordingly.
pub use common::grpc::grpc_socket::socket::MsgKind;
pub use common::UserId;
/// 设备唯一标识（例如设备序列号、推送 token 等）
pub type DeviceId = String;
/// 设备类型（mobile/web/pc/unknown），用于多端登录策略
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum DeviceType {
    Mobile,
    Web,
    Pc,
    Unknown,
}

impl Default for DeviceType {
    fn default() -> Self {
        DeviceType::Unknown
    }
}

impl DeviceType {
    pub fn from_str(s: &str) -> Self {
        match s.to_ascii_lowercase().as_str() {
            // 兼容历史：ios/android 归并为 mobile
            "ios" => DeviceType::Mobile,
            "android" => DeviceType::Mobile,
            "mobile" => DeviceType::Mobile,
            "web" => DeviceType::Web,
            "pc" => DeviceType::Pc,
            _ => DeviceType::Unknown,
        }
    }
}
/// 会话唯一标识（格式：`user:device:uuid`）
pub type SessionId = String;
/// 消息唯一 ID
pub type MessageId = i64;

/// 服务端下行消息（发给客户端）。
///
/// `id` 用于客户端 ACK 对齐；`kind` 与 `payload` 表示业务含义；
/// `ts_ms` 便于客户端基于服务端时间排序消息。
#[derive(Clone, Debug)]
pub struct ServerMsg {
    /// 消息唯一 ID（用于客户端 ACK 对齐）
    pub id: MessageId,
    /// 业务类型（枚举）
    pub kind: MsgKind,
    /// 二进制负载（业务自行定义 Protobuf 或其他二进制）
    pub payload: Vec<u8>,
    /// 业务时间戳（毫秒）
    pub ts_ms: i64,
}

/// 客户端上行消息（含 ACK）。
///
/// * `ack`：存在时表示确认服务端下行 `ServerMsg.id`。
/// * `client_id`：客户端幂等 ID，用于上行去重。
/// * `kind`/`payload`：具体业务负载。
#[derive(Clone, Debug)]
pub struct ClientMsg {
    /// 如果存在，表示对服务端某条 `id` 的确认
    pub ack: Option<MessageId>,
    /// 客户端上行幂等ID（新字段）：用于去重/重试对账；不参与下行 ACK 语义
    pub client_id: Option<MessageId>,
    /// 业务类型（非 ACK 时使用，枚举）
    pub kind: MsgKind,
    /// 二进制负载（非 ACK 时使用）
    pub payload: Vec<u8>,
}

/// 发送选项。
pub type AckCallback = Arc<dyn Fn(MessageId) + Send + Sync>;

pub struct SendOpts {
    /// 是否需要客户端确认
    pub require_ack: bool,
    /// 等待 ACK 的超时时间
    pub expire: Duration,
    /// 超时后的最大重试次数
    pub max_retry: u32,
    /// 客户端 ACK 成功后的回调（例如提交 Kafka offset）
    pub ack_hook: Option<AckCallback>,
    /// 达到最大重试或超时后的回调（例如记录失败或提交 offset）
    pub drop_hook: Option<AckCallback>,
}

impl Clone for SendOpts {
    fn clone(&self) -> Self {
        Self {
            require_ack: self.require_ack,
            expire: self.expire,
            max_retry: self.max_retry,
            ack_hook: self.ack_hook.clone(),
            drop_hook: self.drop_hook.clone(),
        }
    }
}

impl fmt::Debug for SendOpts {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("SendOpts")
            .field("require_ack", &self.require_ack)
            .field("expire", &self.expire)
            .field("max_retry", &self.max_retry)
            .field("ack_hook", &self.ack_hook.is_some())
            .field("drop_hook", &self.drop_hook.is_some())
            .finish()
    }
}

impl Default for SendOpts {
    fn default() -> Self {
        Self {
            require_ack: true,
            expire: Duration::from_secs(10),
            max_retry: 2,
            ack_hook: None,
            drop_hook: None,
        }
    }
}
