use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, table_def, unique_index};

pub fn init() {
    let _ = &*GROUP_MEMBER_TABLE_DEF;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GroupMemberEntity {
    pub id: Option<i64>,
    pub group_id: i64,
    pub member_id: i64,
    pub nickname: String,
    pub alias: Option<String>,
    pub avatar: String,
    pub role: i32,
    pub muted: bool,
    pub join_time: i64,
    pub updated_at: i64,
    pub version: i64,
}

impl GroupMemberEntity {
    pub fn new(group_id: i64, member_id: i64, nickname: impl Into<String>) -> Self {
        Self {
            id: None,
            group_id,
            member_id,
            nickname: nickname.into(),
            alias: None,
            avatar: String::new(),
            role: 0,
            muted: false,
            join_time: 0,
            updated_at: 0,
            version: 0,
        }
    }
}

impl TableEntity for GroupMemberEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new("group_id", Value::Integer(self.group_id)));
        cols.push(ColumnValue::new("member_id", Value::Integer(self.member_id)));
        cols.push(ColumnValue::new(
            "nickname",
            Value::Text(self.nickname.clone()),
        ));
        cols.push(ColumnValue::new(
            "alias",
            Value::Text(self.alias.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new("avatar", Value::Text(self.avatar.clone())));
        cols.push(ColumnValue::new("role", Value::Integer(self.role as i64)));
        cols.push(ColumnValue::new(
            "muted",
            Value::Integer(self.muted as i64),
        ));
        cols.push(ColumnValue::new(
            "join_time",
            Value::Integer(self.join_time),
        ));
        cols.push(ColumnValue::new(
            "updated_at",
            Value::Integer(self.updated_at),
        ));
        cols.push(ColumnValue::new(
            "version",
            Value::Integer(self.version),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static GROUP_MEMBER_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "group_member",
        comment = "群成员缓存表",
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
                comment = "群 ID"
            ),
            column_def!(
                "member_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "成员用户 ID"
            ),
            column_def!(
                "nickname",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "成员昵称"
            ),
            column_def!(
                "alias",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "群内别名"
            ),
            column_def!(
                "avatar",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "头像 URL"
            ),
            column_def!(
                "role",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "角色"
            ),
            column_def!(
                "muted",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "是否禁言"
            ),
            column_def!(
                "join_time",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "加入时间"
            ),
            column_def!(
                "updated_at",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "本地更新时间"
            ),
            column_def!(
                "version",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "版本号（用于幂等/增量）"
            )
        ],
        indexes = [
            unique_index!("idx_group_member_unique", ["group_id", "member_id"])
        ]
    }
});

pub fn group_member_table_def() -> &'static TableDef {
    &GROUP_MEMBER_TABLE_DEF
}
