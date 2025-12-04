//!
//! 线路与协议：
//! - 传输：`tokio` TCP + `LengthDelimitedCodec`（长度前缀帧）；
//! - 编解码：业务载荷为 Protobuf，首帧握手使用 `ClientMsg.auth` 携带 `AuthMsg`；
//! - 上行：客户端发送 `ClientMsg`，服务端解析并上报给 `SessionManager`；
//! - 下行：`SessionManager` 经分发后投递 `ServerMsg`，本模块编码为 Protobuf 后写回；
//! - 鉴权：调用 hot_online_service 校验 session_token，确保设备唯一并遵守 15 天 TTL。

use anyhow::{anyhow, Context};
use bytes::BytesMut;
use futures_util::{SinkExt, StreamExt};
use log::{error, info, warn};
use prost::Message;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::net::SocketAddr;
use tokio::net::TcpListener;
use tokio::task::JoinHandle;
use tokio::time::Instant;
use tokio_util::codec::{Framed, LengthDelimitedCodec};

use crate::service::grpc_clients;
use crate::service::node_discovery::{
    fetch_msg_friend_addr, fetch_node_addr, resolve_hot_online_addr,
};
use common::infra::grpc::grpc_socket::socket as socket_proto;
use common::infra::grpc::grpc_user::online_service::{
    SessionTokenStatus, UpdateUserReq, UserEntity, ValidateSessionTokenRequest,
};
use common::infra::grpc::message as msgpb;
use common::support::node::NodeType;
use prost_types::FieldMask;
use socket_proto::{AuthMsg as PbAuthMsg, ClientMsg as PbClientMsg, ServerMsg as PbServerMsg};
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tonic::Request;

use crate::service::session::{SessionHandle, SessionManager};
use crate::service::types::{ClientMsg, DeviceType, SendOpts, ServerMsg, UID};

const HEARTBEAT_TIMEOUT: Duration = Duration::from_secs(180);

/// 启动 TCP 服务监听（端口从配置文件 socket.server.host/port 读取）
///
/// 行为：
/// - 监听配置地址；
/// - 为每个新连接关闭 Nagle 提升低延迟；
/// - 为每个连接启动独立 task 执行握手、读写循环与清理。
pub async fn start_tcp_server() -> anyhow::Result<()> {
    let cfg = common::config::AppConfig::get();
    let socket_cfg = cfg.get_socket();
    let node_index = socket_cfg.index();
    let bind = socket_cfg
        .tcp_addr()
        .context("socket tcp address missing (set socket.addr or socket.host+socket.port)")?;
    // 尝试在 Tokio runtime 上监听 TCP 端口（失败直接返回错误以便上层中止启动流程）。
    let listener = TcpListener::bind(&bind)
        .await
        .context("bind tcp listener")?;
    warn!(
        "TCP socket server listening on {} (index={})",
        bind, node_index
    );

    tokio::spawn(async move {
        loop {
            match listener.accept().await {
                Ok((stream, peer)) => {
                    // 低延迟：关闭 Nagle
                    let _ = stream.set_nodelay(true);
                    // 每个连接交由独立任务处理，避免单连接阻塞影响其他客户端。
                    tokio::spawn(async move {
                        if let Err(e) = handle_conn(stream, peer).await {
                            warn!("conn {} closed with error: {:?}", peer, e);
                        }
                    });
                }
                Err(e) => {
                    error!("accept error: {:?}", e);
                }
            }
        }
    });

    Ok(())
}

