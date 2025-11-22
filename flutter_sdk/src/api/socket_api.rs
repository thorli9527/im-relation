use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use bytes::BytesMut;
use flutter_rust_bridge::frb;
use prost::Message;
use serde_json::{json, Value as JsonValue};

use crate::{
    api::errors::ApiError,
    domain::proto_adapter::{content_to_json, json_to_content},
    generated::message as msgpb,
    generated::socket as socket_proto,
};

/// 将 prost 消息编码为二进制字节，复用 BytesMut 减少分配。
fn encode<M: Message>(message: M) -> Result<Vec<u8>, String> {
    let mut buf = BytesMut::with_capacity(message.encoded_len());
    message
        .encode(&mut buf)
        .map_err(|err| ApiError::parse(format!("encode message: {err}")).into_string())?;
    Ok(buf.to_vec())
}

/// 从带有 raw base64 字段的 JSON 恢复 msgpb::Content。
/// JSON 需为 proto_adapter::content_to_json 生成的格式。
fn content_from_json(value: &JsonValue) -> Result<msgpb::Content, String> {
    json_to_content(value).map_err(|err| ApiError::parse(err).into_string())
}

/// 将下行情景 ServerMsg 打包成轻量 JSON，便于 Dart 解析。
fn server_msg_to_json(msg: socket_proto::ServerMsg) -> JsonValue {
    json!({
        "id": msg.id,
        "payload": STANDARD.encode(msg.payload),
        "ts_ms": msg.ts_ms,
    })
}

/// FRB 导出：把 Content 的 JSON 结构编码为 pb 字节；需传入 proto_adapter 生成的 JSON（包含 raw）。
#[frb]
pub fn encode_content(content: JsonValue) -> Result<Vec<u8>, String> {
    let payload = content_from_json(&content)?;
    encode(payload)
}

/// FRB 导出：解码 pb 字节为 JSON（经 proto_adapter），Flutter 收消息应调用此方法。
#[frb]
pub fn decode_content(bytes: Vec<u8>) -> Result<JsonValue, String> {
    let content = msgpb::Content::decode(bytes.as_slice())
        .map_err(|err| ApiError::parse(err.to_string()).into_string())?;
    Ok(content_to_json(&content))
}

/// 打包客户端上行 JSON 为 socket ClientMsg，ack/client_id 保持显式字段，payload 转换为 msgpb::Content。
#[frb]
pub fn pack_client_msg(
    payload: JsonValue,
    ack: Option<i64>,
    client_id: Option<i64>,
) -> Result<Vec<u8>, String> {
    let content = content_from_json(&payload)?;
    let pb = socket_proto::ClientMsg {
        ack,
        auth: None,
        payload: encode(content)?,
        client_id,
    };
    encode(pb)
}

/// 解包下行原始字节为 JSON，含消息 ID/时间戳/base64 载荷。
#[frb]
pub fn unpack_server_msg(bytes: Vec<u8>) -> Result<JsonValue, String> {
    let msg = socket_proto::ServerMsg::decode(bytes.as_slice())
        .map_err(|err| ApiError::parse(err.to_string()).into_string())?;
    Ok(server_msg_to_json(msg))
}
