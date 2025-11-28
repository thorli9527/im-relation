use std::{
    env, fmt,
    sync::{
        atomic::{AtomicBool, Ordering},
        mpsc::{self, Receiver, Sender},
    },
    thread,
    time::{Duration, SystemTime, UNIX_EPOCH},
};

use crate::{
    api::config_api,
    domain::{MessageEntity, MessageScene, MessageSource},
    generated::message::{self as msgpb, DeviceType as SocketDeviceType},
    generated::socket::{AuthMsg, ClientMsg, ServerMsg as SocketServerMsg},
    job::message_job,
    service::{
        conversation_service::ConversationService, friend_request_service::FriendRequestService,
        friend_service::FriendService, group_member_service::GroupMemberService,
        group_request_service::GroupRequestService, message_service::MessageService,
        user_service::UserService, 
    },
};
use base64::engine::general_purpose::STANDARD as BASE64;
use base64::Engine as _;
use bytes::{Bytes, BytesMut};
use futures_util::sink::SinkExt;
use log::{debug, info, warn};
use once_cell::sync::OnceCell;
use parking_lot::{Mutex, MutexGuard};
use prost::Message;
use tokio::runtime::Runtime;
use tokio::sync::mpsc::{self as tokio_mpsc, UnboundedReceiver, UnboundedSender};
use tokio::{net::TcpStream, time::Duration as TokioDuration};
use tokio_stream::StreamExt;
use tokio_util::codec::{Framed, LengthDelimitedCodec};
use uuid::Uuid;

#[derive(Clone)]
pub struct SocketConfig {
    pub socket_addr: String,
    pub uid: i64,
    pub device_type: SocketDeviceType,
    pub device_id: String,
    pub token: String,
    pub heartbeat_secs: u64,
}

enum SocketCommand {
    Shutdown,
}

struct SocketControl {
    tx: UnboundedSender<SocketCommand>,
    content_tx: UnboundedSender<msgpb::Content>,
    handle: thread::JoinHandle<()>,
}

pub struct SocketClient {
    inner: Mutex<Option<SocketControl>>,
}

impl SocketClient {
    /// Returns the global SocketClient singleton.
    /// Initialization happens via `init()` during startup.
    pub fn get() -> &'static SocketClient {
        INSTANCE.get().expect("SocketClient not initialized")
    }

    pub fn init() -> Result<(), String> {
        // Prepare waiters list, connection flag, and resender thread.
        SUCCESS_WAITERS.get_or_init(|| Mutex::new(Vec::new()));
        AUTH_SUCCESS.get_or_init(|| AtomicBool::new(false));
        PASSIVE_LOGOUT.get_or_init(|| AtomicBool::new(false));
        start_resend_thread();
        INSTANCE
            .set(SocketClient {
                inner: Mutex::new(None),
            })
            .map_err(|_| "SocketClient already initialized".to_string())
    }

    fn lock_inner(&self) -> MutexGuard<'_, Option<SocketControl>> {
        // parking_lot locks are not poisoned, so we can just lock directly.
        self.inner.lock()
    }

    pub fn connect(&self, config: SocketConfig) -> Result<(), String> {
        let mut guard = self.lock_inner();
        // Clean up previous loop if already connected.
        if let Some(control) = guard.take() {
            let _ = control.tx.send(SocketCommand::Shutdown);
            let _ = control.handle.join();
        }

        let (tx, rx) = tokio_mpsc::unbounded_channel();
        let (content_tx, content_rx) = tokio_mpsc::unbounded_channel();
        let config_clone = config.clone();
        let handle = thread::Builder::new()
            .name("socket-client".into())
            .spawn(move || {
                let runtime = Runtime::new().expect("failed to build runtime");
                runtime.block_on(run_socket_loop(config_clone, rx, content_rx));
            })
            .map_err(|err| err.to_string())?;
        *guard = Some(SocketControl {
            tx,
            content_tx,
            handle,
        });
        Ok(())
    }

    pub fn subscribe_connection_success(&self) -> Receiver<()> {
        // Return a one-shot receiver that resolves when auth succeeds.
        let flag = AUTH_SUCCESS.get().expect("auth flag initialized");
        let (tx, rx) = mpsc::channel();
        if flag.load(Ordering::SeqCst) {
            let _ = tx.send(());
        } else if let Some(waiters) = SUCCESS_WAITERS.get() {
            waiters.lock().push(tx);
        }
        rx
    }

    pub fn disconnect(&self) -> Result<(), String> {
        // Gracefully stop the background thread and drop channels.
        let mut guard = self.lock_inner();
        if let Some(control) = guard.take() {
            let _ = control.tx.send(SocketCommand::Shutdown);
            let _ = control.handle.join();
        }
        Ok(())
    }

    pub fn status(&self) -> Result<bool, String> {
        let guard = self.lock_inner();
        Ok(guard.is_some())
    }

    pub fn send_content(&self, content: msgpb::Content) -> Result<(), String> {
        // Forward outbound protobuf content into the dedicated channel.
        if test_mode_enabled() {
            notify_connection_success();
            return Ok(());
        }
        let guard = self.lock_inner();
        if let Some(control) = guard.as_ref() {
            control
                .content_tx
                .send(content)
                .map_err(|err| err.to_string())
        } else {
            Err("socket not connected".into())
        }
    }

    /// Return whether a passive logout notice was received; clears the flag.
    pub fn take_passive_logout_flag(&self) -> bool {
        PASSIVE_LOGOUT
            .get_or_init(|| AtomicBool::new(false))
            .swap(false, Ordering::SeqCst)
    }
}

