use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, table_def, unique_index};

pub fn init() {
    let _ = &*FRIEND_TABLE_DEF;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FriendEntity {
    pub id: Option<i64>,
    pub friend_id: i64,
    pub avatar: String,
    pub nickname: Option<String>,
    pub remark: Option<String>,
    pub created_at: i64,
}

impl FriendEntity {
    pub fn new(friend_id: i64, created_at: i64) -> Self {
        Self {
            id: None,
            friend_id,
            avatar: String::new(),
            nickname: None,
            remark: None,
            created_at,
        }
    }
}

impl TableEntity for FriendEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "friend_id",
            Value::Integer(self.friend_id),
        ));
        cols.push(ColumnValue::new("avatar", Value::Text(self.avatar.clone())));
        cols.push(ColumnValue::new(
            "nickname",
            Value::Text(self.nickname.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "remark",
            Value::Text(self.remark.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "created_at",
            Value::Integer(self.created_at),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static FRIEND_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "friend",
        comment = "好友列表",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!(
                "friend_id",
                ColumnType::Integer,
                constraints = "NOT NULL UNIQUE",
                comment = "好友用户 ID"
            ),
            column_def!(
                "avatar",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "好友头像 URL"
            ),
            column_def!(
                "nickname",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "好友昵称"
            ),
            column_def!(
                "remark",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "备注信息"
            ),
            column_def!(
                "created_at",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "创建时间戳"
            )
        ],
        indexes = [
            unique_index!("idx_default", ["friend_id"])
        ]
    }
});

pub fn friend_table_def() -> &'static TableDef {
    &FRIEND_TABLE_DEF
}
