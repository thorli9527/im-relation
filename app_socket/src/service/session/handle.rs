use tokio::sync::mpsc;
use tokio::sync::mpsc::error::TrySendError;

use crate::service::types::{DeviceId, DeviceType, ServerMsg, SessionId, UserId};

use super::metrics::METRICS;

/// 单条会话的发送句柄（写通道）
#[derive(Clone)]
pub struct SessionHandle {
    pub user_id: UserId,
    pub device_type: DeviceType,
    pub device_id: DeviceId,
    pub session_id: SessionId,
    pub session_token: String,
    pub expires_at_ms: i64,
    pub(super) tx: mpsc::Sender<ServerMsg>,
}

impl SessionHandle {
    /// 非阻塞尝试发送消息到该会话
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
