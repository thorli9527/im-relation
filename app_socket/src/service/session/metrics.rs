use std::sync::atomic::AtomicU64;

/// 会话子系统内部的自定义指标集合。
pub(super) struct Metrics {
    /// 成功扇出到具体连接的消息数量
    pub(super) fanout_sent: AtomicU64,
    /// 发送通道已满导致的丢投次数
    pub(super) session_queue_full: AtomicU64,
    /// 触发 ACK 重试的次数
    pub(super) ack_retries: AtomicU64,
    /// ACK 超时丢弃次数
    pub(super) ack_timeouts: AtomicU64,
    /// 客户端 ACK 消息到达次数
    pub(super) ack_inbound: AtomicU64,
    /// ACK 消息对应的 ID 不存在（可能重复或超时）
    pub(super) ack_unknown: AtomicU64,
    /// ACK 分片通道出现背压次数
    pub(super) ack_backpressure: AtomicU64,
    /// Typing 更新事件数量
    pub(super) typing_updates: AtomicU64,
    /// Typing 更新被限流次数
    pub(super) typing_rate_limited: AtomicU64,
    /// Typing 过期触发清理次数
    pub(super) typing_expired: AtomicU64,
    /// Typing 事件扇出成功次数
    pub(super) typing_fanout: AtomicU64,
}

/// 进程级静态指标实例，由各模块直接引用。
pub(super) static METRICS: Metrics = Metrics {
    fanout_sent: AtomicU64::new(0),
    session_queue_full: AtomicU64::new(0),
    ack_retries: AtomicU64::new(0),
    ack_timeouts: AtomicU64::new(0),
    ack_inbound: AtomicU64::new(0),
    ack_unknown: AtomicU64::new(0),
    ack_backpressure: AtomicU64::new(0),
    typing_updates: AtomicU64::new(0),
    typing_rate_limited: AtomicU64::new(0),
    typing_expired: AtomicU64::new(0),
    typing_fanout: AtomicU64::new(0),
};