static INSTANCE: OnceCell<SocketClient> = OnceCell::new();
static SUCCESS_WAITERS: OnceCell<Mutex<Vec<Sender<()>>>> = OnceCell::new();
static AUTH_SUCCESS: OnceCell<AtomicBool> = OnceCell::new();
static MESSAGE_RESENDER: OnceCell<thread::JoinHandle<()>> = OnceCell::new();
static PASSIVE_LOGOUT: OnceCell<AtomicBool> = OnceCell::new();

const RESEND_INTERVAL_SECS: u64 = 5;

async fn run_socket_loop(
    config: SocketConfig,
    mut rx: UnboundedReceiver<SocketCommand>,
    mut content_rx: UnboundedReceiver<msgpb::Content>,
) {
    // Loop that tries to maintain an active socket connection, obeying reconnect limits.
    let limit = config_api::ensure_socket_reconnect_limit()
        .unwrap_or(config_api::DEFAULT_SOCKET_RECONNECT_LIMIT);
    if test_mode_enabled() {
        eprintln!("socket_client run_socket_loop test mode, notify connection");
        notify_connection_success();
        let _ = config_api::set_socket_reconnect_attempts(limit);
        let _ = config_api::set_socket_reconnect_message("socket test mode connected".into());
        if let Some(SocketCommand::Shutdown) = rx.recv().await {}
        return;
    }
    let mut attempts = config_api::get_or_init_attempts(limit).unwrap_or(limit);
    let mut exhausted = attempts == 0;

    loop {
        // Sleep between attempts when limit exhausted.
        if exhausted {
            tokio::time::sleep(TokioDuration::from_secs(60)).await;
        }

        // Each attempt runs until shutdown/disconnection; maintain reconnect metadata.
        match run_connection_attempt(&config, &mut rx, &mut content_rx).await {
            ConnectionOutcome::Shutdown => break,
            ConnectionOutcome::Disconnected {
                message,
                had_success,
            } => {
                if let Some(msg) = message {
                    let _ = config_api::set_socket_reconnect_message(msg);
                }
                if had_success {
                    attempts = limit;
                    exhausted = false;
                    let _ = config_api::set_socket_reconnect_attempts(attempts);
                } else {
                    if attempts > 0 {
                        attempts -= 1;
                        let _ = config_api::set_socket_reconnect_attempts(attempts);
                    }
                    exhausted = attempts == 0;
                    if exhausted {
                        let _ = config_api::set_socket_reconnect_message(
                            "socket 重连次数耗尽，每分钟尝试一次".into(),
                        );
                    } else {
                        let _ = config_api::set_socket_reconnect_message(format!(
                            "socket 重连中，剩余 {} 次",
                            attempts
                        ));
                    }
                }
            }
        }
    }
}

enum ConnectionOutcome {
    Shutdown,
    Disconnected {
        message: Option<String>,
        had_success: bool,
    },
}