/// 处理单个 TCP 连接：握手 → 写协程 → 读循环 → 清理
async fn handle_conn(stream: tokio::net::TcpStream, peer: SocketAddr) -> anyhow::Result<()> {
    let sm = SessionManager::get();
    // 使用 LengthDelimitedCodec 将 TCP 字节流封装为“长度前缀帧”。
    let mut framed = Framed::new(stream, LengthDelimitedCodec::new());

    // 1) 握手：首帧必须是 ClientMsg，携带 auth（payload 可为空或业务 Content）
    let Some(first) = framed.next().await else {
        // 对端主动断开或未发送任何内容，直接结束即可。
        return Ok(());
    };
    let first = first?;
    let shell = PbClientMsg::decode(first.freeze())?;
    let auth = shell
        .auth
        .as_ref()
        .ok_or_else(|| anyhow!("first frame missing auth payload"))?;
    // 基本鉴权：token 校验（与 Redis 中的 user -> token 绑定一致）；可选 signature 验证
    let token_expiry_ms = match validate_auth(&auth).await {
        Ok(Some(exp)) => exp,
        Ok(None) => {
            warn!(
                "{} auth failed: uid={} device={},token:{} ",
                peer, auth.uid, auth.device_id, auth.token
            );
            return Ok(());
        }
        Err(e) => {
            warn!(
                "{} auth validate error: uid={} device={} err={:?}",
                peer, auth.uid, auth.device_id, e
            );
            return Ok(());
        }
    };
    let device_type: DeviceType =
        msgpb::DeviceType::try_from(auth.device_type).unwrap_or(msgpb::DeviceType::Unknown);
    // 能力协商占位：记录加密能力（不影响现有流程）
    if auth.supports_encryption {
        info!(
            "{} client supports encryption; schemes={:?}",
            peer, auth.encryption_schemes
        );
    }
    let (handle, mut rx) = sm.register(
        auth.uid as UID,
        device_type.clone(),
        auth.device_id.clone(),
        auth.token.clone(),
        token_expiry_ms,
    );
    let user_id = handle.user_id;
    let session_id = handle.session_id.clone();

    warn!(
        "{} auth success: uid={} device_id={} device_type={:?} resume={} last_ack={}",
        peer, user_id, auth.device_id, device_type, auth.resume, auth.last_ack_id
    );

    send_connection_success(&handle);

    // split 将 Framed 拆为 sink (写端) 与 stream (读端)，便于分别驱动写协程和读循环。
    let (mut sink, mut stream) = framed.split();

    // 断线重连快速补发：若客户端声明 resume 并带上 last_ack_id，则从 backlog 进行快速补发
    #[allow(clippy::let_and_return)]
    {
        if auth.resume && auth.last_ack_id != 0 {
            let resent = sm.resend_since(&user_id, auth.last_ack_id, &handle);
            if resent > 0 {
                info!("{} resume resent={} uid={}", peer, resent, user_id);
            }
        }
    }

    // 2) 写协程：将 SessionManager 的下行 ServerMsg 转为 Protobuf 并写回。
    // 重要：SessionManager/dispatcher 会在收到客户端的 socket ACK 后执行 ack_hook，
    // 以提交 Kafka offset。这里仅负责写出和接收 ACK，不直接触碰 Kafka。
    let writer: JoinHandle<anyhow::Result<()>> = tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            // 将内部结构转换为 Protobuf，再交由 LengthDelimitedCodec 写入 TCP。
            let pb = PbServerMsg {
                id: msg.id,
                auth: msg.auth.clone(),
                payload: msg.raw_payload.clone(),
                ts_ms: msg.ts_ms,
            };
            let mut buf = BytesMut::with_capacity(pb.encoded_len());
            pb.encode(&mut buf)?; // 编码原始消息体，由 LengthDelimitedCodec 负责加长度前缀
            sink.send(buf.freeze()).await.context("send server msg")?;
        }
        Ok(())
    });

    // 3) 读循环：消费客户端上行 ClientMsg（含 ACK）并检测心跳
    let heartbeat_timer = tokio::time::sleep(HEARTBEAT_TIMEOUT);
    tokio::pin!(heartbeat_timer);
    heartbeat_timer
        .as_mut()
        .reset(Instant::now() + HEARTBEAT_TIMEOUT);

    let mut heartbeat_timed_out = false;

    loop {
        tokio::select! {
            _ = &mut heartbeat_timer => {
                warn!(
                    "{} heartbeat timeout exceeded {}s, closing connection uid={} sid={}",
                    peer,
                    HEARTBEAT_TIMEOUT.as_secs(),
                    user_id,
                    session_id
                );
                heartbeat_timed_out = true;
                break;
            }
            frame = stream.next() => {
                match frame {
                    Some(Ok(bytes)) => {
                        match PbClientMsg::decode(bytes.freeze()) {
                            Ok(pb) => {
                                heartbeat_timer
                                    .as_mut()
                                    .reset(Instant::now() + HEARTBEAT_TIMEOUT);
                                if let Some(ack_id) = pb.ack {
                                    info!("{} <- ack {} uid={}", peer, ack_id, user_id);
                                }
                                let raw_payload = pb.payload;
                                let payload =
                                    msgpb::Content::decode(raw_payload.as_slice()).unwrap_or_default();
                                let client_msg = ClientMsg {
                                    ack: pb.ack,
                                    client_id: pb.client_id,
                                    payload: payload.clone(),
                                    raw_payload,
                                };
                                if payload.heartbeat.unwrap_or(false) {
                                    continue;
                                }

                                if client_msg.ack.is_some() {
                                    SessionManager::get().on_client_msg(user_id, client_msg);
                                    continue;
                                }

                                let ref_message_id = payload.message_id;
                                if payload.friend_business.is_some() {
                                    spawn_friend_forward(user_id, payload.clone(), ref_message_id);
                                    continue;
                                }
                                if payload.group_business.is_some() {
                                    spawn_group_forward(user_id, payload.clone(), ref_message_id);
                                    continue;
                                }
                                if let Some(profile_update) = find_profile_event(&payload) {
                                    spawn_profile_event(user_id, profile_update, ref_message_id);
                                    continue;
                                }
                                if payload.system_business.is_some() {
                                    spawn_system_business(
                                        user_id,
                                        payload.system_business.clone(),
                                        ref_message_id,
                                    );
                                    continue;
                                }

                                match msgpb::ChatScene::try_from(payload.scene) {
                                    Ok(msgpb::ChatScene::Single) => {
                                        let domain = build_domain_message(&payload);
                                        tokio::spawn(async move {
                                            if let Err(err) = forward_friend_message(domain).await {
                                                warn!("friend msg forward failed: {}", err);
                                            } else {
                                                send_client_ack(user_id, ref_message_id);
                                            }
                                        });
                                    }
                                    Ok(msgpb::ChatScene::Group) => {
                                        let domain = build_domain_message(&payload);
                                        tokio::spawn(async move {
                                            if let Err(err) = forward_group_message(domain).await {
                                                warn!("group msg forward failed: {}", err);
                                            } else {
                                                send_client_ack(user_id, ref_message_id);
                                            }
                                        });
                                    }
                                    _ => {
                                        SessionManager::get().on_client_msg(user_id, client_msg);
                                    }
                                }
                            }
                            Err(e) => {
                                warn!("{} invalid client msg: {:?}", peer, e);
                            }
                        }
                    }
                    Some(Err(e)) => {
                        warn!("{} read error: {:?}", peer, e);
                        break;
                    }
                    None => break,
                }
            }
        }
    }

    // 4) 清理：注销会话并等待写协程结束
    sm.unregister(&user_id, &session_id);
    // ensure writer ends
    // 若写协程尚未结束（可能因 channel close），此处等待以释放资源。
    if heartbeat_timed_out {
        writer.abort();
    }
    let _ = writer.await;
    Ok(())
}

