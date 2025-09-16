//! 会话管理与 ACK 跟踪
//!
//! 模块职责：
//! - 维护用户→会话的映射（支持多端登录策略）；
//! - 扇出下发到该用户的所有在线会话；
//! - 分片化 ACK 跟踪 + DelayQueue 定时重试，避免 O(n) 周期扫描；
//! - 每会话有界发送缓冲，防止内存膨胀。
//!
//! 并发与复杂度：
//! - 会话表使用 DashMap 提升并发读写；
//! - ACK 分片数≈CPU 核数，分片内使用 HashMap + DelayQueue（到期触发），处理为 O(1) 近似；
//! - 单用户扇出为对其会话 map 的一次迭代，典型规模较小。

use std::sync::Arc;
use std::collections::HashMap;
use std::time::Duration;

use ahash::AHashMap;
use dashmap::DashMap;
use once_cell::sync::OnceCell;
use tokio::sync::mpsc;
use tokio::sync::mpsc::error::TrySendError;
use tokio::time::Instant;
use tokio_stream::StreamExt;
use tokio_util::time::DelayQueue;
use std::sync::atomic::{ AtomicU64, Ordering };
use std::collections::VecDeque;

use crate::service::types::{
    ClientMsg,
    DeviceId,
    DeviceType,
    MessageId,
    SendOpts,
    ServerMsg,
    SessionId,
    UserId,
};

/// 单条会话的发送句柄（写通道）
#[derive(Clone)]
pub struct SessionHandle {
    pub user_id: UserId,
    pub device_type: DeviceType,
    pub device_id: DeviceId,
    pub session_id: SessionId,
    tx: mpsc::Sender<ServerMsg>,
}

impl SessionHandle {
    /// 非阻塞尝试发送消息到该会话
    pub fn send(&self, msg: ServerMsg) -> bool {
        match self.tx.try_send(msg) {
            Ok(()) => true,
            Err(TrySendError::Full(_)) => {
                METRICS.session_queue_full.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                false
            }
            Err(_) => false,
        }
    }
}

#[derive(Clone, Debug)]
pub struct PendingAck {
    msg: ServerMsg,
    attempts: u32,
    expire_at: Instant,
    opts: SendOpts,
    target_user: UserId,
}

/// ACK 分片与到期调度（DelayQueue）
#[derive(Clone)]
pub struct AckShards {
    inner: Arc<AckShardsInner>,
}

struct AckShardsInner {
    shard_tx: Vec<mpsc::Sender<AckCmd>>,
    shard_count: usize,
}

#[derive(Debug)]
enum AckCmd {
    Track {
        id: MessageId,
        entry: PendingAck,
    },
    Ack {
        id: MessageId,
    },
}

impl AckShards {
    pub fn new(shard_count: usize, retry_interval: Duration) -> Self {
        let mut txs = Vec::with_capacity(shard_count);
        for _sid in 0..shard_count {
            let (tx, mut rx) = mpsc::channel::<AckCmd>(10000);
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
                                    let _ = SessionManager::get().send_to_user(e.target_user, e.msg.clone(), e.opts.clone());
                                    // 重新排队等待下次检查
                                    METRICS.ack_retries.fetch_add(1, Ordering::Relaxed);
                                    map.insert(id, e);
                                    dq.insert(id, retry_interval);
                                }
                                // 否则：过期或达最大重试，丢弃
                                else {
                                    METRICS.ack_timeouts.fetch_add(1, Ordering::Relaxed);
                                }
                            }
                        }
                    }
                }
            });
        }
        Self { inner: Arc::new(AckShardsInner { shard_tx: txs, shard_count: shard_count }) }
    }

    #[inline]
    fn shard(&self, id: MessageId) -> &mpsc::Sender<AckCmd> {
        let idx = (id as usize).wrapping_mul(0x9e3779b1) % self.inner.shard_count;
        &self.inner.shard_tx[idx]
    }

    pub fn track_if_new(&self, msg: &ServerMsg, opts: &SendOpts, target_user: UserId) {
        let id = msg.id;
        let entry = PendingAck {
            msg: msg.clone(),
            attempts: 0,
            expire_at: Instant::now() + opts.expire,
            opts: opts.clone(),
            target_user,
        };
        let _ = self.shard(id).try_send(AckCmd::Track { id, entry });
    }
    pub fn ack(&self, id: MessageId) {
        let _ = self.shard(id).try_send(AckCmd::Ack { id });
    }
}

/// 多端登录策略：决定注册新会话时如何处理已有会话
#[derive(Clone, Copy, Debug)]
pub enum MultiLoginPolicy {
    AllowAll,
    SinglePerDeviceType,
    SingleGlobal,
}

/// 会话管理策略：多端登录与容量限制
#[derive(Clone)]
pub struct SessionPolicy {
    pub multi_login: MultiLoginPolicy,
    pub max_sessions_per_user: usize,
}

impl Default for SessionPolicy {
    fn default() -> Self {
        Self { multi_login: MultiLoginPolicy::SinglePerDeviceType, max_sessions_per_user: 5 }
    }
}

/// 会话管理：维护用户到若干连接的映射，负责扇出、ACK 上报与注销
#[derive(Clone)]
pub struct SessionManager {
    sessions: Arc<DashMap<UserId, AHashMap<SessionId, SessionHandle>>>,
    acks: AckShards,
    policy: SessionPolicy,
    backlog: Arc<DashMap<UserId, VecDeque<ServerMsg>>>,
    /// 最近接收的客户端消息ID，用于去重（每用户最多保留50个）
    recent_client_ids: Arc<DashMap<UserId, VecDeque<MessageId>>>,
}

static INSTANCE: OnceCell<SessionManager> = OnceCell::new();