/// 执行一次连接尝试：发起 TCP，鉴权，启动心跳/读写循环。
/// 有命令或数据会通过 `rx`/`content_rx` 传入，任何错误将返回断开状态。
async fn run_connection_attempt(
    config: &SocketConfig,
    rx: &mut UnboundedReceiver<SocketCommand>,
    content_rx: &mut UnboundedReceiver<msgpb::Content>,
) -> ConnectionOutcome {
    let stream = match TcpStream::connect(&config.socket_addr).await {
        Ok(stream) => stream,
        Err(err) => {
            warn!("failed to connect socket {}: {}", config.socket_addr, err);
            return ConnectionOutcome::Disconnected {
                message: Some(format!("连接失败：{err}")),
                had_success: false,
            };
        }
    };
    let mut framed = Framed::new(stream, LengthDelimitedCodec::new());
    if let Err(err) = send_auth(&mut framed, config).await {
        warn!("socket auth failed: {}", err);
        return ConnectionOutcome::Disconnected {
            message: Some(format!("鉴权失败：{err}")),
            had_success: false,
        };
    }

    let mut heartbeat = tokio::time::interval(TokioDuration::from_secs(config.heartbeat_secs));
    let mut authed = false;

    loop {
        tokio::select! {
            cmd = rx.recv() => {
                if let Some(SocketCommand::Shutdown) = cmd {
                    break;
                }
            }
            _ = heartbeat.tick() => {
                if authed {
                    if let Err(err) = send_heartbeat(&mut framed).await {
                        warn!("heartbeat failed: {}", err);
                        return ConnectionOutcome::Disconnected {
                            message: Some(format!("心跳失败：{err}")),
                            had_success: authed,
                        };
                    }
                }
            }
            outbound = content_rx.recv() => {
                if let Some(content) = outbound {
                    if !authed {
                        warn!("socket send blocked: auth not completed");
                        continue;
                    }
                    if let Err(err) = send_outbound_content(&mut framed, content).await {
                        warn!("socket write failed: {}", err);
                        return ConnectionOutcome::Disconnected {
                            message: Some(format!("写入失败：{err}")),
                            had_success: authed,
                        };
                    }
                }
            }
            frame = framed.next() => {
                match frame {
                    Some(Ok(bytes)) => {
                        let read_len = bytes.len();
                        if let Ok(pb) = SocketServerMsg::decode(bytes.freeze()) {
                            if let Some(auth) = pb.auth.as_ref() {
                                info!(
                                    "socket recv auth_ok uid={} device={} id={}",
                                    auth.uid, auth.device_id, pb.id
                                );
                                if !authed {
                                    authed = true;
                                    let limit = config_api::ensure_socket_reconnect_limit()
                                        .unwrap_or(config_api::DEFAULT_SOCKET_RECONNECT_LIMIT);
                                    let _ = config_api::set_socket_reconnect_attempts(limit);
                                    let _ = config_api::set_socket_reconnect_message(
                                        "socket 连接成功".into(),
                                    );
                                    notify_connection_success();
                                }
                            }
                            if !pb.payload.is_empty() {
                                let current_uid = UserService::get()
                                    .latest_user()
                                    .ok()
                                    .flatten()
                                    .map(|u| u.uid);
                                if let Ok(content) = msgpb::Content::decode(pb.payload.as_slice()) {
                                    info!(
                                        "socket recv id={} ts_ms={} scene={} contents={} heartbeat={:?}",
                                        pb.id,
                                        pb.ts_ms,
                                        content.scene,
                                        content.contents.len(),
                                        content.heartbeat
                                    );
                                    if let Some(ack) = &content.ack {
                                        if let Some(ref_id) = ack.ref_message_id {
                                            let _ = MessageService::get().mark_ack(ref_id as i64);
                                        }
                                    }
                                    handle_inbound_content(&content, current_uid);
                                    if pb.id > 0 {
                                        if let Err(err) = send_delivery_ack(&mut framed, pb.id).await
                                        {
                                            warn!("send delivery ack failed: {}", err);
                                        }
                                    }
                                }
                            }
                        }
                        debug!("socket received {} bytes", read_len);
                    }
                    Some(Err(err)) => {
                        warn!("socket read failed: {}", err);
                        return ConnectionOutcome::Disconnected {
                            message: Some(format!("读取失败：{err}")),
                            had_success: authed,
                        };
                    }
                    None => {
                        info!("socket stream ended");
                        return ConnectionOutcome::Disconnected {
                            message: Some("连接已关闭".into()),
                            had_success: authed,
                        };
                    }
                }
            }
        }
    }
    ConnectionOutcome::Shutdown
}