fn build_domain_message(content: &msgpb::Content) -> msgpb::DomainMessage {
    let scene = msgpb::ChatScene::try_from(content.scene).unwrap_or(msgpb::ChatScene::ChatUnknown);
    let category = match scene {
        msgpb::ChatScene::Single => msgpb::MsgCategory::Friend,
        msgpb::ChatScene::Group => msgpb::MsgCategory::Group,
        _ => {
            if content.friend_business.is_some() {
                msgpb::MsgCategory::Friend
            } else if content.group_business.is_some() {
                msgpb::MsgCategory::Group
            } else {
                msgpb::MsgCategory::System
            }
        }
    };

    msgpb::DomainMessage {
        message_id: content.message_id,
        sender_id: content.sender_id,
        receiver_id: content.receiver_id,
        timestamp: content.timestamp,
        ts_ms: content.timestamp,
        delivery: None,
        scene: content.scene,
        category: category as i32,
        contents: content.contents.clone(),
        friend_business: content.friend_business.clone(),
        group_business: content.group_business.clone(),
        system_business: content.system_business.clone(),
    }
}

async fn forward_friend_message(domain: msgpb::DomainMessage) -> anyhow::Result<()> {
    let addr = fetch_msg_friend_addr()
        .await?
        .ok_or_else(|| anyhow!("msg_friend address missing"))?;
    let mut client = grpc_clients::friend_msg_client(&addr)
        .await
        .context("connect to msg_friend failed")?;
    client
        .handle_friend_message(Request::new(domain))
        .await
        .context("handle_friend_message rpc failed")?;
    Ok(())
}

