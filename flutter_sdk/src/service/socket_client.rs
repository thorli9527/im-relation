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
    api::{config_api, friend_api},
    domain::{ConversationEntity, MessageEntity, MessageScene, MessageSource},
    domain::proto_adapter::content_to_json,
    generated::message::{self as msgpb, DeviceType as SocketDeviceType},
    generated::socket::{AuthMsg, ClientMsg, ServerMsg as SocketServerMsg},
    job::message_job,
    service::{
        conversation_service::ConversationService, friend_request_service::FriendRequestService,
        friend_service::FriendService, group_member_service::GroupMemberService,
        group_request_service::GroupRequestService,
        local_system_message_service::LocalSystemMessageService, message_service::MessageService,
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
use serde::Deserialize;
use tokio::runtime::Runtime;
use tokio::sync::mpsc::{self as tokio_mpsc, UnboundedReceiver, UnboundedSender};
use tokio::{net::TcpStream, time::Duration as TokioDuration};
use tokio_stream::StreamExt;
use tokio_util::codec::{Framed, LengthDelimitedCodec};
use uuid::Uuid;

/// Socket 客户端配置，用于初始化连接。
#[derive(Clone)]
pub struct SocketConfig {
    /// Socket 服务地址，如 127.0.0.1:50051
    pub socket_addr: String,
    /// 当前用户 UID
    pub uid: i64,
    /// 设备类型（MOBILE/WEB/PC）
    pub device_type: SocketDeviceType,
    /// 设备唯一 ID
    pub device_id: String,
    /// 会话 token
    pub token: String,
    /// 心跳间隔（秒）
    pub heartbeat_secs: u64,
}

/// 用于线程间控制 socket 事件的内部命令。
enum SocketCommand {
    Shutdown,
}

/// 封装 socket 后台线程的控制句柄和通道。
struct SocketControl {
    /// 发送控制命令（关机等）
    tx: UnboundedSender<SocketCommand>,
    /// 发送业务内容
    content_tx: UnboundedSender<msgpb::Content>,
    /// 后台线程句柄
    handle: thread::JoinHandle<()>,
}

/// Socket 客户端单例，对外暴露连接、发送、订阅等接口。
pub struct SocketClient {
    inner: Mutex<Option<SocketControl>>,
}

impl SocketClient {
    /// 全局唯一实例。初始化通过 `init()`。
    pub fn get() -> &'static SocketClient {
        INSTANCE.get().expect("SocketClient not initialized")
    }

    pub fn init() -> Result<(), String> {
        // 初始化等待者队列、鉴权标记、重发线程。
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

    /// 建立 socket 连接：若已有连接则先关闭旧连接，启动后台线程。
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

    /// 断开 socket 连接，停止后台线程。
    pub fn disconnect(&self) -> Result<(), String> {
        let mut guard = self.lock_inner();
        if let Some(control) = guard.take() {
            let _ = control.tx.send(SocketCommand::Shutdown);
            let _ = control.handle.join();
        }
        Ok(())
    }

    /// 当前是否有活跃连接。
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

    /// 返回并清除被动下线标记。
    pub fn take_passive_logout_flag(&self) -> bool {
        PASSIVE_LOGOUT
            .get_or_init(|| AtomicBool::new(false))
            .swap(false, Ordering::SeqCst)
    }
}

/// 全局 SocketClient 单例。
static INSTANCE: OnceCell<SocketClient> = OnceCell::new();
/// 等待 socket 鉴权成功的订阅者列表（一次性唤醒）。
static SUCCESS_WAITERS: OnceCell<Mutex<Vec<Sender<()>>>> = OnceCell::new();
/// 鉴权成功标记。
static AUTH_SUCCESS: OnceCell<AtomicBool> = OnceCell::new();
/// 后台消息重发线程句柄。
static MESSAGE_RESENDER: OnceCell<thread::JoinHandle<()>> = OnceCell::new();
/// 是否收到被动下线通知的标记。
static PASSIVE_LOGOUT: OnceCell<AtomicBool> = OnceCell::new();

/// 消息重发的轮询间隔（秒）
const RESEND_INTERVAL_SECS: u64 = 5;

async fn run_socket_loop(
    config: SocketConfig,
    mut rx: UnboundedReceiver<SocketCommand>,
    mut content_rx: UnboundedReceiver<msgpb::Content>,
) {
    // 主循环：负责维持连接、处理重连限制。
    // limit：最大重连次数（由配置或默认值获取）
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
    // attempts：剩余可重连次数；exhausted：是否用尽，决定是否延时 60s 再试
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

/// 单次连接尝试的结果，用于决定循环行为。
enum ConnectionOutcome {
    /// 主动关闭
    Shutdown,
    /// 被动断开：附带提示信息与是否曾成功鉴权
    Disconnected {
        message: Option<String>,
        had_success: bool,
    },
}

/// 执行一次连接尝试：发起 TCP，鉴权，启动心跳/读写循环。
/// 有命令或数据会通过 `rx`/`content_rx` 传入，任何错误将返回断开状态。
async fn run_connection_attempt(
    config: &SocketConfig,
    rx: &mut UnboundedReceiver<SocketCommand>,       // 接收控制命令（Shutdown）
    content_rx: &mut UnboundedReceiver<msgpb::Content>, // 接收业务消息待发送
) -> ConnectionOutcome {
    // 1) 建立 TCP 连接
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
    // framed：长度定界编码的 TCP 流包装，负责收发 protobuf payload。
    let mut framed = Framed::new(stream, LengthDelimitedCodec::new());
    // 2) 发送鉴权
    if let Err(err) = send_auth(&mut framed, config).await {
        warn!("socket auth failed: {}", err);
        return ConnectionOutcome::Disconnected {
            message: Some(format!("鉴权失败：{err}")),
            had_success: false,
        };
    }

    // 心跳定时器；authed 表示是否完成鉴权，未鉴权前仅接受 auth 响应
    let mut heartbeat = tokio::time::interval(TokioDuration::from_secs(config.heartbeat_secs));
    let mut authed = false;

    loop {
        tokio::select! {
            // 后台控制命令：目前仅支持 Shutdown，收到即退出循环。
            cmd = rx.recv() => {
                if let Some(SocketCommand::Shutdown) = cmd {
                    break;
                }
            }
            // 定时心跳：仅在鉴权成功后发送；失败则视为断开。
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
            // 发送业务消息：鉴权前拒绝发送；写失败则触发重连。
            outbound = content_rx.recv() => {
                if let Some(content) = outbound {
                    if !authed {
                        warn!("socket send blocked: auth not completed");
                        continue;
                    }
                    // 业务消息写入，下游报错时触发重连
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
                    // 下行帧：解码 ServerMsg，处理 auth/payload。
                    Some(Ok(bytes)) => {
                        let read_len = bytes.len(); // 收到的字节数（记录调试）
                        if let Ok(pb) = SocketServerMsg::decode(bytes.freeze()) {

                            // 处理鉴权响应：首次收到 auth 即视为鉴权成功，重置重连计数并通知订阅者。
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
                                // 鉴权帧处理完成，继续下个循环
                                continue;
                            }
                            // 处理业务 payload：Content 解码、ACK 更新、本地落库、回送送达 ACK。
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

/// 统一入口处理服务端推送：日志打印 -> 落库（业务/消息/会话） -> UI 通知系统事件 -> 应用资料变更。
fn handle_inbound_content(content: &msgpb::Content, current_uid: Option<i64>) {
    // 打印解码后的 Content，便于调试；失败时仅提示。
    if let Ok(json) = serde_json::to_string_pretty(&content_to_json(content)) {
        info!("socket inbound decoded: {}", json);
    } else {
        info!("socket inbound received (decode pretty failed)");
    }
    if let Err(err) = persist_inbound_content(content, current_uid) {
        warn!("persist inbound content failed: {}", err);
    }
    // 系统业务：推送到 UI，并处理被动下线。
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
    // Profile 更新事件：同步到用户/好友/群成员。
    for item in &content.contents {
        if let Some(msgpb::message_content::Content::ProfileUpdate(event)) = &item.content {
            if let Err(err) = apply_profile_update_event(content.sender_id, event) {
                warn!("apply_profile_update_event failed: {}", err);
            }
        }
    }
}

/// 顺序处理业务并落库：先处理群/好友/系统业务（确保资料/关系写入），再落地消息实体并更新会话快照/未读。
fn persist_inbound_content(
    content: &msgpb::Content,
    current_uid: Option<i64>,
) -> Result<(), String> {
    // 打印收到的完整消息内容，便于排查落库前的原始数据。
    match serde_json::to_string_pretty(&content_to_json(content)) {
        Ok(json) => info!("persist inbound content: {}", json),
        Err(err) => warn!("persist inbound content json encode failed: {}", err),
    }
    // 先处理业务消息：群事件（入群/审批等）、好友事件（申请/通过/拉起资料）、系统事件（公告/停机等）。
    handle_group_business(content);
    // 好友业务：申请/同意/建立好友关系等，可能触发本地好友/请求表更新。
    handle_friend_business(content, current_uid);
    // 系统业务：公告、停机等系统通知，可能直接返回错误提示调用方。
    handle_system_business(content, current_uid)?;
    // 业务处理完成后再落地原始消息实体，保持与服务端对齐的完整历史。
    persist_message_entity(content, current_uid)?;
    // 最后更新会话快照/未读，保证 UI 看到的最新状态与落地记录一致。
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
    // 场景决定会话类型与目标 ID
    let scene = MessageScene::from(content.scene as i64);
    let target_id = resolve_conversation_target(content, current_uid);
    let conv_type = scene as i32;
    let svc = ConversationService::get();
    let owner_uid = match current_uid {
        Some(uid) => uid,
        None => return Ok(()),
    };
    let mut entity = svc
        .get_by_type_and_target(owner_uid, conv_type, target_id)?
        .unwrap_or_else(|| crate::domain::ConversationEntity::new(owner_uid, conv_type, target_id));

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

/// 根据 content 填充最近消息文案，用于会话列表。
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
    if let Some(system) = content.system_business.as_ref() {
        if system.business_type == msgpb::SystemBusinessType::SystemFriendAdd as i32 {
            return "[friend added]".into();
        }
        return "[system]".into();
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

    // 若无变更则跳过
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
        nickname.clone().unwrap_or_default(),
        avatar.clone(),
        updated_at,
    )?;
    GroupMemberService::get().apply_profile_update(
        sender_id,
        nickname.unwrap_or_default(),
        avatar,
        updated_at,
        version,
    )?;
    Ok(())
}

#[derive(Debug, Deserialize)]
struct FriendAddDetail {
    from_uid: i64,
    to_uid: i64,
}

fn handle_system_business(
    content: &msgpb::Content,
    current_uid: Option<i64>,
) -> Result<(), String> {
    let Some(system) = content.system_business.as_ref() else {
        return Ok(());
    };
    if system.business_type != msgpb::SystemBusinessType::SystemFriendAdd as i32 {
        return Ok(());
    }
    let detail: FriendAddDetail = serde_json::from_str(&system.detail)
        .map_err(|err| format!("parse friend add detail failed: {err}"))?;
    // 确保好友关系写入本地（无备注/昵称场景默认空）。
    if let Some(uid) = current_uid {
        let friend_id = if uid == detail.from_uid {
            detail.to_uid
        } else if uid == detail.to_uid {
            detail.from_uid
        } else {
            0
        };
        if friend_id > 0 {
            let _ = FriendService::get()
                .ensure_friend(friend_id, None, String::new(), content.timestamp);
        }
    }
    persist_friend_add_message(content, &detail, current_uid)
}

fn persist_friend_add_message(
    content: &msgpb::Content,
    detail: &FriendAddDetail,
    current_uid: Option<i64>,
) -> Result<(), String> {
    let uid = match current_uid {
        Some(id) => id,
        None => return Ok(()),
    };
    let friend_id = if uid == detail.from_uid {
        detail.to_uid
    } else if uid == detail.to_uid {
        detail.from_uid
    } else {
        return Ok(());
    };
    let mut synthetic = content.clone();
    synthetic.scene = msgpb::ChatScene::Single as i32;
    synthetic.receiver_id = uid;
    synthetic.sender_id = friend_id;
    persist_message_entity(&synthetic, current_uid)?;
    update_conversation_snapshot(&synthetic, current_uid)
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
        Some(FriendAction::Established(payload)) => {
            info!("friendAction Established{}",&content_to_json(content));
            handle_friend_established(current_uid, content, payload);
        }
        _ => {}
    }
}

// 处理好友建立通知：拉取对方资料 -> 落地好友/头像 -> 更新会话快照/本地系统消息。
fn handle_friend_established(
    current_uid: Option<i64>,
    content: &msgpb::Content,
    payload: &msgpb::FriendEstablishedPayload,
) {
    let uid = match current_uid {
        Some(id) => id,
        None => return,
    };
    // 判定当前用户是 A 还是 B，从而得到对端 ID；不匹配直接返回。
    let friend_id = if uid == payload.uid_a {
        payload.uid_b
    } else if uid == payload.uid_b {
        payload.uid_a
    } else {
        return;
    };
    let established_at = if payload.at_ms > 0 {
        payload.at_ms
    } else {
        content.timestamp
    };
    let svc = FriendService::get();
    // 已存在则不重复落地。
    match svc.get_by_friend_id(friend_id) {
        Ok(Some(_)) => {
            info!(
                "friend {} already exists, skip established payload (uid_a={}, uid_b={})",
                friend_id, payload.uid_a, payload.uid_b
            );
            return;
        }
        Ok(None) => {
            info!(
                "friend {} not found locally, will fetch profile via established payload",
                friend_id
            );
        }
        Err(err) => {
            warn!(
                "query friend {} from established message failed: {}",
                friend_id, err
            );
        }
    }

    // 调用好友详情接口补全昵称/头像，失败则放弃本地落地。
    let profile = match friend_api::get_friend_detail(friend_id) {
        Ok(Some(friend)) => friend,
        Ok(None) => {
            warn!(
                "fetch profile for established friend {} returned empty user",
                friend_id
            );
            return;
        }
        Err(err) => {
            warn!(
                "fetch profile for established friend {} failed: {}",
                friend_id, err
            );
            return;
        }
    };

    let nickname = profile.nickname.clone();
    let avatar = (!profile.avatar.trim().is_empty()).then(|| profile.avatar.clone());
    let remark = profile.remark.clone();

    // 落地好友（昵称允许空串），若成功且有头像则顺带更新头像。
    match svc.ensure_friend(friend_id, remark, nickname.clone(), established_at) {
        Ok(()) => {
            if let Some(av) = avatar {
                if let Err(err) =
                    svc.apply_profile_update(friend_id, nickname, Some(av), established_at)
                {
                    warn!(
                        "apply_profile_update {} from established message failed: {}",
                        friend_id, err
                    );
                }
            }
        }
        Err(err) => {
            warn!(
                "ensure_friend {} from established message failed: {}",
                friend_id, err
            );
        }
    }

    // 更新会话快照 + 本地系统消息占位。
    if let Err(err) = persist_established_snapshot(uid, friend_id, established_at) {
        warn!(
            "persist conversation/system message for established {} failed: {}",
            friend_id, err
        );
    }
}

const FRIEND_ESTABLISHED_PLACEHOLDER: &str = "已成为好友";

fn persist_established_snapshot(
    owner_uid: i64,
    friend_id: i64,
    established_at: i64,
) -> Result<(), String> {
    let conv_svc = ConversationService::get();
    let mut conv = conv_svc
        .get_by_type_and_target(owner_uid, MessageScene::Single as i32, friend_id)?
        .unwrap_or_else(|| ConversationEntity::new(owner_uid, MessageScene::Single as i32, friend_id));
    conv.owner_uid = owner_uid;
    conv.unread_count = conv.unread_count.saturating_add(1);
    conv.last_message_time = established_at;
    conv.last_message_content = FRIEND_ESTABLISHED_PLACEHOLDER.to_string();
    conv_svc.upsert(conv)?;

    let sys_msg = crate::domain::LocalSystemMessageEntity::new(
        owner_uid,
        friend_id,
        FRIEND_ESTABLISHED_PLACEHOLDER.to_string(),
        established_at,
    );
    LocalSystemMessageService::get().insert(sys_msg)
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
        normalize_optional(&payload.nickname).unwrap_or_default(),
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
        heartbeat: None,
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
    // 构造鉴权消息：包含 uid/设备信息/token/时间戳/nonce。
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
        heartbeat: None,
        payload: Vec::new(),
        client_id: None,
    };
    send_message(framed, client_msg).await
}

async fn send_heartbeat(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
) -> Result<(), String> {
    let client_msg = ClientMsg {
        ack: None,
        auth: None,
        heartbeat: Some(true),
        payload: Vec::new(),
        client_id: None,
    };
    send_message(framed, client_msg).await
}

async fn send_outbound_content(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
    content: msgpb::Content,
) -> Result<(), String> {
    // 客户端主动发送普通业务内容（非心跳/鉴权）
    let payload = encode_message(content)?;
    let client_msg = ClientMsg {
        ack: None,
        auth: None,
        heartbeat: None,
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
                // 定期重发发送失败的消息，提升可靠性
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