fn handle_inbound_content(content: &msgpb::Content, current_uid: Option<i64>) {
    if let Err(err) = persist_inbound_content(content, current_uid) {
        warn!("persist inbound content failed: {}", err);
    }
    if let Some(system) = content.system_business.as_ref() {
        crate::api::socket_api::notify_system_notice(crate::api::socket_api::SystemNoticeEvent {
            business_type: system.business_type,
            title: system.title.clone(),
            detail: system.detail.clone(),
        });
        if system.business_type
            == msgpb::SystemBusinessType::SystemBusinessPassiveLogout as i32
        {
            PASSIVE_LOGOUT
                .get_or_init(|| AtomicBool::new(false))
                .store(true, Ordering::SeqCst);
            if let Err(err) = crate::service::auth_service::logout() {
                warn!("force logout after passive logout notice failed: {}", err);
            }
        }
    }
    for item in &content.contents {
        if let Some(msgpb::message_content::Content::ProfileUpdate(event)) = &item.content {
            if let Err(err) = apply_profile_update_event(content.sender_id, event) {
                warn!("apply_profile_update_event failed: {}", err);
            }
        }
    }
}

fn persist_inbound_content(
    content: &msgpb::Content,
    current_uid: Option<i64>,
) -> Result<(), String> {
    handle_group_business(content);
    handle_friend_business(content, current_uid);
    persist_message_entity(content, current_uid)?;
    update_conversation_snapshot(content, current_uid)?;
    Ok(())
}

fn persist_message_entity(
    content: &msgpb::Content,
    current_uid: Option<i64>,
) -> Result<(), String> {
    let target_id = resolve_conversation_target(content, current_uid);
    let svc = MessageService::get();
    let entity = MessageEntity {
        id: None,
        conversation_id: target_id,
        scene: MessageScene::from(content.scene as i64),
        receiver_id: Some(content.receiver_id),
        sender_type: 1,
        sender_id: content.sender_id,
        is_session_message: content.scene != msgpb::ChatScene::Profile as i32,
        is_chat_message: true,
        content: serde_json::json!({
            "protobuf": BASE64.encode({
                let mut b = Vec::new();
                let _ = content.encode(&mut b);
                b
            })
        }),
        extra: String::new(),
        created_at: content.timestamp,
        data_source: MessageSource::Server,
        sending_status: true,
        ack_status: true,
        send_count: 0,
    };
    svc.insert(&entity)?;
    Ok(())
}

fn update_conversation_snapshot(
    content: &msgpb::Content,
    current_uid: Option<i64>,
) -> Result<(), String> {
    let scene = MessageScene::from(content.scene as i64);
    let target_id = resolve_conversation_target(content, current_uid);
    let conv_type = scene as i32;
    let svc = ConversationService::get();
    let mut entity = svc
        .get_by_type_and_target(conv_type, target_id)?
        .unwrap_or_else(|| crate::domain::ConversationEntity::new(conv_type, target_id));

    let should_increase_unread = current_uid
        .map(|uid| uid != content.sender_id)
        .unwrap_or(false)
        && !content.contents.is_empty()
        && scene != MessageScene::System;

    if should_increase_unread {
        entity.unread_count = entity.unread_count.saturating_add(1);
    }
    entity.last_message_time = content.timestamp;
    entity.last_message_content = summarize_content(content);
    svc.upsert(entity)
}

fn summarize_content(content: &msgpb::Content) -> String {
    for item in &content.contents {
        match &item.content {
            Some(msgpb::message_content::Content::Text(text)) => {
                return text.text.clone();
            }
            Some(msgpb::message_content::Content::Image(_)) => return "[image]".into(),
            Some(msgpb::message_content::Content::Audio(_)) => return "[audio]".into(),
            Some(msgpb::message_content::Content::Video(_)) => return "[video]".into(),
            Some(msgpb::message_content::Content::FriendEvent(_)) => return "[friend event]".into(),
            Some(msgpb::message_content::Content::GroupEvent(_)) => return "[group event]".into(),
            _ => {}
        }
    }
    if content.friend_business.is_some() {
        return "[friend business]".into();
    }
    if content.group_business.is_some() {
        return "[group business]".into();
    }
    if content.ack.is_some() {
        return "[ACK]".into();
    }
    "[message]".into()
}