async fn forward_group_message(domain: msgpb::DomainMessage) -> anyhow::Result<()> {
    let addr = fetch_node_addr(NodeType::MesGroup)
        .await?
        .ok_or_else(|| anyhow!("msg_group address missing"))?;
    let mut client = grpc_clients::group_msg_client(&addr)
        .await
        .context("connect to msg_group failed")?;
    client
        .handle_group_message(Request::new(domain))
        .await
        .context("handle_group_message rpc failed")?;
    Ok(())
}

fn spawn_friend_forward(user_id: UID, payload: msgpb::Content, ref_message_id: Option<u64>) {
    let domain = build_domain_message(&payload);
    tokio::spawn(async move {
        if let Err(err) = forward_friend_message(domain).await {
            warn!("friend msg forward failed: {}", err);
        } else {
            send_client_ack(user_id, ref_message_id);
        }
    });
}

fn spawn_group_forward(user_id: UID, payload: msgpb::Content, ref_message_id: Option<u64>) {
    let domain = build_domain_message(&payload);
    tokio::spawn(async move {
        if let Err(err) = forward_group_message(domain).await {
            warn!("group msg forward failed: {}", err);
        } else {
            send_client_ack(user_id, ref_message_id);
        }
    });
}

fn spawn_profile_event(
    user_id: UID,
    profile: msgpb::ProfileEventContent,
    ref_message_id: Option<u64>,
) {
    tokio::spawn(async move {
        if let Err(err) = handle_profile_event(user_id, profile).await {
            warn!("profile event failed: {}", err);
        } else {
            send_client_ack(user_id, ref_message_id);
        }
    });
}

fn spawn_system_business(
    user_id: UID,
    business: Option<msgpb::SystemBusinessContent>,
    ref_message_id: Option<u64>,
) {
    let business = match business {
        Some(b) => b,
        None => return,
    };
    tokio::spawn(async move {
        if let Err(err) = handle_system_business(user_id, business).await {
            warn!("system business handling failed: {}", err);
        } else {
            send_client_ack(user_id, ref_message_id);
        }
    });
}

fn find_profile_event(payload: &msgpb::Content) -> Option<msgpb::ProfileEventContent> {
    payload
        .contents
        .iter()
        .find_map(|item| match &item.content {
            Some(msgpb::message_content::Content::ProfileUpdate(update)) => Some(update.clone()),
            _ => None,
        })
}

async fn handle_profile_event(
    user_id: UID,
    profile: msgpb::ProfileEventContent,
) -> anyhow::Result<()> {
    let addr = resolve_hot_online_addr().await?;
    let mut client = grpc_clients::user_rpc_client(&addr)
        .await
        .context("connect to user rpc failed")?;

    let event_type = msgpb::profile_event_content::ProfileEventType::try_from(profile.event_type)
        .unwrap_or(msgpb::profile_event_content::ProfileEventType::EventUnknown);
    let new_value = profile.new_value;

    let mut patch = build_profile_user_patch(user_id);
    let mut paths = Vec::new();

    match event_type {
        msgpb::profile_event_content::ProfileEventType::EventName => {
            patch.name = new_value;
            paths.push("name".to_string());
        }
        msgpb::profile_event_content::ProfileEventType::EventAvatar => {
            patch.avatar = new_value;
            paths.push("avatar".to_string());
        }
        msgpb::profile_event_content::ProfileEventType::EventEmail => {
            patch.email = Some(new_value);
            paths.push("email".to_string());
        }
        msgpb::profile_event_content::ProfileEventType::EventPhone => {
            patch.phone = Some(new_value);
            paths.push("phone".to_string());
        }
        msgpb::profile_event_content::ProfileEventType::EventLogout => {
            info!("user {} requested logout via profile event", user_id);
            return Ok(());
        }
        _ => return Ok(()),
    }

    if paths.is_empty() {
        return Ok(());
    }

    let req = UpdateUserReq {
        patch: Some(patch),
        update_mask: Some(FieldMask { paths }),
    };
    client
        .update_user(Request::new(req))
        .await
        .context("update user profile via socket failed")?;
    Ok(())
}

