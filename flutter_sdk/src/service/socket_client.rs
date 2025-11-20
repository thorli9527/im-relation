use std::{
    env, fmt,
    sync::{
        atomic::{AtomicBool, Ordering},
        mpsc::{self, Receiver, Sender},
        Mutex,
    },
    thread,
    time::{SystemTime, UNIX_EPOCH},
};

use crate::{
    api::config_api,
    generated::message as msgpb,
    generated::socket::{
        AuthMsg, ClientMsg, DeviceType as SocketDeviceType, ServerMsg as SocketServerMsg,
    },
    service::message_service::MessageService,
};
use bytes::{Bytes, BytesMut};
use futures_util::sink::SinkExt;
use log::{debug, info, warn};
use once_cell::sync::OnceCell;
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
    pub user_id: i64,
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
        // Prepare waiters list and connection flag before any connects.
        SUCCESS_WAITERS.get_or_init(|| Mutex::new(Vec::new()));
        CONNECTION_SUCCESS.get_or_init(|| AtomicBool::new(false));
        INSTANCE
            .set(SocketClient {
                inner: Mutex::new(None),
            })
            .map_err(|_| "SocketClient already initialized".to_string())
    }

    pub fn connect(&self, config: SocketConfig) -> Result<(), String> {
        let mut guard = self.inner.lock().map_err(|_| "socket lock poisoned")?;
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
        // Return a one-shot receiver that resolves when a connection succeeds.
        let flag = CONNECTION_SUCCESS
            .get()
            .expect("connection flag initialized");
        let (tx, rx) = mpsc::channel();
        if flag.load(Ordering::SeqCst) {
            let _ = tx.send(());
        } else if let Some(waiters) = SUCCESS_WAITERS.get() {
            waiters.lock().unwrap().push(tx);
        }
        rx
    }

    pub fn disconnect(&self) -> Result<(), String> {
        // Gracefully stop the background thread and drop channels.
        let mut guard = self.inner.lock().map_err(|_| "socket lock poisoned")?;
        if let Some(control) = guard.take() {
            let _ = control.tx.send(SocketCommand::Shutdown);
            let _ = control.handle.join();
        }
        Ok(())
    }

    pub fn status(&self) -> Result<bool, String> {
        let guard = self.inner.lock().map_err(|_| "socket lock poisoned")?;
        Ok(guard.is_some())
    }

    pub fn send_content(&self, content: msgpb::Content) -> Result<(), String> {
        // Forward outbound protobuf content into the dedicated channel.
        if test_mode_enabled() {
            notify_connection_success();
            return Ok(());
        }
        let guard = self.inner.lock().map_err(|_| "socket lock poisoned")?;
        if let Some(control) = guard.as_ref() {
            control
                .content_tx
                .send(content)
                .map_err(|err| err.to_string())
        } else {
            Err("socket not connected".into())
        }
    }
}

static INSTANCE: OnceCell<SocketClient> = OnceCell::new();
static SUCCESS_WAITERS: OnceCell<Mutex<Vec<Sender<()>>>> = OnceCell::new();
static CONNECTION_SUCCESS: OnceCell<AtomicBool> = OnceCell::new();

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
    let mut connected_success = false;

    loop {
        tokio::select! {
            cmd = rx.recv() => {
                if let Some(SocketCommand::Shutdown) = cmd {
                    break;
                }
            }
            _ = heartbeat.tick() => {
                if connected_success {
                    if let Err(err) = send_heartbeat(&mut framed).await {
                        warn!("heartbeat failed: {}", err);
                        return ConnectionOutcome::Disconnected {
                            message: Some(format!("心跳失败：{err}")),
                            had_success: connected_success,
                        };
                    }
                }
            }
            outbound = content_rx.recv() => {
                if let Some(content) = outbound {
                    if let Err(err) = send_outbound_content(&mut framed, content).await {
                        warn!("socket write failed: {}", err);
                        return ConnectionOutcome::Disconnected {
                            message: Some(format!("写入失败：{err}")),
                            had_success: connected_success,
                        };
                    }
                }
            }
            frame = framed.next() => {
                match frame {
                    Some(Ok(bytes)) => {
                        let read_len = bytes.len();
                        if let Ok(pb) = SocketServerMsg::decode(bytes.freeze()) {
                            if let Ok(content) = msgpb::Content::decode(pb.payload.as_slice()) {
                                if let Some(ack) = &content.ack {
                                    if let Some(ref_id) = ack.ref_message_id {
                                        let _ = MessageService::get().mark_ack(ref_id as i64);
                                    }
                                }
                                if let Some(sys) = content.system_business {
                                    if is_connection_success(&sys) && !connected_success {
                                        connected_success = true;
                                        let limit = config_api::ensure_socket_reconnect_limit()
                                            .unwrap_or(config_api::DEFAULT_SOCKET_RECONNECT_LIMIT);
                                        let _ =
                                            config_api::set_socket_reconnect_attempts(limit);
                                        let _ = config_api::set_socket_reconnect_message(
                                            "socket 连接成功".into(),
                                        );
                                        notify_connection_success();
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
                            had_success: connected_success,
                        };
                    }
                    None => {
                        info!("socket stream ended");
                        return ConnectionOutcome::Disconnected {
                            message: Some("连接已关闭".into()),
                            had_success: connected_success,
                        };
                    }
                }
            }
        }
    }
    ConnectionOutcome::Shutdown
}

async fn send_auth(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
    config: &SocketConfig,
) -> Result<(), String> {
    let auth = AuthMsg {
        user_id: config.user_id,
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
    send_message(framed, auth).await
}

async fn send_heartbeat(
    framed: &mut Framed<TcpStream, LengthDelimitedCodec>,
) -> Result<(), String> {
    let mut content = msgpb::Content::default();
    content.heartbeat = Some(true);
    let payload_bytes = encode_message(content)?;
    let client_msg = ClientMsg {
        ack: None,
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
    if let Some(flag) = CONNECTION_SUCCESS.get() {
        flag.store(true, Ordering::SeqCst);
    }
    if let Some(waiters) = SUCCESS_WAITERS.get() {
        let mut guard = waiters.lock().unwrap();
        for tx in guard.drain(..) {
            let _ = tx.send(());
        }
    }
}

fn is_connection_success(content: &msgpb::SystemBusinessContent) -> bool {
    content.business_type == msgpb::SystemBusinessType::SystemBusinessUpgrade as i32
        && content.title == "连接成功"
}

fn test_mode_enabled() -> bool {
    env::var("FLUTTER_SDK_SOCKET_CLIENT_TEST_MODE")
        .map(|value| value == "1")
        .unwrap_or(false)
}

impl fmt::Debug for SocketClient {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let guard = self.inner.lock().map_err(|_| fmt::Error)?;
        f.debug_struct("SocketClient")
            .field("connected", &guard.is_some())
            .finish()
    }
}
