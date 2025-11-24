use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use prost::Message;
use serde_json::{json, Map, Value as JsonValue};

use crate::generated::message as msgpb;

pub(crate) fn content_to_json(content: &msgpb::Content) -> JsonValue {
    let mut map = Map::new();
    if let Some(id) = content.message_id {
        map.insert("message_id".to_string(), json!(id));
    }
    map.insert("sender_id".to_string(), json!(content.sender_id));
    map.insert("receiver_id".to_string(), json!(content.receiver_id));
    map.insert("timestamp".to_string(), json!(content.timestamp));
    map.insert("scene".to_string(), json!(content.scene));
    map.insert(
        "contents".to_string(),
        JsonValue::Array(
            content
                .contents
                .iter()
                .map(message_content_to_json)
                .collect(),
        ),
    );
    map_insert_opt(
        &mut map,
        "friend_business",
        content.friend_business.as_ref(),
        |fb| business_to_json(fb),
    );
    map_insert_opt(
        &mut map,
        "group_business",
        content.group_business.as_ref(),
        |gb| business_to_json(gb),
    );
    if let Some(heartbeat) = content.heartbeat {
        map.insert("heartbeat".to_string(), json!(heartbeat));
    }
    map_insert_opt(&mut map, "ack", content.ack.as_ref(), ack_to_json);
    map_insert_opt(
        &mut map,
        "system_business",
        content.system_business.as_ref(),
        |sys| system_business_to_json(sys),
    );
    map.insert("raw".to_string(), json!(encode_raw(content)));
    JsonValue::Object(map)
}

fn map_insert_opt<T, F>(map: &mut Map<String, JsonValue>, key: &str, value: Option<&T>, f: F)
where
    F: FnOnce(&T) -> JsonValue,
{
    if let Some(inner) = value {
        map.insert(key.to_string(), f(inner));
    }
}

fn message_content_to_json(content: &msgpb::MessageContent) -> JsonValue {
    let mut map = Map::new();
    let (tag, type_label) = match &content.content {
        Some(msgpb::message_content::Content::Text(_)) => (1, "text"),
        Some(msgpb::message_content::Content::Image(_)) => (2, "image"),
        Some(msgpb::message_content::Content::Audio(_)) => (3, "audio"),
        Some(msgpb::message_content::Content::Video(_)) => (4, "video"),
        Some(msgpb::message_content::Content::Location(_)) => (5, "location"),
        Some(msgpb::message_content::Content::File(_)) => (6, "file"),
        Some(msgpb::message_content::Content::AvCall(_)) => (7, "av_call"),
        Some(msgpb::message_content::Content::Custom(_)) => (8, "custom"),
        Some(msgpb::message_content::Content::Emoji(_)) => (9, "emoji"),
        Some(msgpb::message_content::Content::Revoke(_)) => (10, "revoke"),
        Some(msgpb::message_content::Content::Forward(_)) => (11, "forward"),
        Some(msgpb::message_content::Content::Quote(_)) => (12, "quote"),
        Some(msgpb::message_content::Content::Html(_)) => (13, "html"),
        Some(msgpb::message_content::Content::Voip(_)) => (14, "voip"),
        Some(msgpb::message_content::Content::Notification(_)) => (15, "notification"),
        Some(msgpb::message_content::Content::Reminder(_)) => (17, "reminder"),
        Some(msgpb::message_content::Content::GroupEvent(_)) => (18, "group_event"),
        Some(msgpb::message_content::Content::FriendEvent(_)) => (24, "friend_event"),
        Some(msgpb::message_content::Content::ContactCard(_)) => (19, "contact_card"),
        Some(msgpb::message_content::Content::Vote(_)) => (20, "vote"),
        Some(msgpb::message_content::Content::RedEnvelope(_)) => (21, "red_envelope"),
        Some(msgpb::message_content::Content::Delete(_)) => (22, "delete"),
        Some(msgpb::message_content::Content::ProfileUpdate(_)) => (27, "profile_update"),
        None => (-1, "unknown"),
    };
    map.insert("type".to_string(), json!(type_label));
    map.insert("tag".to_string(), json!(tag));
    map.insert("raw".to_string(), json!(encode_raw(content)));
    JsonValue::Object(map)
}

fn business_to_json<M: Message>(message: &M) -> JsonValue {
    json!({ "raw": encode_raw(message) })
}

fn ack_to_json(ack: &msgpb::AckContent) -> JsonValue {
    json!({
        "ok": ack.ok,
        "code": ack.code,
        "message": ack.message,
        "ref_message_id": ack.ref_message_id,
        "extra": encode_raw(ack),
    })
}

fn system_business_to_json(sys: &msgpb::SystemBusinessContent) -> JsonValue {
    json!({
        "business_type": sys.business_type,
        "title": sys.title,
        "detail": sys.detail,
        "raw": encode_raw(sys),
    })
}

fn encode_raw<T: Message>(message: &T) -> String {
    STANDARD.encode(message.encode_to_vec())
}

pub(crate) fn json_to_content(value: &JsonValue) -> Result<msgpb::Content, String> {
    let raw = value
        .get("raw")
        .and_then(|v| v.as_str())
        .ok_or("content.raw is required")?;
    let bytes = STANDARD
        .decode(raw)
        .map_err(|err| format!("decode content.raw: {err}"))?;
    msgpb::Content::decode(bytes.as_slice()).map_err(|err| err.to_string())
}
