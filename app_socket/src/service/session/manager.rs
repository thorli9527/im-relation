use std::collections::VecDeque;
use std::sync::atomic::Ordering;
use std::sync::Arc;
use std::time::Duration;

use ahash::AHashMap;
use dashmap::DashMap;
use log::warn;
use once_cell::sync::OnceCell;
use prost::Message;
use tokio::sync::mpsc;
use tokio::time::sleep;

use crate::service::handles::{FriendHandler, GroupHandler, Handler as _, SystemHandler};
use crate::service::types::{
    ClientMsg, DeviceId, DeviceType, MessageId, MsgKind, SendOpts, ServerMsg, SessionId, UserId,
};
use serde_json::json;
use time::OffsetDateTime;

use super::ack::AckShards;
use super::handle::SessionHandle;
use super::metrics::METRICS;
use super::policy::{MultiLoginPolicy, SessionPolicy};
use common::infra::grpc::message::{self as msgpb, typing::Target as TypingTarget, TypingState};

/// 会话管理：维护用户到若干连接的映射，负责扇出、ACK 上报与注销。
#[derive(Clone)]
pub struct SessionManager {
    /// user_id -> (session_id -> SessionHandle) 的层级缓存
    sessions: Arc<DashMap<UserId, AHashMap<SessionId, SessionHandle>>>,
    /// ACK 跟踪分片集合
    acks: AckShards,
    /// 会话登录策略配置
    policy: SessionPolicy,
    /// 用于断线重连补发的消息缓存
    backlog: Arc<DashMap<UserId, VecDeque<ServerMsg>>>,
    /// 最近接收的客户端消息ID，用于去重（每用户最多保留50个）
    recent_client_ids: Arc<DashMap<UserId, VecDeque<MessageId>>>,
    /// session_token -> (user_id, session_id)
    token_index: Arc<DashMap<String, (UserId, SessionId)>>,
    /// session_id -> session_token
    session_tokens: Arc<DashMap<SessionId, String>>,
    /// 会话维度的正在输入状态缓存
    typing: Arc<DashMap<SceneKey, DashMap<UserId, TypingEntry>>>,
}

/// 进程内全局单例，初始于 `init`。
static INSTANCE: OnceCell<SessionManager> = OnceCell::new();

/// Typing 背景场景，用于区分点对点与群聊广播范围。
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum SceneKey {
    Direct { a: UserId, b: UserId },
    Group { group_id: i64 },
}

impl SceneKey {
    /// 构造点对点会话 key，内部保证 `(a,b)` 顺序一致以便复用缓存。
    pub fn direct_from(a: UserId, b: UserId) -> Self {
        if a <= b {
            SceneKey::Direct { a, b }
        } else {
            SceneKey::Direct { a: b, b: a }
        }
    }
}

/// 正在输入 (Typing) 状态的缓存条目，包含限流和过期信息。
#[derive(Clone, Debug)]
struct TypingEntry {
    /// 当前对外广播的状态
    state: TypingState,
    /// 最近一次广播来源的会话 ID
    session_id: Option<SessionId>,
    /// 过期时间，到期后将重置为 `TypingNone`
    expires_at_ms: i64,
    /// 最近一次向外广播的时间
    last_emit_ms: i64,
    /// 限流窗口起始时间
    window_start_ms: i64,
    /// 当前窗口内的请求次数
    window_hits: u32,
    /// Typing 通知需要推送到的用户列表
    recipients: Arc<Vec<UserId>>,
}

impl TypingEntry {
    /// 初始化新的 Typing 状态缓存，默认状态为 `TypingNone`。
    fn new(now_ms: i64, recipients: Arc<Vec<UserId>>) -> Self {
        Self {
            state: TypingState::TypingNone,
            session_id: None,
            expires_at_ms: now_ms,
            last_emit_ms: 0,
            window_start_ms: now_ms,
            window_hits: 0,
            recipients,
        }
    }