fn resolve_conversation_target(content: &msgpb::Content, current_uid: Option<i64>) -> i64 {
    let scene = MessageScene::from(content.scene as i64);
    match scene {
        MessageScene::Group => content.receiver_id,
        MessageScene::System => content.receiver_id,
        _ => {
            if let Some(uid) = current_uid {
                if content.receiver_id == uid {
                    content.sender_id
                } else {
                    content.receiver_id
                }
            } else {
                content.receiver_id
            }
        }
    }
}

fn apply_profile_update_event(
    sender_id: i64,
    event: &msgpb::ProfileEventContent,
) -> Result<(), String> {
    use msgpb::profile_event_content::ProfileEventType;

    let version = parse_meta_i64(&event.metadata, "version");
    let updated_at = parse_meta_i64(&event.metadata, "updated_at").unwrap_or_else(current_millis);

    let (nickname, avatar) = match event.event_type {
        v if v == ProfileEventType::EventName as i32 => (Some(event.new_value.clone()), None),
        v if v == ProfileEventType::EventAvatar as i32 => (None, Some(event.new_value.clone())),
        _ => (None, None),
    };

    if nickname.is_none() && avatar.is_none() {
        return Ok(());
    }

    UserService::get().apply_profile_update(
        sender_id,
        nickname.clone(),
        avatar.clone(),
        version,
        updated_at,
    )?;
    FriendService::get().apply_profile_update(
        sender_id,
        nickname.clone(),
        avatar.clone(),
        updated_at,
    )?;
    GroupMemberService::get()
        .apply_profile_update(sender_id, nickname, avatar, updated_at, version)?;
    Ok(())
}

fn handle_friend_business(content: &msgpb::Content, current_uid: Option<i64>) {
    use msgpb::friend_business_content::Action as FriendAction;

    let Some(biz) = content.friend_business.as_ref() else {
        return;
    };
    match &biz.action {
        Some(FriendAction::Request(payload)) => {
            if let Err(err) = FriendRequestService::get().upsert_request(payload) {
                warn!("store friend request {} failed: {}", payload.request_id, err);
            }
            crate::api::socket_api::notify_friend_request(payload);
        }
        Some(FriendAction::Decision(payload)) => {
            let decided_at = if payload.decided_at > 0 {
                payload.decided_at
            } else {
                content.timestamp
            };
            if let Err(err) = FriendRequestService::get().apply_decision(
                payload,
                content.sender_id,
                content.receiver_id,
                decided_at,
            ) {
                warn!(
                    "apply friend decision {} failed: {}",
                    payload.request_id, err
                );
            }
            if payload.accepted {
                if let Err(err) =
                    apply_friend_acceptance(current_uid, content, payload, decided_at)
                {
                    warn!(
                        "apply friend acceptance for {} failed: {}",
                        payload.request_id, err
                    );
                }
            }
        }
        _ => {}
    }
}

fn handle_group_business(content: &msgpb::Content) {
    use msgpb::group_business_content::Action as GroupAction;

    let Some(biz) = content.group_business.as_ref() else {
        return;
    };
    match &biz.action {
        Some(GroupAction::JoinRequest(payload)) => {
            if let Err(err) = GroupRequestService::get().upsert_request(payload) {
                warn!(
                    "store group join request {} failed: {}",
                    payload.request_id, err
                );
            }
        }
        Some(GroupAction::JoinDecision(payload)) => {
            let decided_at = if payload.decided_at > 0 {
                payload.decided_at
            } else {
                content.timestamp
            };
            if let Err(err) = GroupRequestService::get().apply_decision(payload, decided_at) {
                warn!(
                    "apply group join decision {} failed: {}",
                    payload.request_id, err
                );
            }
        }
        _ => {}
    }
}

