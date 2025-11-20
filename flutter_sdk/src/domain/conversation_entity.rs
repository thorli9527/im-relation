use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, table_def, unique_index};

pub fn init() {
    let _ = &*CONVERSATION_TABLE_DEF;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ConversationEntity {
    /// 主键 ID，自增。
    pub id: Option<i64>,
    /// 会话类型：如私聊、群聊、系统等。
    pub conversation_type: i32,
    /// 会话目标 ID（好友 ID 或群 ID 等）。
    pub target_id: i64,
    /// 当前会话的未读消息数量。
    pub unread_count: i32,
    /// 最后一条消息的时间戳（秒）。
    pub last_message_time: i64,
    /// 最后一条消息的内容摘要。
    pub last_message_content: String,
}

impl ConversationEntity {
    pub fn new(conversation_type: i32, target_id: i64) -> Self {
        Self {
            id: None,
            conversation_type,
            target_id,
            unread_count: 0,
            last_message_time: 0,
            last_message_content: String::new(),
        }
    }
}

impl TableEntity for ConversationEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "conversation_type",
            Value::Integer(self.conversation_type as i64),
        ));
        cols.push(ColumnValue::new(
            "target_id",
            Value::Integer(self.target_id),
        ));
        cols.push(ColumnValue::new(
            "unread_count",
            Value::Integer(self.unread_count as i64),
        ));
        cols.push(ColumnValue::new(
            "last_message_time",
            Value::Integer(self.last_message_time),
        ));
        cols.push(ColumnValue::new(
            "last_message_content",
            Value::Text(self.last_message_content.clone()),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static CONVERSATION_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "conversation",
        comment = "会话表",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!(
                "conversation_type",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "会话类型：1-单聊 2-群聊 3-系统等"
            ),
            column_def!(
                "target_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "目标主体 ID（好友/群/系统）"
            ),
            column_def!(
                "unread_count",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "未读消息数量"
            ),
            column_def!(
                "last_message_time",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "最后一条消息的时间戳"
            ),
            column_def!(
                "last_message_content",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "最后一条消息内容摘要"
            )
        ],
        indexes = [
            unique_index!("idx_default", ["conversation_type", "target_id"])
        ]
    }
});

pub fn conversation_table_def() -> &'static TableDef {
    &CONVERSATION_TABLE_DEF
}
