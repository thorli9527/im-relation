//! 分片队列与分发调度
//!
//! 设计目标：
//! - 依据 `UID` 做一致分片，确保同一用户的消息顺序性与降低跨分片竞争；
//! - 每分片采用有界 `mpsc::channel` 承载背压；队列满时丢弃并打点日志；
//! - 分片工作循环从队列取出消息，直接调用 `SessionManager::send_to_user` 进行扇出。

use std::sync::Arc;

use log::{log, warn};
use std::sync::atomic::{AtomicU64, Ordering};
use tokio::sync::mpsc;

use crate::service::session::SessionManager;
use crate::service::types::{SendOpts, ServerMsg, UID};
use common::support::util::common_utils::hash_index;

#[derive(Clone)]
/// 内部分发单元：包含目标用户、下行消息与发送选项
struct DispatchItem {
    uid: UID,
    msg: ServerMsg,
    opts: SendOpts,
}

/// 有界分片调度器：把不同用户的消息分配到固定分片，降低锁竞争与相互影响
#[derive(Clone)]
pub struct ShardedDispatcher {
    shards: Arc<Vec<mpsc::Sender<DispatchItem>>>,
}

impl ShardedDispatcher {
    /// 创建 N 个分片（每分片一个有界 `mpsc::channel` 作为背压队列），并各自启动消费任务
    pub fn new(shard_count: usize, cap: usize) -> Self {
        let mut txs = Vec::with_capacity(shard_count);
        for i in 0..shard_count {
            let (tx, rx) = mpsc::channel::<DispatchItem>(cap);
            txs.push(tx);
            // 每个分片由独立任务消费，避免单热点用户阻塞其它分片。
            tokio::spawn(run_shard(i, rx));
        }
        Self {
            shards: Arc::new(txs),
        }
    }

    /// 入队到一致性分片（依据 uid 哈希），队列满返回 false
    pub fn enqueue(&self, uid: UID, msg: ServerMsg, opts: SendOpts) -> bool {
        let sid = hash_index(&uid, self.shards.len() as i32) as usize;
        self.shards[sid]
            .try_send(DispatchItem { uid, msg, opts })
            .is_ok()
    }
}

/// 分片处理循环：不断从队列取消息并投递到在线会话
async fn run_shard(shard_id: usize, mut rx: mpsc::Receiver<DispatchItem>) {
    let sm = SessionManager::get();
    let mut dropped = 0usize;
    while let Some(item) = rx.recv().await {

        //打印 item.ServerMsg.id
        warn!("DispatchItem.id.{}",item.msg.id);

        let DispatchItem { uid, msg, opts } = item;
        let msg_id = msg.id;
        let ack_hook = opts.ack_hook.clone();
        let drop_hook = opts.drop_hook.clone();
        // 直接调用 SessionManager 扇出消息；返回值代表成功推送到多少会话。
        let sent = sm.send_to_user(uid, msg, opts);
        if sent == 0 {
            // 设备不在线：直接确认以便 kafka 提交 offset，避免长时间阻塞。
            if let Some(cb) = ack_hook.as_ref() {
                cb(msg_id);
            }
            if let Some(cb) = drop_hook.as_ref() {
                cb(msg_id);
            }
            dropped += 1;
            if dropped % 100 == 0 {
                warn!("shard={} dropped={} (no sessions)", shard_id, dropped);
            }
            // 统计无在线会话时的丢弃次数，辅助排查全员离线等问题。
            DISPATCH_DROPS.fetch_add(1, Ordering::Relaxed);
        }
    }
}

static DISPATCH_DROPS: AtomicU64 = AtomicU64::new(0);
