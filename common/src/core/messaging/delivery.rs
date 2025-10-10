//! 控制消息投递行为的可选参数。

/// Kafka 及 socket 投递所需的幂等、重试、超时设置。
#[derive(Debug, Clone)]
pub struct DeliveryOptions {
    /// 是否要求对端确认 ACK。
    pub require_ack: bool,
    /// 消息过期时间（毫秒），None 代表不过期。
    pub expire_ms: Option<u64>,
    /// 最大重试次数，None 表示使用默认策略。
    pub max_retry: Option<u32>,
}

impl DeliveryOptions {
    /// 默认要求 ACK 并设置保守的重试与过期时间。
    pub fn require_ack_defaults() -> Self {
        // 10s 过期 + 10 次重试，适用于关键消息。
        Self {
            require_ack: true,
            expire_ms: Some(10_000),
            max_retry: Some(10),
        }
    }

    /// 生成一个不需要确认、适用于告警类的投递配置。
    pub fn fire_and_forget() -> Self {
        // 对非关键消息关闭 ACK 与重试。
        Self {
            require_ack: false,
            expire_ms: None,
            max_retry: None,
        }
    }
}
