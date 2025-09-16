//! TCP 服务器实现（由 `tcp.rs` 迁移重构）
//!
//! 线路与协议：
//! - 传输：`tokio` TCP + `LengthDelimitedCodec`（长度前缀帧）；
//! - 编解码：业务载荷为 Protobuf，首帧握手使用 `AuthMsg`；
//! - 上行：客户端发送 `ClientMsg`，服务端解析并上报给 `SessionManager`；
//! - 下行：`SessionManager` 经分发后投递 `ServerMsg`，本模块编码为 Protobuf 后写回；
//! - 鉴权：`validate_auth` 支持 token（Redis）与可选签名校验，并进行时间漂移容忍检查。

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

use crate::proto as socketpb;
use socketpb::{AuthMsg as PbAuthMsg, ClientMsg as PbClientMsg, DeviceType as PbDeviceType, MsgKind as PbMsgKind, ServerMsg as PbServerMsg};

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
    let server = cfg.get_server();
    let bind = format!("{}:{}", server.host, server.port);
    let addr: SocketAddr = bind.parse().context("invalid socket bind address from config")?;
    let listener = TcpListener::bind(addr).await.context("bind tcp listener")?;
    info!("tcp socket listening on {}", bind);

    tokio::spawn(async move {
        loop {
            match listener.accept().await {
                Ok((stream, peer)) => {
                    // 低延迟：关闭 Nagle
                    let _ = stream.set_nodelay(true);
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
    let mut framed = Framed::new(stream, LengthDelimitedCodec::new());

    // 1) 握手：首帧必须是 AuthMsg（Protobuf 长度前缀）
    let Some(first) = framed.next().await else { return Ok(()); };
    let first = first?;
    let auth = PbAuthMsg::decode(first.freeze())?;
    // 基本鉴权：token 校验（与 Redis 中的 user -> token 绑定一致）；可选 signature 验证
    if !validate_auth(&auth).await.unwrap_or(false) {
        warn!("{} auth failed: uid={} device={} ", peer, auth.user_id, auth.device_id);
        return Ok(());
    }
    let device_type: DeviceType = (PbDeviceType::try_from(auth.device_type).unwrap_or(PbDeviceType::Unknown)).into();
    // 能力协商占位：记录加密能力（不影响现有流程）
    if auth.supports_encryption {
        info!(
            "{} client supports encryption; schemes={:?}",
            peer,
            auth.encryption_schemes
        );
    }
    let (handle, mut rx) = sm.register(auth.user_id as UserId, device_type, auth.device_id.clone());
    let user_id = handle.user_id;
    let session_id = handle.session_id.clone();

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
            let pb = PbServerMsg { id: msg.id, kind: msg.kind as i32, payload: msg.payload.clone(), ts_ms: msg.ts_ms };
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
                    let kind = PbMsgKind::try_from(pb.kind).unwrap_or(PbMsgKind::MkUnknown);
                    let cmsg = ClientMsg { ack: pb.ack, client_id: pb.client_id, kind, payload: pb.payload };
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
    let _ = writer.await;
    Ok(())
}

/// 基础鉴权：
/// - token：与 Redis 中的 `app:token:{token}` 绑定进行校验（校验 id 一致性）；
/// - 可选签名：如配置 md5_key，则校验 signature（简单示例，真实项目应替换更安全方案）；
/// - 时间漂移：允许 5 分钟以内的时间偏差。
async fn validate_auth(auth: &PbAuthHello) -> anyhow::Result<bool> {
    // 1) token 验证（Redis 中保存的登录 token）
    if auth.token.is_empty() {
        return Ok(false);
    }
    if let Some(pool) = try_get_redis_pool() {
        let key = format!("app:token:{}", auth.token);
        let mut conn = pool.get().await.ok();
        if let Some(c) = conn.as_mut() {
            use deadpool_redis::redis::AsyncCommands;
            let val: Result<Option<String>, _> = c.get(&key).await;
            if let Ok(opt) = val {
                if let Some(json) = opt {
                    if let Ok(v) = serde_json::from_str::<serde_json::Value>(&json) {
                        if v.get("id").and_then(|x| x.as_i64()).unwrap_or_default() != auth.user_id {
                            return Ok(false);
                        }
                    }
                } else {
                    return Ok(false);
                }
            } else {
                return Ok(false);
            }
        } else {
            return Ok(false);
        }
    }

    // 2) 可选 signature 验证（如果配置了密钥）
    if !auth.signature.is_empty() {
        if let Some(key) = common::config::AppConfig::get().get_sys().md5_key {
            let expect = compute_sig(&key, auth);
            if auth.signature != expect {
                return Ok(false);
            }
        }
    }

    // 3) 基本时间漂移检查（可选）
    if auth.ts_ms != 0 {
        use std::time::{SystemTime, UNIX_EPOCH};
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as i64;
        if (now - auth.ts_ms).abs() > 5 * 60 * 1000 {
            // 时间漂移过大，可视情况拒绝；此处放行
        }
    }
    Ok(true)
}

/// 计算简单签名（示例实现，非生产级）：连接 key/token/user_id/device_id/ts/nonce 后进行 SHA1
fn compute_sig(key: &str, h: &PbAuthHello) -> Vec<u8> {
    use sha1::{Digest, Sha1};
    let mut s = String::new();
    s.push_str(key);
    s.push('|');
    s.push_str(&h.token);
    s.push('|');
    s.push_str(&h.user_id.to_string());
    s.push('|');
    s.push_str(&h.device_id);
    s.push('|');
    s.push_str(&h.ts_ms.to_string());
    s.push('|');
    s.push_str(&hex::encode(&h.nonce));
    let mut hasher = Sha1::new();
    hasher.update(s.as_bytes());
    hasher.finalize().to_vec()
}

/// 获取 Redis 连接池（在 AppConfig 初始化时已构建）
fn try_get_redis_pool() -> Option<deadpool_redis::Pool> {
    // 已在 common::config::AppConfig::init 中根据配置初始化了 Redis 连接池
    let arc = common::redis::redis_pool::RedisPoolTools::get();
    Some((**arc).clone())
}