fn build_profile_user_patch(user_id: UID) -> UserEntity {
    UserEntity {
        id: user_id,
        password: String::new(),
        name: String::new(),
        email: None,
        phone: None,
        language: None,
        country: None,
        nickname: None,
        avatar: String::new(),
        allow_add_friend: 0,
        gender: 0,
        user_type: 0,
        profile_fields: HashMap::new(),
        create_time: 0,
        update_time: 0,
        version: 0,
    }
}

async fn handle_system_business(
    user_id: UID,
    business: msgpb::SystemBusinessContent,
) -> anyhow::Result<()> {
    info!(
        "user {} system business received: type={} title={}",
        user_id, business.business_type, business.title
    );
    Ok(())
}

fn send_client_ack(user_id: UID, ref_message_id: Option<u64>) {
    let ts_ms = current_time_millis();
    let mut payload = msgpb::Content::default();
    payload.ack = Some(msgpb::AckContent {
        ok: true,
        code: 0,
        message: "forwarded".to_string(),
        ref_message_id,
        extra: Vec::new(),
    });
    let raw_payload = payload.encode_to_vec();
    let msg = ServerMsg {
        id: ts_ms,
        auth: None,
        payload,
        raw_payload,
        ts_ms,
    };
    let opts = SendOpts {
        require_ack: false,
        ..Default::default()
    };
    let _ = SessionManager::get().send_to_user(user_id, msg, opts);
}

fn send_connection_success(handle: &SessionHandle) {
    let ts_ms = current_time_millis();
    let auth = PbAuthMsg {
        uid: handle.user_id,
        device_type: handle.device_type as i32,
        device_id: handle.device_id.clone(),
        token: handle.session_token.clone(),
        ts_ms,
        nonce: Vec::new(),
        signature: Vec::new(),
        resume: false,
        last_ack_id: 0,
        supports_encryption: false,
        encryption_schemes: Vec::new(),
    };

    let msg = ServerMsg {
        id: ts_ms,
        payload: msgpb::Content::default(),
        raw_payload: Vec::new(),
        ts_ms,
        auth: Some(auth),
    };
    let _ = handle.send(msg);
}

fn current_time_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as i64
}

/// 基础鉴权：
/// - token：与 Redis 中的 `app:token:{token}` 绑定进行校验（校验 id 一致性）；
/// - 可选签名：如配置 md5_key，则校验 signature（简单示例，真实项目应替换更安全方案）；
/// - 时间漂移：允许 5 分钟以内的时间偏差。
pub(super) async fn validate_auth(auth: &PbAuthMsg) -> anyhow::Result<Option<i64>> {
    if auth.token.is_empty() {
        return Ok(None);
    }

    let addr = resolve_hot_online_addr().await?;
    let mut client = grpc_clients::online_client(&addr).await?;
    let resp = client
        .validate_session_token(ValidateSessionTokenRequest {
            session_token: auth.token.clone(),
        })
        .await?
        .into_inner();

    if resp.status != SessionTokenStatus::StsActive as i32 {
        log::warn!(
            "validate_auth: inactive token (status={}), uid={}, device={}",
            resp.status,
            resp.uid,
            resp.device_id
        );
        return Ok(None);
    }
    if resp.uid != auth.uid {
        log::warn!(
            "validate_auth: uid mismatch token_uid={} auth_uid={}",
            resp.uid,
            auth.uid
        );
        return Ok(None);
    }
    if resp.device_type != auth.device_type {
        log::warn!(
            "validate_auth: device_type mismatch token_type={} auth_type={}",
            resp.device_type,
            auth.device_type
        );
        return Ok(None);
    }
    if resp.device_id != auth.device_id {
        log::warn!(
            "validate_auth: device_id mismatch token_device={} auth_device={}",
            resp.device_id,
            auth.device_id
        );
        return Ok(None);
    }

    // 时间漂移容忍：仅用于日志记录，目前不拦截
    if auth.ts_ms != 0 {
        use std::time::{SystemTime, UNIX_EPOCH};
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as i64;
        if (now - auth.ts_ms).abs() > 5 * 60 * 1000 {
            log::warn!("auth timestamp drift detected: uid={}", auth.uid);
        }
    }

    Ok(Some(resp.expires_at as i64))
}
