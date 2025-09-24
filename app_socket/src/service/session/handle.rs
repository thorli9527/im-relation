use tokio::sync::mpsc;
use tokio::sync::mpsc::error::TrySendError;

use crate::service::types::{DeviceId, DeviceType, ServerMsg, SessionId, UserId};

use super::metrics::METRICS;

/// 单条会话的发送句柄，封装会话运行时元数据和写通道。
#[derive(Clone)]
pub struct SessionHandle {
    /// 归属用户 ID
    pub user_id: UserId,
    /// 客户端类型（移动端/网页等）
    pub device_type: DeviceType,
    /// 客户端设备 ID
    pub device_id: DeviceId,
    /// 内部生成的会话唯一 ID
    pub session_id: SessionId,
    /// 对应鉴权层签发的 session token
    pub session_token: String,
    /// token 过期时间（毫秒时间戳）
    pub expires_at_ms: i64,
    /// 指向底层 Tokio channel 的发送端，用于真正写入消息
    pub(super) tx: mpsc::Sender<ServerMsg>,
}

impl SessionHandle {
    /// 非阻塞尝试发送消息到该会话，失败时交由调用方自行处理。
    pub fn send(&self, msg: ServerMsg) -> bool {
        match self.tx.try_send(msg) {
            Ok(()) => true,
            Err(TrySendError::Full(_)) => {
                METRICS
                    .session_queue_full
                    .fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                // 返回 false 让调用方感知写入失败，从而决定是否丢弃或适当降速。
                false
            }
            Err(_) => false,
        }
    }
}