    /// 注册新的 Typing 状态更新，返回是否需要立刻广播。
    fn register(
        &mut self,
        state: TypingState,
        session_id: Option<&str>,
        now_ms: i64,
    ) -> TypingUpdateResult {
        if now_ms.saturating_sub(self.window_start_ms) >= 1_000 {
            self.window_start_ms = now_ms;
            self.window_hits = 0;
        }
        self.window_hits += 1;
        if self.window_hits > TYPING_RATE_LIMIT_PER_SEC {
            return TypingUpdateResult::RateLimited;
        }

        self.expires_at_ms = now_ms + TYPING_TTL_MS;
        if let Some(id) = session_id {
            self.session_id = Some(id.to_string());
        }

        let should_emit =
            self.state != state || now_ms.saturating_sub(self.last_emit_ms) >= TYPING_DEBOUNCE_MS;
        self.state = state;
        if should_emit {
            self.last_emit_ms = now_ms;
            TypingUpdateResult::Emit
        } else {
            TypingUpdateResult::Debounced
        }
    }
}

/// Typing 状态更新的结果枚举，驱动后续的广播或限流逻辑。
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum TypingUpdateResult {
    /// 触发下游广播
    Emit,
    /// 状态重复或过于频繁，延迟广播
    Debounced,
    /// 命中速率限制，忽略此次更新
    RateLimited,
}

/// Typing 状态在客户端可持续的最长时间（毫秒）。
const TYPING_TTL_MS: i64 = 5_000;
/// 两次对同样状态的最小广播间隔（毫秒）。
const TYPING_DEBOUNCE_MS: i64 = 500;
/// 每秒允许的 Typing 更新次数。
const TYPING_RATE_LIMIT_PER_SEC: u32 = 5;
/// 后台垃圾回收扫描间隔（毫秒）。
const TYPING_GC_INTERVAL_MS: u64 = 1_000;

impl SessionManager {
    /// 初始化并启动后台 ACK 重试循环（全局单例）
    pub fn init(policy: SessionPolicy) -> Self {
        let cfg = common::config::AppConfig::get();
        let sock = cfg.get_socket();
        let shards = sock.ack_shards.unwrap_or_else(num_cpus::get).max(1);
        let retry_ms = sock.ack_retry_ms.unwrap_or(500) as u64;
        let manager = Self::build(policy, shards, retry_ms);
        let _ = INSTANCE.set(manager.clone());
        manager
    }

    /// 构建 SessionManager，同时启动 Typing GC 等后台协程。
    fn build(policy: SessionPolicy, shards: usize, retry_ms: u64) -> Self {
        let manager = Self {
            sessions: Arc::new(DashMap::new()),
            acks: AckShards::new(shards, Duration::from_millis(retry_ms)),
            policy,
            backlog: Arc::new(DashMap::new()),
            recent_client_ids: Arc::new(DashMap::new()),
            token_index: Arc::new(DashMap::new()),
            session_tokens: Arc::new(DashMap::new()),
            typing: Arc::new(DashMap::new()),
        };
        manager.spawn_typing_gc();
        manager
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

        // 缓存即将被踢下线的会话，用于后续发送通知。
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
            // 超出容量限制时，直接清空旧会话，确保新连接可以写入。
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
            self.notify_kick(&old, "same_device_login");
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
        self.clear_typing_for_session(session_id);
    }

    /// 移除 token 与 session_id 的双向索引，避免脏数据。
    fn remove_token_mapping(&self, session_id: &str, token_hint: Option<&str>) {
        if let Some((_, token)) = self.session_tokens.remove(session_id) {
            self.token_index.remove(&token);
        } else if let Some(token) = token_hint {
            self.token_index.remove(token);
        }
    }

