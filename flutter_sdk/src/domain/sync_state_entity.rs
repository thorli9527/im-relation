use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, table_def};

pub fn init() {
    let _ = &*SYNC_STATE_TABLE_DEF;
}

/// 记录本地同步游标：好友/群/系统的 lastSeq（默认为 0）。
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SyncStateEntity {
    pub id: Option<i64>,
    pub friend_last_seq: i64,
    pub group_last_seq: i64,
    pub system_last_seq: i64,
}

impl SyncStateEntity {
    pub fn new() -> Self {
        Self {
            id: Some(1),
            friend_last_seq: 0,
            group_last_seq: 0,
            system_last_seq: 0,
        }
    }
}

impl TableEntity for SyncStateEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "friend_last_seq",
            Value::Integer(self.friend_last_seq),
        ));
        cols.push(ColumnValue::new(
            "group_last_seq",
            Value::Integer(self.group_last_seq),
        ));
        cols.push(ColumnValue::new(
            "system_last_seq",
            Value::Integer(self.system_last_seq),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static SYNC_STATE_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "sync_state",
        comment = "同步游标表",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY",
                comment = "固定单行 ID"
            ),
            column_def!(
                "friend_last_seq",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "好友消息游标"
            ),
            column_def!(
                "group_last_seq",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "群消息游标"
            ),
            column_def!(
                "system_last_seq",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "系统消息游标"
            )
        ]
    }
});
