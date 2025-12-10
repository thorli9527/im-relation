use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, normal_index, table_def};

pub fn init() {
    let _ = &*LOCAL_SYSTEM_MESSAGE_TABLE_DEF;
}

/// 本地系统消息：仅客户端持久化，不回传服务端。
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LocalSystemMessageEntity {
    pub id: Option<i64>,
    /// 所属用户 UID（多账号隔离）。
    pub owner_uid: i64,
    /// 关联对象，例如好友 UID 或会话 target_id。
    pub target_id: i64,
    /// 消息内容（纯文本）。
    pub content: String,
    /// 创建时间戳（毫秒）。
    pub created_at: i64,
    /// 是否未读。
    pub unread: bool,
}

impl LocalSystemMessageEntity {
    pub fn new(owner_uid: i64, target_id: i64, content: String, created_at: i64) -> Self {
        Self {
            id: None,
            owner_uid,
            target_id,
            content,
            created_at,
            unread: true,
        }
    }
}

impl TableEntity for LocalSystemMessageEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "owner_uid",
            Value::Integer(self.owner_uid),
        ));
        cols.push(ColumnValue::new(
            "target_id",
            Value::Integer(self.target_id),
        ));
        cols.push(ColumnValue::new(
            "content",
            Value::Text(self.content.clone()),
        ));
        cols.push(ColumnValue::new(
            "created_at",
            Value::Integer(self.created_at),
        ));
        cols.push(ColumnValue::new(
            "unread",
            Value::Integer(self.unread as i64),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static LOCAL_SYSTEM_MESSAGE_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "local_system_message",
        comment = "本地系统消息表，仅客户端持久化",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!(
                "owner_uid",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "所属用户 UID"
            ),
            column_def!(
                "target_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "关联对象（好友/会话目标）"
            ),
            column_def!(
                "content",
                ColumnType::Text,
                constraints = "NOT NULL",
                comment = "消息内容"
            ),
            column_def!(
                "created_at",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "创建时间戳（毫秒）"
            ),
            column_def!(
                "unread",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 1",
                comment = "是否未读"
            )
        ],
        indexes = [
            // 按账号/目标时间排序查询
            normal_index!("idx_local_sys_msg_owner_target_time", ["owner_uid", "target_id", "created_at"])
        ]
    }
});

pub fn local_system_message_table_def() -> &'static TableDef {
    &LOCAL_SYSTEM_MESSAGE_TABLE_DEF
}