    /// 通知被踢下线的旧会话，以便客户端展示原因。
    fn notify_kick(&self, handle: &SessionHandle, reason: &str) {
        let now_ms = current_millis();
        let payload = json!({
            "notice_type": "login_duplicate",
            "content": "你的账户已在另一台相同类型的设备上登录",
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

    /// 启动后台任务，周期性清理 Typing 过期状态。
    fn spawn_typing_gc(&self) {
        let manager = self.clone();
        tokio::spawn(async move {
            let interval = Duration::from_millis(TYPING_GC_INTERVAL_MS);
            loop {
                sleep(interval).await;
                manager.expire_typing_internal();
            }
        });
    }

    /// 合并并去重 Typing 广播的接收者列表，保证包含触发者自身。
    fn sanitize_recipients(&self, actor: UserId, recipients: &[UserId]) -> Arc<Vec<UserId>> {
        let mut dedup = recipients.to_vec();
        if !dedup.iter().any(|uid| *uid == actor) {
            dedup.push(actor);
        }
        dedup.sort_unstable();
        dedup.dedup();
        Arc::new(dedup)
    }

    /// Typing 状态更新的核心流程：执行去重、限流、广播与缓存维护。
    fn update_typing_internal(
        &self,
        scene: SceneKey,
        actor: UserId,
        session_id: Option<&str>,
        state: TypingState,
        at_ms: i64,
        recipients: &[UserId],
    ) {
        let now_ms = current_millis();
        let recipients = self.sanitize_recipients(actor, recipients);

        if state == TypingState::TypingNone {
            if let Some(scene_map) = self.typing.get(&scene) {
                let removed = scene_map.remove(&actor).map(|(_, entry)| entry);
                drop(scene_map);
                if let Some(entry) = removed {
                    METRICS
                        .typing_updates
                        .fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                    self.broadcast_typing(
                        &scene,
                        actor,
                        TypingState::TypingNone,
                        at_ms,
                        entry.recipients.as_ref(),
                    );
                }
                if let Some(empty) = self.typing.get(&scene) {
                    if empty.is_empty() {
                        self.typing.remove(&scene);
                    }
                }
            }
            return;
        }

        let scene_map = self
            .typing
            .entry(scene.clone())
            .or_insert_with(DashMap::new);

        let mut emit_targets: Option<Arc<Vec<UserId>>> = None;
        {
            let mut entry = scene_map
                .entry(actor)
                .or_insert_with(|| TypingEntry::new(now_ms, recipients.clone()));
            entry.recipients = recipients.clone();
            match entry.register(state, session_id, now_ms) {
                TypingUpdateResult::Emit => {
                    emit_targets = Some(entry.recipients.clone());
                }
                TypingUpdateResult::Debounced => {}
                TypingUpdateResult::RateLimited => {
                    METRICS
                        .typing_rate_limited
                        .fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                    return;
                }
            }
        }

        if let Some(targets) = emit_targets {
            METRICS
                .typing_updates
                .fetch_add(1, std::sync::atomic::Ordering::Relaxed);
            self.broadcast_typing(&scene, actor, state, at_ms, targets.as_ref());
        }
    }

    /// 将 Typing 事件编码并广播到目标会话。
    fn broadcast_typing(
        &self,
        scene: &SceneKey,
        actor: UserId,
        state: TypingState,
        at_ms: i64,
        recipients: &[UserId],
    ) {
        if recipients.is_empty() {
            return;
        }

        let target = match scene {
            SceneKey::Direct { a, b } => {
                let other = if actor == *a { *b } else { *a };
                if actor != *a && actor != *b {
                    return;
                }
                Some(TypingTarget::ToUserId(other))
            }
            SceneKey::Group { group_id } => Some(TypingTarget::GroupId(*group_id)),
        };

        let typing_msg = msgpb::Typing {
            from_user_id: actor,
            state: state as i32,
            at: at_ms,
            target,
            notify_user_ids: recipients.to_vec(),
        };

        let mut buf = Vec::with_capacity(typing_msg.encoded_len());
        if typing_msg.encode(&mut buf).is_err() {
            return;
        }

        let msg = ServerMsg {
            id: current_millis(),
            kind: match scene {
                SceneKey::Direct { .. } => MsgKind::MkFriendTyping,
                SceneKey::Group { .. } => MsgKind::MkGroupTyping,
            },
            payload: buf,
            ts_ms: at_ms,
        };

        let mut fanout = 0u64;
        for uid in recipients.iter().copied() {
            if let Some(sessions) = self.sessions.get(&uid) {
                for (_, handle) in sessions.iter() {
                    if handle.send(msg.clone()) {
                        fanout += 1;
                    }
                }
                drop(sessions);
            }
        }
        if fanout > 0 {
            METRICS
                .typing_fanout
                .fetch_add(fanout, std::sync::atomic::Ordering::Relaxed);
        }
    }

    /// 扫描 Typing 缓存，移除过期条目并广播 TypingNone。
    fn expire_typing_internal(&self) {
        let now_ms = current_millis();
        let scenes: Vec<SceneKey> = self
            .typing
            .iter()
            .map(|entry| entry.key().clone())
            .collect();

        for scene in scenes {
            let mut expired: Vec<(UserId, Arc<Vec<UserId>>)> = Vec::new();
            if let Some(scene_map) = self.typing.get_mut(&scene) {
                let users: Vec<UserId> = scene_map.iter().map(|entry| *entry.key()).collect();
                for uid in users {
                    if let Some(entry) = scene_map.get(&uid) {
                        if entry.expires_at_ms <= now_ms {
                            expired.push((uid, entry.recipients.clone()));
                        }
                    }
                }
                for (uid, _) in &expired {
                    scene_map.remove(uid);
                }
                if scene_map.is_empty() {
                    self.typing.remove(&scene);
                }
            }
            for (uid, recipients) in expired {
                METRICS
                    .typing_expired
                    .fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                self.broadcast_typing(
                    &scene,
                    uid,
                    TypingState::TypingNone,
                    now_ms,
                    recipients.as_ref(),
                );
            }
        }
    }

    /// 当连接关闭时清理其 Typing 状态，避免幽灵在线。
    fn clear_typing_for_session(&self, session_id: &str) {
        let scenes: Vec<SceneKey> = self
            .typing
            .iter()
            .map(|entry| entry.key().clone())
            .collect();
        for scene in scenes {
            let mut affected: Vec<(UserId, Arc<Vec<UserId>>)> = Vec::new();
            if let Some(scene_map) = self.typing.get_mut(&scene) {
                let users: Vec<UserId> = scene_map
                    .iter()
                    .filter_map(|entry| {
                        entry
                            .value()
                            .session_id
                            .as_ref()
                            .filter(|sid| sid.as_str() == session_id)
                            .map(|_| *entry.key())
                    })
                    .collect();
                for uid in &users {
                    if let Some((_, entry)) = scene_map.remove(uid) {
                        affected.push((*uid, entry.recipients.clone()));
                    }
                }
                if scene_map.is_empty() {
                    self.typing.remove(&scene);
                }
            }
            for (uid, recipients) in affected {
                self.broadcast_typing(
                    &scene,
                    uid,
                    TypingState::TypingNone,
                    current_millis(),
                    recipients.as_ref(),
                );
            }
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
            METRICS.ack_inbound.fetch_add(1, Ordering::Relaxed);
            if id == 0 {
                warn!(
                    "SessionManager: received ack with id=0 from user={}",
                    user_id
                );
            }
            // ACK 优先处理：从追踪表移除，避免误判为超时重试。
            self.acks.ack(id);
            return;
        }
        if matches!(msg.kind, MsgKind::MkHeartbeat) {
            // 心跳已在连接层处理，这里无需进一步分发。
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

    /// 更新点对点会话的 Typing 状态。
    pub fn update_direct_typing(
        &self,
        actor: UserId,
        peer: UserId,
        session_id: Option<&str>,
        state: TypingState,
        at_ms: i64,
    ) {
        let recipients = [actor, peer];
        self.update_typing_internal(
            SceneKey::direct_from(actor, peer),
            actor,
            session_id,
            state,
            at_ms,
            &recipients,
        );
    }

    /// 更新群会话的 Typing 状态。
    pub fn update_group_typing(
        &self,
        group_id: i64,
        actor: UserId,
        session_id: Option<&str>,
        state: TypingState,
        at_ms: i64,
        notify_user_ids: &[UserId],
    ) {
        self.update_typing_internal(
            SceneKey::Group { group_id },
            actor,
            session_id,
            state,
            at_ms,
            notify_user_ids,
        );
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

/// 生成唯一的会话 ID 后缀，复用公共 UUID 工具。
fn crate_uuid() -> String {
    common::support::util::common_utils::build_uuid()
}

/// 获取当前 UTC 时间的毫秒时间戳。
fn current_millis() -> i64 {
    (OffsetDateTime::now_utc().unix_timestamp_nanos() / 1_000_000) as i64
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::service::session::policy::SessionPolicy;
    use crate::service::types::{DeviceId, DeviceType};
    use common::infra::grpc::message::{self as msgpb, typing};
    use std::sync::atomic::Ordering;
    use tokio::time::{timeout, Duration};

    fn register_session(
        manager: &SessionManager,
        user: UserId,
        device: DeviceType,
        device_id: DeviceId,
        token: &str,
    ) -> (SessionHandle, tokio::sync::mpsc::Receiver<ServerMsg>) {
        manager.register(user, device, device_id, token.to_string(), 0)
    }

    #[tokio::test]
    async fn typing_direct_multi_device() {
        let manager = SessionManager::build(SessionPolicy::default(), 1, 100);

        let (handle_a1, mut rx_a1) =
            register_session(&manager, 1, DeviceType::Mobile, "dev_a1".into(), "tok_a1");
        let (_handle_a2, mut rx_a2) =
            register_session(&manager, 1, DeviceType::Web, "dev_a2".into(), "tok_a2");
        let (_handle_b, mut rx_b) =
            register_session(&manager, 2, DeviceType::Mobile, "dev_b".into(), "tok_b");

        manager.update_direct_typing(
            1,
            2,
            Some(&handle_a1.session_id),
            TypingState::TypingText,
            current_millis(),
        );

        let msg_a1 = timeout(Duration::from_millis(200), rx_a1.recv())
            .await
            .expect("a1 timeout")
            .expect("a1 none");
        assert_eq!(msg_a1.kind, MsgKind::MkFriendTyping);

        let msg_a2 = timeout(Duration::from_millis(200), rx_a2.recv())
            .await
            .expect("a2 timeout")
            .expect("a2 none");
        assert_eq!(msg_a2.kind, MsgKind::MkFriendTyping);

        let msg_b = timeout(Duration::from_millis(200), rx_b.recv())
            .await
            .expect("b timeout")
            .expect("b none");
        let typing = msgpb::Typing::decode(msg_b.payload.as_slice()).unwrap();
        assert!(matches!(typing.target, Some(typing::Target::ToUserId(1))));
    }

    #[tokio::test]
    async fn typing_group_broadcast() {
        let manager = SessionManager::build(SessionPolicy::default(), 1, 100);
        let (_actor, mut rx_actor) = register_session(
            &manager,
            10,
            DeviceType::Mobile,
            "actor".into(),
            "tok_actor",
        );
        let (_m1, mut rx_m1) =
            register_session(&manager, 11, DeviceType::Mobile, "m1".into(), "tok_m1");

        manager.update_group_typing(
            99,
            10,
            None,
            TypingState::TypingVoice,
            current_millis(),
            &[10, 11],
        );

        let msg_actor = timeout(Duration::from_millis(200), rx_actor.recv())
            .await
            .expect("actor timeout")
            .expect("actor none");
        assert_eq!(msg_actor.kind, MsgKind::MkGroupTyping);

        let msg_m1 = timeout(Duration::from_millis(200), rx_m1.recv())
            .await
            .expect("m1 timeout")
            .expect("m1 none");
        let typing = msgpb::Typing::decode(msg_m1.payload.as_slice()).unwrap();
        assert!(matches!(typing.target, Some(typing::Target::GroupId(99))));
    }

    #[tokio::test]
    async fn typing_ttl_triggers_none() {
        let manager = SessionManager::build(SessionPolicy::default(), 1, 100);
        let (handle_a, mut rx_a) =
            register_session(&manager, 21, DeviceType::Mobile, "dev_a".into(), "tok_a");
        let (_handle_b, mut rx_b) =
            register_session(&manager, 22, DeviceType::Mobile, "dev_b".into(), "tok_b");

        manager.update_direct_typing(
            21,
            22,
            Some(&handle_a.session_id),
            TypingState::TypingText,
            current_millis(),
        );

        let _ = timeout(Duration::from_millis(200), rx_a.recv()).await;
        let _ = timeout(Duration::from_millis(200), rx_b.recv()).await;

        let scene = SceneKey::direct_from(21, 22);
        if let Some(scene_map) = manager.typing.get(&scene) {
            if let Some(mut entry) = scene_map.get_mut(&21) {
                entry.expires_at_ms = current_millis() - 1;
            }
        }
        manager.expire_typing_internal();

        let msg_b = timeout(Duration::from_millis(200), rx_b.recv())
            .await
            .expect("expire timeout")
            .expect("expire none");
        let typing = msgpb::Typing::decode(msg_b.payload.as_slice()).unwrap();
        assert_eq!(typing.state, TypingState::TypingNone as i32);
    }

    #[tokio::test]
    async fn typing_rate_limit_records_metric() {
        METRICS.typing_rate_limited.store(0, Ordering::Relaxed);

        let manager = SessionManager::build(SessionPolicy::default(), 1, 100);
        let (handle_a, _) =
            register_session(&manager, 31, DeviceType::Mobile, "dev_a".into(), "tok_a");

        for _ in 0..8 {
            manager.update_direct_typing(
                31,
                32,
                Some(&handle_a.session_id),
                TypingState::TypingText,
                current_millis(),
            );
        }

        tokio::time::sleep(Duration::from_millis(10)).await;

        let limited = METRICS.typing_rate_limited.load(Ordering::Relaxed);
        assert!(limited >= 1);
    }
}