fn apply_friend_acceptance(
    current_uid: Option<i64>,
    content: &msgpb::Content,
    payload: &msgpb::FriendRequestDecisionPayload,
    decided_at: i64,
) -> Result<(), String> {
    let uid = match current_uid {
        Some(id) => id,
        None => return Ok(()),
    };
    let counterpart = if uid == content.sender_id {
        content.receiver_id
    } else if uid == content.receiver_id {
        content.sender_id
    } else {
        return Ok(());
    };

    FriendService::get().ensure_friend(
        counterpart,
        normalize_optional(&payload.remark),
        normalize_optional(&payload.nickname),
        decided_at,
    )
}

fn normalize_optional(value: &str) -> Option<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

async fn send_delivery_ack(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
    msg_id: i64,
) -> Result<(), String> {
    let client_msg = ClientMsg {
        ack: Some(msg_id),
        auth: None,
        payload: Vec::new(),
        client_id: None,
    };
    send_message(framed, client_msg).await
}

fn parse_meta_i64(meta: &std::collections::HashMap<String, String>, key: &str) -> Option<i64> {
    meta.get(key).and_then(|v| v.parse::<i64>().ok())
}

async fn send_auth(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
    config: &SocketConfig,
) -> Result<(), String> {
    let auth = AuthMsg {
        uid: config.uid,
        device_type: config.device_type as i32,
        device_id: config.device_id.clone(),
        token: config.token.clone(),
        ts_ms: current_millis(),
        nonce: Uuid::new_v4().as_bytes().to_vec(),
        signature: Vec::new(),
        resume: false,
        last_ack_id: 0,
        supports_encryption: false,
        encryption_schemes: Vec::new(),
    };
    let client_msg = ClientMsg {
        ack: None,
        auth: Some(auth),
        payload: Vec::new(),
        client_id: None,
    };
    send_message(framed, client_msg).await
}

async fn send_heartbeat(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
) -> Result<(), String> {
    let mut content = msgpb::Content::default();
    content.heartbeat = Some(true);
    let payload_bytes = encode_message(content)?;
    let client_msg = ClientMsg {
        ack: None,
        auth: None,
        payload: payload_bytes.to_vec(),
        client_id: None,
    };
    send_message(framed, client_msg).await
}

async fn send_outbound_content(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
    content: msgpb::Content,
) -> Result<(), String> {
    let payload = encode_message(content)?;
    let client_msg = ClientMsg {
        ack: None,
        auth: None,
        payload: payload.to_vec(),
        client_id: None,
    };
    send_message(framed, client_msg).await
}

fn encode_message<M: Message>(message: M) -> Result<Bytes, String> {
    let mut buf = BytesMut::with_capacity(message.encoded_len());
    message
        .encode(&mut buf)
        .map_err(|err| format!("encode message: {err}"))?;
    Ok(buf.freeze())
}

async fn send_message<M: Message>(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
    message: M,
) -> Result<(), String> {
    let payload = encode_message(message)?;
    framed
        .send(payload)
        .await
        .map_err(|err| format!("failed to send frame: {err}"))
}

fn current_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|dur| dur.as_millis() as i64)
        .unwrap_or_default()
}

fn notify_connection_success() {
    if let Some(flag) = AUTH_SUCCESS.get() {
        flag.store(true, Ordering::SeqCst);
    }
    if let Some(waiters) = SUCCESS_WAITERS.get() {
        let mut guard = waiters.lock();
        for tx in guard.drain(..) {
            let _ = tx.send(());
        }
    }
}

fn test_mode_enabled() -> bool {
    env::var("FLUTTER_SDK_SOCKET_CLIENT_TEST_MODE")
        .map(|value| value == "1")
        .unwrap_or(false)
}

fn start_resend_thread() {
    MESSAGE_RESENDER.get_or_init(|| {
        thread::Builder::new()
            .name("message-resender".into())
            .spawn(|| loop {
                if let Err(err) = message_job::resend_pending() {
                    warn!("message_resender error: {}", err);
                }
                thread::sleep(Duration::from_secs(RESEND_INTERVAL_SECS));
            })
            .expect("failed to spawn message resender")
    });
}

impl fmt::Debug for SocketClient {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let guard = self.inner.lock();
        f.debug_struct("SocketClient")
            .field("connected", &guard.is_some())
            .finish()
    }
}
