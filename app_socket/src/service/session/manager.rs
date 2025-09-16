use std::collections::VecDeque;
use std::sync::Arc;
use std::time::Duration;

use ahash::AHashMap;
use dashmap::DashMap;
use once_cell::sync::OnceCell;
use tokio::sync::mpsc;

use crate::service::handler::{FriendHandler, GroupHandler, Handler as _, SystemHandler};
use crate::service::types::{
    ClientMsg, DeviceId, DeviceType, MessageId, MsgKind, SendOpts, ServerMsg, SessionId, UserId,
};
use serde_json::json;
use time::OffsetDateTime;

use super::ack::AckShards;
use super::handle::SessionHandle;
use super::metrics::METRICS;
use super::policy::{MultiLoginPolicy, SessionPolicy};

/// 会话管理：维护用户到若干连接的映射，负责扇出、ACK 上报与注销
#[derive(Clone)]
pub struct SessionManager {
    sessions: Arc<DashMap<UserId, AHashMap<SessionId, SessionHandle>>>,
    acks: AckShards,
    policy: SessionPolicy,
    backlog: Arc<DashMap<UserId, VecDeque<ServerMsg>>>,
    /// 最近接收的客户端消息ID，用于去重（每用户最多保留50个）
    recent_client_ids: Arc<DashMap<UserId, VecDeque<MessageId>>>,
    /// session_token -> (user_id, session_id)
    token_index: Arc<DashMap<String, (UserId, SessionId)>>,
    /// session_id -> session_token
    session_tokens: Arc<DashMap<SessionId, String>>,
}

static INSTANCE: OnceCell<SessionManager> = OnceCell::new();

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
            token_index: Arc::new(DashMap::new()),
            session_tokens: Arc::new(DashMap::new()),
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
        if dq.contains(&id) {
            // 重复出现表示客户端重放或超时重试，直接返回 true 让上层跳过业务处理。
            return true;
        }
        if dq.len() >= 50 {
            let _ = dq.pop_front();
        }
        dq.push_back(id);
        false
    }

    /// 注册一个新连接。根据策略剔除冲突会话，返回该连接的发送句柄与接收端。
    pub fn register(
        &self,
        user_id: UserId,
        device_type: DeviceType,
        device_id: DeviceId,
        session_token: String,
        expires_at_ms: i64,
    ) -> (SessionHandle, mpsc::Receiver<ServerMsg>) {
        let session_id = format!("{}:{}:{}", &user_id, &device_id, crate_uuid());
        let (tx, rx) = mpsc::channel(128);
        let handle = SessionHandle {
            user_id: user_id.clone(),
            device_type: device_type.clone(),
            device_id,
            session_id: session_id.clone(),
            session_token: session_token.clone(),
            expires_at_ms,
            tx,
        };
        let mut map = self.sessions.entry(user_id.clone()).or_default();

        let mut removed: Vec<SessionHandle> = Vec::new();

        match self.policy.multi_login {
            MultiLoginPolicy::AllowAll => {}
            MultiLoginPolicy::SingleGlobal => {
                let keys: Vec<String> = map.keys().map(|k| k.clone()).collect();
                for sid in keys {
                    if let Some(old) = map.remove(&sid) {
                        self.remove_token_mapping(&sid, Some(&old.session_token));
                        removed.push(old);
                    }
                }
            }
            MultiLoginPolicy::SinglePerDeviceType => {
                let keys: Vec<String> = map
                    .iter()
                    .filter(|(_, h)| h.device_type == device_type)
                    .map(|(sid, _)| sid.clone())
                    .collect();
                for sid in keys {
                    if let Some(old) = map.remove(&sid) {
                        self.remove_token_mapping(&sid, Some(&old.session_token));
                        removed.push(old);
                    }
                }
            }
        }

        if map.len() >= self.policy.max_sessions_per_user {
            let keys: Vec<String> = map.keys().map(|k| k.clone()).collect();
            for sid in keys {
                if let Some(old) = map.remove(&sid) {
                    self.remove_token_mapping(&sid, Some(&old.session_token));
                    removed.push(old);
                }
            }
        }

        map.insert(session_id.clone(), handle.clone());
        self.session_tokens
            .insert(session_id.clone(), session_token.clone());
        self.token_index
            .insert(session_token.clone(), (user_id.clone(), session_id.clone()));

        for old in removed {
            self.notify_kick(&old, "new_login");
        }

        (handle, rx)
    }

    /// 注销连接
    pub fn unregister(&self, user_id: &UserId, session_id: &str) {
        if let Some(mut m) = self.sessions.get_mut(user_id) {
            if let Some(handle) = m.remove(session_id) {
                self.remove_token_mapping(session_id, Some(&handle.session_token));
            }
        }
        self.remove_token_mapping(session_id, None);
    }

    fn remove_token_mapping(&self, session_id: &str, token_hint: Option<&str>) {
        if let Some((_, token)) = self.session_tokens.remove(session_id) {
            self.token_index.remove(&token);
        } else if let Some(token) = token_hint {
            self.token_index.remove(token);
        }
    }

    fn notify_kick(&self, handle: &SessionHandle, reason: &str) {
        let now_ms = (OffsetDateTime::now_utc().unix_timestamp_nanos() / 1_000_000) as i64;
        let payload = json!({
            "event": "session_kick",
            "reason": reason,
            "device_type": format!("{:?}", handle.device_type),
        })
        .to_string();
        let msg = ServerMsg {
            id: now_ms,
            kind: MsgKind::MkSysNotice,
            payload: payload.into_bytes(),
            ts_ms: now_ms,
        };
        let _ = handle.send(msg);
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
                METRICS
                    .fanout_sent
                    .fetch_add(sent as u64, std::sync::atomic::Ordering::Relaxed);
            }
            sent
        } else {
            // 若用户当前无在线会话，返回 0 并由调用方决定是否记录堆积或丢弃。
            0
        }
    }

    /// 处理来自客户端的上行消息（包含 ACK）
    pub fn on_client_msg(&self, user_id: UserId, msg: ClientMsg) {
        if let Some(id) = msg.ack {
            // ACK 优先处理：从追踪表移除，避免误判为超时重试。
            self.acks.ack(id);
            return;
        }
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
        handle: &SessionHandle,
    ) -> usize {
        if let Some(q) = self.backlog.get(user_id) {
            let mut resent = 0usize;
            for m in q.iter() {
                if m.id > last_ack_id {
                    // 逐条将 ack 之后的消息重新推送给当前连接，保证断线重连后快速补齐。
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
