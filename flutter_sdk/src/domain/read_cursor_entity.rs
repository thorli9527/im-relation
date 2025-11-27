use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, normal_index, table_def};

/// 记录每个用户在不同场景/目标下的已读游标：
/// - scene: 单聊/群聊/系统等
/// - target_id: 单聊对方 uid / 群聊 gid / 系统为 0
/// - last_read_seq: 已读到的序列或消息号（根据同步协议）
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReadCursorEntity {
    /// 主键 ID
    pub id: Option<i64>,
    /// 用户 ID（拥有该游标的用户）
    pub uid: i64,
    /// 场景：单聊/群聊/系统等
    pub scene: i32,
    /// 目标 ID：单聊对方 uid / 群聊 gid / 系统为 0
    pub target_id: i64,
    /// 已读到的序列或消息号（根据同步协议）
    pub last_read_seq: i64,
    /// 更新时间戳（毫秒）
    pub updated_at: i64,
}

impl ReadCursorEntity {
    pub fn new(uid: i64, scene: i32, target_id: i64, last_read_seq: i64, updated_at: i64) -> Self {
        Self {
            id: None,
            uid,
            scene,
            target_id,
            last_read_seq,
            updated_at,
        }
    }
}

impl TableEntity for ReadCursorEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new("uid", Value::Integer(self.uid)));
        cols.push(ColumnValue::new("scene", Value::Integer(self.scene as i64)));
        cols.push(ColumnValue::new(
            "target_id",
            Value::Integer(self.target_id),
        ));
        cols.push(ColumnValue::new(
            "last_read_seq",
            Value::Integer(self.last_read_seq),
        ));
        cols.push(ColumnValue::new(
            "updated_at",
            Value::Integer(self.updated_at),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id
            .map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static READ_CURSOR_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "read_cursor",
        comment = "已读游标表（按场景/目标记录 last_read_seq）",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!(
                "uid",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "用户 ID"
            ),
            column_def!(
                "scene",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "场景：单聊/群聊/系统等"
            ),
            column_def!(
                "target_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "目标 ID：单聊对方/群聊群 ID/系统为 0"
            ),
            column_def!(
                "last_read_seq",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "已读到的序列或消息号"
            ),
            column_def!(
                "updated_at",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "更新时间戳（毫秒）"
            )
        ],
        indexes = [
            normal_index!("idx_read_cursor_uid_scene_target", ["uid", "scene", "target_id"])
        ]
    }
});

pub fn read_cursor_table_def() -> &'static TableDef {
    &READ_CURSOR_TABLE_DEF
}
