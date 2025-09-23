use std::sync::atomic::AtomicU64;

pub(super) struct Metrics {
    pub(super) fanout_sent: AtomicU64,
    pub(super) session_queue_full: AtomicU64,
    pub(super) ack_retries: AtomicU64,
    pub(super) ack_timeouts: AtomicU64,
    pub(super) typing_updates: AtomicU64,
    pub(super) typing_rate_limited: AtomicU64,
    pub(super) typing_expired: AtomicU64,
    pub(super) typing_fanout: AtomicU64,
}

pub(super) static METRICS: Metrics = Metrics {
    fanout_sent: AtomicU64::new(0),
    session_queue_full: AtomicU64::new(0),
    ack_retries: AtomicU64::new(0),
    ack_timeouts: AtomicU64::new(0),
    typing_updates: AtomicU64::new(0),
    typing_rate_limited: AtomicU64::new(0),
    typing_expired: AtomicU64::new(0),
    typing_fanout: AtomicU64::new(0),
};
