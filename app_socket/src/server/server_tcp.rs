//!
//! 线路与协议：
//! - 传输：`tokio` TCP + `LengthDelimitedCodec`（长度前缀帧）；
//! - 编解码：业务载荷为 Protobuf，首帧握手使用 `AuthMsg`；
//! - 上行：客户端发送 `ClientMsg`，服务端解析并上报给 `SessionManager`；
//! - 下行：`SessionManager` 经分发后投递 `ServerMsg`，本模块编码为 Protobuf 后写回；
//! - 鉴权：调用 hot_online_service 校验 session_token，确保设备唯一并遵守 15 天 TTL。

use anyhow::Context;
use bytes::BytesMut;
use futures_util::{SinkExt, StreamExt};
use log::{error, info, warn};
use prost::Message;
use std::convert::TryFrom;
use std::net::SocketAddr;
use tokio::net::TcpListener;
use tokio::task::JoinHandle;
use tokio_util::codec::{Framed, LengthDelimitedCodec};

use crate::service::grpc_clients;
use crate::service::node_discovery::resolve_hot_online_addr;
use common::grpc::grpc_hot_online::online_service::{
    SessionTokenStatus, ValidateSessionTokenRequest,
};
use common::grpc::grpc_socket::socket as socket_proto;
use socket_proto::{
    AuthMsg as PbAuthMsg, ClientMsg as PbClientMsg, DeviceType as PbDeviceType,
    MsgKind as PbMsgKind, ServerMsg as PbServerMsg,
};

use crate::service::session::SessionManager;
use crate::service::types::{ClientMsg, DeviceType, UserId};

impl From<PbDeviceType> for DeviceType {
    fn from(v: PbDeviceType) -> Self {
        match v {
            PbDeviceType::Mobile => DeviceType::Mobile,
            PbDeviceType::Web => DeviceType::Web,
            PbDeviceType::Pc => DeviceType::Pc,
            _ => DeviceType::Unknown,
        }
    }
}

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
    info!("tcp socket listening on {} (index={})", bind, node_index);

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

    // 1) 握手：首帧必须是 AuthMsg（Protobuf 长度前缀）
    let Some(first) = framed.next().await else {
        // 对端主动断开或未发送任何内容，直接结束即可。
        return Ok(());
    };
    let first = first?;
    let auth = PbAuthMsg::decode(first.freeze())?;
    // 基本鉴权：token 校验（与 Redis 中的 user -> token 绑定一致）；可选 signature 验证
    let token_expiry_ms = match validate_auth(&auth).await {
        Ok(Some(exp)) => exp,
        Ok(None) => {
            warn!(
                "{} auth failed: uid={} device={} ",
                peer, auth.user_id, auth.device_id
            );
            return Ok(());
        }
        Err(e) => {
            warn!(
                "{} auth validate error: uid={} device={} err={:?}",
                peer, auth.user_id, auth.device_id, e
            );
            return Ok(());
        }
    };
    let device_type: DeviceType =
        (PbDeviceType::try_from(auth.device_type).unwrap_or(PbDeviceType::Unknown)).into();
    // 能力协商占位：记录加密能力（不影响现有流程）
    if auth.supports_encryption {
        info!(
            "{} client supports encryption; schemes={:?}",
            peer, auth.encryption_schemes
        );
    }
    let (handle, mut rx) = sm.register(
        auth.user_id as UserId,
        device_type,
        auth.device_id.clone(),
        auth.token.clone(),
        token_expiry_ms,
    );
    let user_id = handle.user_id;
    let session_id = handle.session_id.clone();

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

    // 2) 写协程：将 SessionManager 的下行 ServerMsg 转为 Protobuf 并写回
    let writer: JoinHandle<anyhow::Result<()>> = tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            // 将内部结构转换为 Protobuf，再交由 LengthDelimitedCodec 写入 TCP。
            let pb = PbServerMsg {
                id: msg.id,
                kind: msg.kind as i32,
                payload: msg.payload.clone(),
                ts_ms: msg.ts_ms,
            };
            let mut buf = BytesMut::with_capacity(pb.encoded_len());
            pb.encode(&mut buf)?; // 编码原始消息体，由 LengthDelimitedCodec 负责加长度前缀
            sink.send(buf.freeze()).await.context("send server msg")?;
        }
        Ok(())
    });

    // 3) 读循环：消费客户端上行 ClientMsg（含 ACK），仅将 ACK 上报给 SessionManager
    while let Some(frame) = stream.next().await {
        match frame {
            Ok(bytes) => match PbClientMsg::decode(bytes.freeze()) {
                Ok(pb) => {
                    // 尝试将枚举值转换为定义的 MsgKind；未知值使用 MkUnknown 兜底。
                    let kind = PbMsgKind::try_from(pb.kind).unwrap_or(PbMsgKind::MkUnknown);
                    let cmsg = ClientMsg {
                        ack: pb.ack,
                        client_id: pb.client_id,
                        kind,
                        payload: pb.payload,
                    };
                    // 上报给 SessionManager：包含 ACK 处理与业务分发。
                    sm.on_client_msg(user_id, cmsg);
                }
                Err(e) => {
                    warn!("{} invalid client msg: {:?}", peer, e);
                }
            },
            Err(e) => {
                warn!("{} read error: {:?}", peer, e);
                break;
            }
        }
    }

    // 4) 清理：注销会话并等待写协程结束
    sm.unregister(&user_id, &session_id);
    // ensure writer ends
    // 若写协程尚未结束（可能因 channel close），此处等待以释放资源。
    let _ = writer.await;
    Ok(())
}

/// 基础鉴权：
/// - token：与 Redis 中的 `app:token:{token}` 绑定进行校验（校验 id 一致性）；
/// - 可选签名：如配置 md5_key，则校验 signature（简单示例，真实项目应替换更安全方案）；
/// - 时间漂移：允许 5 分钟以内的时间偏差。
async fn validate_auth(auth: &PbAuthMsg) -> anyhow::Result<Option<i64>> {
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
        return Ok(None);
    }
    if resp.user_id != auth.user_id {
        return Ok(None);
    }
    if resp.device_type != auth.device_type {
        return Ok(None);
    }
    if resp.device_id != auth.device_id {
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
            log::warn!("auth timestamp drift detected: uid={}", auth.user_id);
        }
    }

    Ok(Some(resp.expires_at as i64))
}
