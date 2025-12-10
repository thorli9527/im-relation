use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, table_def, unique_index};

pub fn init() {
    let _ = &*GROUP_TABLE_DEF;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GroupEntity {
    /// 主键 ID（自增）
    pub id: Option<i64>,
    /// 群 ID（业务唯一）
    pub group_id: i64,
    /// 群头像 URL
    pub avatar: Option<String>,
    /// 群名称
    pub name: String,
    /// 群公告
    pub notice: String,
    /// 群主 ID
    pub owner_id: i64,
    /// 群类型：示例 1-普通群等
    pub group_type: i32,
    /// 群描述
    pub description: String,
    /// 成员数量
    pub member_count: i32,
    /// 创建时间（Unix 秒）
    pub create_time: i64,
}

impl GroupEntity {
    pub fn new(group_id: i64, name: impl Into<String>, owner_id: i64) -> Self {
        Self {
            id: None,
            group_id,
            avatar: None,
            name: name.into(),
            notice: String::new(),
            owner_id,
            group_type: 1,
            description: String::new(),
            member_count: 0,
            create_time: 0,
        }
    }
}

impl TableEntity for GroupEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new("group_id", Value::Integer(self.group_id)));
        cols.push(ColumnValue::new(
            "avatar",
            Value::Text(self.avatar.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new("name", Value::Text(self.name.clone())));
        cols.push(ColumnValue::new("notice", Value::Text(self.notice.clone())));
        cols.push(ColumnValue::new("owner_id", Value::Integer(self.owner_id)));
        cols.push(ColumnValue::new(
            "group_type",
            Value::Integer(self.group_type as i64),
        ));
        cols.push(ColumnValue::new(
            "description",
            Value::Text(self.description.clone()),
        ));
        cols.push(ColumnValue::new(
            "member_count",
            Value::Integer(self.member_count as i64),
        ));
        cols.push(ColumnValue::new(
            "create_time",
            Value::Integer(self.create_time),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static GROUP_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "chat_group",
        comment = "群信息表",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!(
                "group_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "群业务 ID"
            ),
            column_def!(
                "avatar",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "群头像 URL"
            ),
            column_def!(
                "name",
                ColumnType::Text,
                constraints = "NOT NULL",
                comment = "群名称"
            ),
            column_def!(
                "notice",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "群公告"
            ),
            column_def!(
                "owner_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "群主 ID"
            ),
            column_def!(
                "group_type",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "群类型"
            ),
            column_def!(
                "description",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "群描述"
            ),
            column_def!(
                "member_count",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "成员数量"
            ),
            column_def!(
                "create_time",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "创建时间"
            )
        ],
        indexes = [
            unique_index!("idx_default", ["group_id"])
        ]
    }
});

pub fn group_table_def() -> &'static TableDef {
    &GROUP_TABLE_DEF
}