struct Metrics {
    fanout_sent: AtomicU64,
    session_queue_full: AtomicU64,
    ack_retries: AtomicU64,
    ack_timeouts: AtomicU64,
}

static METRICS: Metrics = Metrics {
    fanout_sent: AtomicU64::new(0),
    session_queue_full: AtomicU64::new(0),
    ack_retries: AtomicU64::new(0),
    ack_timeouts: AtomicU64::new(0),
};

impl SessionManager {
    /// 初始化并启动后台 ACK 重试循环（全局单例）
    pub fn init(policy: SessionPolicy) -> Self {
        let cfg = common::config::AppConfig::get();
        let sock = cfg.get_socket();
        let shards = sock.ack_shards.unwrap_or_else(num_cpus::get).max(1);
        let retry_ms = sock.ack_retry_ms.unwrap_or(500);
        let sm = Self {
            sessions: Arc::new(DashMap::new()),
            acks: AckShards::new(shards, Duration::from_millis(retry_ms)),
            policy,
            backlog: Arc::new(DashMap::new()),
            recent_client_ids: Arc::new(DashMap::new()),
        };
        let _ = INSTANCE.set(sm.clone());
        sm
    }
    /// 获取单例句柄
    pub fn get() -> Self {
        INSTANCE.get().expect("SessionManager not inited").clone()
    }

    /// 记录客户端消息ID；若已存在则返回 true（表示重复，不需处理）
    pub fn seen_or_track_client_id(&self, user_id: &UserId, id: MessageId) -> bool {
        let mut entry = self.recent_client_ids.entry(*user_id).or_default();
        let dq = entry.value_mut();
        if dq.contains(&id) { return true; }
        if dq.len() >= 50 { let _ = dq.pop_front(); }
        dq.push_back(id);
        false
    }

    /// 注册一个新连接。根据策略剔除冲突会话，返回该连接的发送句柄与接收端。
    pub fn register(
        &self,
        user_id: UserId,
        device_type: DeviceType,
        device_id: DeviceId
    ) -> (SessionHandle, mpsc::Receiver<ServerMsg>) {
        let session_id = format!("{}:{}:{}", &user_id, &device_id, crate_uuid());
        let (tx, rx) = mpsc::channel(128);
        let handle = SessionHandle {
            user_id: user_id.clone(),
            device_type: device_type.clone(),
            device_id,
            session_id: session_id.clone(),
            tx,
        };
        let mut map = self.sessions.entry(user_id.clone()).or_default();

        // policy: trim/kick
        match self.policy.multi_login {
            MultiLoginPolicy::AllowAll => {}
            MultiLoginPolicy::SingleGlobal => {
                map.clear();
            }
            MultiLoginPolicy::SinglePerDeviceType => {
                // 基于设备类型剔除同类型的旧会话
                map.retain(|_, h| h.device_type != device_type);
            }
        }
        // capacity bound
        if map.len() >= self.policy.max_sessions_per_user {
            map.clear();
        }
        map.insert(session_id.clone(), handle.clone());
        (handle, rx)
    }

    /// 注销连接
    pub fn unregister(&self, user_id: &UserId, session_id: &str) {
        if let Some(mut m) = self.sessions.get_mut(user_id) {
            m.remove(session_id);
        }
    }

    /// 向用户的所有在线会话扇出一条消息（可选 ACK 跟踪）
    pub fn send_to_user(&self, user_id: UserId, msg: ServerMsg, opts: SendOpts) -> usize {
        if opts.require_ack {
            self.acks.track_if_new(&msg, &opts, user_id);
        }
        // 记录最近下发的消息，用于快速补发（每用户保留最多 100 条）
        const BACKLOG_CAP: usize = 100;
        {
            let mut q = self.backlog.entry(user_id).or_default();
            q.push_back(msg.clone());
            while q.len() > BACKLOG_CAP {
                q.pop_front();
            }
        }
        if let Some(m) = self.sessions.get(&user_id) {
            let mut sent = 0;
            for (_sid, s) in m.iter() {
                if s.send(msg.clone()) {
                    sent += 1;
                }
            }
            if sent > 0 {
                METRICS.fanout_sent.fetch_add(sent as u64, std::sync::atomic::Ordering::Relaxed);
            }
            sent
        } else {
            0
        }
    }

    /// 处理来自客户端的上行消息（包含 ACK）
    pub fn on_client_msg(&self, user_id: UserId, msg: ClientMsg) {
        if let Some(id) = msg.ack {
            self.acks.ack(id);
            return;
        }
        use crate::service::handler::{FriendHandler, GroupHandler, SystemHandler, Handler as _};
        let msg_kind = msg.kind.clone() as i32;
        // 处理好友消息 100-300 为好友消息
        if (100..300).contains(&msg_kind) {
            FriendHandler.handle(user_id, &msg);
            return;
        }
        // 处理群消息 300-500 为群消息
        if (300..500).contains(&msg_kind) {
            GroupHandler.handle(user_id, &msg);
            return;
        }
        // 处理系统消息 900-1000 为系统消息
        if (900..1000).contains(&msg_kind) {
            SystemHandler.handle(user_id, &msg);
            return;
        }
        // 其他类型：暂不处理
    }

    /// 仅向指定会话重发比 last_ack_id 更新的最近消息（断线重连快速补发）
    pub fn resend_since(
        &self,
        user_id: &UserId,
        last_ack_id: MessageId,
        handle: &SessionHandle
    ) -> usize {
        if let Some(q) = self.backlog.get(user_id) {
            let mut resent = 0usize;
            for m in q.iter() {
                if m.id > last_ack_id {
                    if handle.send(m.clone()) {
                        resent += 1;
                    }
                }
            }
            return resent;
        }
        0
    }
}

fn crate_uuid() -> String {
    common::util::common_utils::build_uuid()
}
