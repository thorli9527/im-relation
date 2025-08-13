use std::path::PathBuf;
use std::sync::Arc;
use tokio::time::{interval, Duration, MissedTickBehavior};
use tracing::{info, warn, error};

use crate::db::hash_shard_map::HashShardMap;
use crate::persist::snapshot::{build_snapshot, write_snapshot_bincode};

pub struct SnapshotTask {
    map: Arc<HashShardMap>,
    path: PathBuf,
    period: Duration,
}

impl SnapshotTask {
    pub fn new(map: Arc<HashShardMap>, path: impl Into<PathBuf>, period: Duration) -> Self {
        Self { map, path: path.into(), period }
    }

    /// 启动后台定时快照（用 tokio::spawn）
    pub fn spawn(self) {
        tokio::spawn(async move {
            let mut tick = interval(self.period);
            tick.set_missed_tick_behavior(MissedTickBehavior::Delay);
            loop {
                tick.tick().await;
                // 读快照数据时会遍历内部结构但不长时间阻塞写锁（MemberListWrapper 内部锁粒度较小）
                let snap = build_snapshot(&self.map);
                match write_snapshot_bincode(&snap, &self.path) {
                    Ok(()) => info!("snapshot written to {}", self.path.display()),
                    Err(e) => error!("snapshot failed: {e:?}"),
                }
            }
        });
    }
}
