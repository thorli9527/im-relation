use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};
use serde_json::Value as JsonValue;

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, normal_index, table_def};

pub fn init() {
    let _ = &*MESSAGE_TABLE_DEF;
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
#[repr(i64)]
pub enum MessageScene {
    Single = 0,
    Group = 1,
    System = 2,
}

impl Default for MessageScene {
    fn default() -> Self {
        MessageScene::Single
    }
}

impl From<i64> for MessageScene {
    fn from(value: i64) -> Self {
        match value {
            1 => MessageScene::Group,
            2 => MessageScene::System,
            _ => MessageScene::Single,
        }
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
#[repr(i64)]
pub enum MessageSource {
    Client = 0,
    Server = 1,
}

impl Default for MessageSource {
    fn default() -> Self {
        MessageSource::Client
    }
}

impl From<i64> for MessageSource {
    fn from(value: i64) -> Self {
        match value {
            1 => MessageSource::Server,
            _ => MessageSource::Client,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MessageEntity {
    /// 主键 ID（自增）
    pub id: Option<i64>,
    /// 会话 ID（关联 conversation 表）
    pub conversation_id: i64,
    /// 场景（单聊/群聊/系统）
    #[serde(default)]
    pub scene: MessageScene,
    /// 接收方 ID：单聊为对方 uid，群聊为群 ID
    pub receiver_id: Option<i64>,
    /// 发送者类型（例如 1-用户 2-系统）
    pub sender_type: i32,
    /// 发送者 ID
    pub sender_id: i64,
    /// 是否为会话消息（非系统）
    #[serde(default)]
    pub is_session_message: bool,
    /// 是否为聊天内容消息（用于过滤系统/业务消息）
    #[serde(default)]
    pub is_chat_message: bool,
    /// 消息内容
    pub content: JsonValue,
    /// 扩展数据（JSON）
    pub extra: String,
    /// 消息时间戳
    pub created_at: i64,
    /// 数据来源（客户端/服务端）
    #[serde(default)]
    pub data_source: MessageSource,
    /// 是否已经成功发送（客户端场景）
    #[serde(default)]
    pub sending_status: bool,
    /// ACK 状态
    #[serde(default)]
    pub ack_status: bool,
    /// 客户端发送次数
    #[serde(default)]
    pub send_count: i32,
}

impl MessageEntity {
    pub fn new(conversation_id: i64, sender_id: i64, content: serde_json::Value) -> Self {
        Self {
            id: None,
            conversation_id,
            scene: MessageScene::Single,
            receiver_id: None,
            sender_type: 1,
            sender_id,
            is_session_message: true,
            is_chat_message: true,
            content,
            extra: String::new(),
            created_at: 0,
            data_source: MessageSource::Client,
            sending_status: false,
            ack_status: false,
            send_count: 0,
        }
    }
}

impl TableEntity for MessageEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "conversation_id",
            Value::Integer(self.conversation_id),
        ));
        if let Some(rid) = self.receiver_id {
            cols.push(ColumnValue::new("receiver_id", Value::Integer(rid)));
        }
        cols.push(ColumnValue::new(
            "sender_type",
            Value::Integer(self.sender_type as i64),
        ));
        cols.push(ColumnValue::new("scene", Value::Integer(self.scene as i64)));
        cols.push(ColumnValue::new(
            "sender_id",
            Value::Integer(self.sender_id),
        ));
        cols.push(ColumnValue::new(
            "is_session_message",
            Value::Integer(self.is_session_message as i64),
        ));
        cols.push(ColumnValue::new(
            "is_chat_message",
            Value::Integer(self.is_chat_message as i64),
        ));
        cols.push(ColumnValue::new(
            "content",
            Value::Text(self.content.to_string()),
        ));
        cols.push(ColumnValue::new("extra", Value::Text(self.extra.clone())));
        cols.push(ColumnValue::new(
            "created_at",
            Value::Integer(self.created_at),
        ));
        cols.push(ColumnValue::new(
            "data_source",
            Value::Integer(self.data_source as i64),
        ));
        cols.push(ColumnValue::new(
            "sending_status",
            Value::Integer(self.sending_status as i64),
        ));
        cols.push(ColumnValue::new(
            "ack_status",
            Value::Integer(self.ack_status as i64),
        ));
        cols.push(ColumnValue::new(
            "send_count",
            Value::Integer(self.send_count as i64),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static MESSAGE_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "message",
        comment = "消息表",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!(
                "conversation_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "关联会话 ID"
            ),
            column_def!(
                "receiver_id",
                ColumnType::Integer,
                constraints = "NULL",
                comment = "接收方 ID（单聊为对方，群聊为群 ID）"
            ),
            column_def!(
                "sender_type",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "发送者类型"
            ),
            column_def!(
                "scene",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "消息场景"
            ),
            column_def!(
                "sender_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "发送者 ID"
            ),
            column_def!(
                "is_session_message",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 1",
                comment = "是否为会话消息"
            ),
            column_def!(
                "is_chat_message",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 1",
                comment = "是否聊天内容消息"
            ),
            column_def!(
                "content",
                ColumnType::Text,
                constraints = "NOT NULL",
                comment = "消息内容"
            ),
            column_def!(
                "extra",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "扩展数据"
            ),
            column_def!(
                "created_at",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "创建时间戳"
            ),
            column_def!(
                "data_source",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "数据来源"
            ),
            column_def!(
                "sending_status",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "发送状态"
            ),
            column_def!(
                "ack_status",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "ACK 状态"
            ),
            column_def!(
                "send_count",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "发送次数"
            )
        ],
        indexes = [
            normal_index!("idx_msg_scene_conversation_id", ["scene", "conversation_id"])
        ]
    }
});

pub fn message_table_def() -> &'static TableDef {
    &MESSAGE_TABLE_DEF
}
