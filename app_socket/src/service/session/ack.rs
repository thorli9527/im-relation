use std::collections::HashMap;
use std::fmt;
use std::sync::Arc;
use std::time::Duration;

use tokio::sync::mpsc;
use tokio::time::Instant;
use tokio_stream::StreamExt;
use tokio_util::time::DelayQueue;

use crate::service::types::{AckCallback, MessageId, SendOpts, ServerMsg, UserId};

use super::manager::SessionManager;
use super::metrics::METRICS;

/// 记录待确认消息及其重试上下文。
#[derive(Clone)]
pub(super) struct PendingAck {
    /// 完整缓存消息体，用于重试扇出；重试时会直接重新扇出该结构
    pub(super) msg: ServerMsg,
    /// 已尝试发送次数（包含首次发送）
    pub(super) attempts: u32,
    /// 超过该时间后不再重试，视为彻底失败
    pub(super) expire_at: Instant,
    /// 发送选项（包含过期、最大重试次数等，克隆自上游调用方）
    pub(super) opts: SendOpts,
    /// 目标用户 ID，便于从管理器重发
    pub(super) target_user: UserId,
    /// 客户端确认回调（例如提交 Kafka offset）
    pub(super) on_ack: Option<AckCallback>,
    /// 达到最大重试或超时后的回调
    pub(super) on_drop: Option<AckCallback>,
}

impl fmt::Debug for PendingAck {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("PendingAck")
            .field("msg_id", &self.msg.id)
            .field("attempts", &self.attempts)
            .field("expire_at", &self.expire_at)
            .field("target_user", &self.target_user)
            .field("max_retry", &self.opts.max_retry)
            .finish()
    }
}

/// ACK 分片与到期调度（DelayQueue），通过哈希分片降低锁竞争。
#[derive(Clone)]
pub(super) struct AckShards {
    inner: Arc<AckShardsInner>,
}

struct AckShardsInner {
    /// 每个分片的命令通道
    shard_tx: Vec<mpsc::Sender<AckCmd>>,
    /// 分片数量，用于取模
    shard_count: usize,
}

/// 分片任务接收的指令，包含新增追踪和确认回调。
#[derive(Debug)]
pub(super) enum AckCmd {
    Track { id: MessageId, entry: PendingAck },
    Ack { id: MessageId },
}

impl AckShards {
    /// 根据配置创建分片，并为每个分片启动一个后台任务负责 DelayQueue 调度。
    pub(super) fn new(shard_count: usize, retry_interval: Duration) -> Self {
        let mut txs = Vec::with_capacity(shard_count);
        for _sid in 0..shard_count {
            let (tx, mut rx) = mpsc::channel::<AckCmd>(10_000);
            txs.push(tx);

            // 每个分片一个独立任务：本地 HashMap + DelayQueue
            tokio::spawn(async move {
                let mut dq: DelayQueue<MessageId> = DelayQueue::new();
                // `map` 保存当前待确认的消息；DelayQueue 仅存 MessageId，二者共同保证 O(1) 查找。
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
                                    if let Some(entry) = map.remove(&id) {
                                        if let Some(cb) = entry.on_ack {
                                            cb(id);
                                        }
                                    }
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
                                    // 否则：过期或达最大重试，执行回调并丢弃
                                    if let Some(cb) = e.on_drop {
                                        cb(id);
                                    }
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
    /// 根据消息 ID 计算落在的分片。
    fn shard(&self, id: MessageId) -> &mpsc::Sender<AckCmd> {
        let idx = (id as usize).wrapping_mul(0x9e3779b1) % self.inner.shard_count;
        &self.inner.shard_tx[idx]
    }

    /// 当消息第一次发送且需要 ACK 时记录分片状态，后续若失败将由后台任务判断是否重试。
    pub(super) fn track_if_new(&self, msg: &ServerMsg, opts: &SendOpts, target_user: UserId) {
        let id = msg.id;
        let entry = PendingAck {
            msg: msg.clone(),
            attempts: 0,
            expire_at: Instant::now() + opts.expire,
            opts: opts.clone(),
            target_user,
            on_ack: opts.ack_hook.clone(),
            on_drop: opts.drop_hook.clone(),
        };
        // 使用 try_send 避免阻塞业务线程；若发送失败表示分片繁忙，可等待下一次发送重试。
        let _ = self.shard(id).try_send(AckCmd::Track { id, entry });
    }

    /// 客户端确认后移除对应记录，取消后续重试。
    pub(super) fn ack(&self, id: MessageId) {
        // 客户端确认后立即从分片中移除，避免多次重试。
        let _ = self.shard(id).try_send(AckCmd::Ack { id });
    }
}
