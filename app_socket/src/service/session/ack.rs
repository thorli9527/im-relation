use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;

use tokio::sync::mpsc;
use tokio::time::Instant;
use tokio_stream::StreamExt;
use tokio_util::time::DelayQueue;

use crate::service::types::{MessageId, SendOpts, ServerMsg, UserId};

use super::manager::SessionManager;
use super::metrics::METRICS;

#[derive(Clone, Debug)]
pub(super) struct PendingAck {
    pub(super) msg: ServerMsg,
    pub(super) attempts: u32,
    pub(super) expire_at: Instant,
    pub(super) opts: SendOpts,
    pub(super) target_user: UserId,
}

/// ACK 分片与到期调度（DelayQueue）
#[derive(Clone)]
pub(super) struct AckShards {
    inner: Arc<AckShardsInner>,
}

struct AckShardsInner {
    shard_tx: Vec<mpsc::Sender<AckCmd>>,
    shard_count: usize,
}

#[derive(Debug)]
pub(super) enum AckCmd {
    Track { id: MessageId, entry: PendingAck },
    Ack { id: MessageId },
}

impl AckShards {
    pub(super) fn new(shard_count: usize, retry_interval: Duration) -> Self {
        let mut txs = Vec::with_capacity(shard_count);
        for _sid in 0..shard_count {
            let (tx, mut rx) = mpsc::channel::<AckCmd>(10_000);
            txs.push(tx);

            // 每个分片一个独立任务：本地 HashMap + DelayQueue
            tokio::spawn(async move {
                let mut dq: DelayQueue<MessageId> = DelayQueue::new();
                let mut map: HashMap<MessageId, PendingAck> = HashMap::new();
                loop {
                    tokio::select! {
                        Some(cmd) = rx.recv() => {
                            match cmd {
                                AckCmd::Track { id, entry } => {
                                    // 已存在则忽略（避免重复 track）
                                    if !map.contains_key(&id) {
                                        map.insert(id, entry);
                                        dq.insert(id, retry_interval);
                                    }
                                }
                                AckCmd::Ack { id } => {
                                    // 客户端确认某条消息后，从缓存中移除并取消定时。
                                    map.remove(&id);
                                }
                            }
                        }
                        Some(expired) = dq.next() => {
                            let id = expired.into_inner();
                            if let Some(mut e) = map.remove(&id) {
                                let now = Instant::now();
                                let expired = now >= e.expire_at;
                                if !expired && e.attempts < e.opts.max_retry {
                                    e.attempts += 1;
                                    // 触发重发
                                    let _ = SessionManager::get()
                                        .send_to_user(e.target_user, e.msg.clone(), e.opts.clone());
                                    // 重新排队等待下次检查
                                    METRICS.ack_retries.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                                    map.insert(id, e);
                                    dq.insert(id, retry_interval);
                                } else {
                                    // 否则：过期或达最大重试，丢弃
                                    METRICS.ack_timeouts.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                                }
                            }
                        }
                    }
                }
            });
        }
        Self {
            inner: Arc::new(AckShardsInner {
                shard_tx: txs,
                shard_count,
            }),
        }
    }

    #[inline]
    fn shard(&self, id: MessageId) -> &mpsc::Sender<AckCmd> {
        let idx = (id as usize).wrapping_mul(0x9e3779b1) % self.inner.shard_count;
        &self.inner.shard_tx[idx]
    }

    pub(super) fn track_if_new(&self, msg: &ServerMsg, opts: &SendOpts, target_user: UserId) {
        let id = msg.id;
        let entry = PendingAck {
            msg: msg.clone(),
            attempts: 0,
            expire_at: Instant::now() + opts.expire,
            opts: opts.clone(),
            target_user,
        };
        // 使用 try_send 避免阻塞业务线程；若发送失败表示分片繁忙，可等待下一次发送重试。
        let _ = self.shard(id).try_send(AckCmd::Track { id, entry });
    }

    pub(super) fn ack(&self, id: MessageId) {
        // 客户端确认后立即从分片中移除，避免多次重试。
        let _ = self.shard(id).try_send(AckCmd::Ack { id });
    }
}
