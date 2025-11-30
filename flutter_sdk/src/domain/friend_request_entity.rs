use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, normal_index, table_def, unique_index};

pub fn init() {
    let _ = &*FRIEND_REQUEST_TABLE_DEF;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FriendRequestEntity {
    pub id: Option<i64>,
    pub request_id: i64,
    pub from_uid: i64,
    pub to_uid: i64,
    pub reason: String,
    pub source: i32,
    pub remark: Option<String>,
    pub nickname: Option<String>,
    pub peer_remark: Option<String>,
    pub peer_nickname: Option<String>,
    pub created_at: i64,
    pub decided_at: Option<i64>,
    pub accepted: Option<bool>,
    pub updated_at: i64,
}

impl FriendRequestEntity {
    pub fn new(request_id: i64, from_uid: i64, to_uid: i64, created_at: i64) -> Self {
        Self {
            id: None,
            request_id,
            from_uid,
            to_uid,
            reason: String::new(),
            source: 0,
            remark: None,
            nickname: None,
            peer_remark: None,
            peer_nickname: None,
            created_at,
            decided_at: None,
            accepted: None,
            updated_at: created_at,
        }
    }
}

impl TableEntity for FriendRequestEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "request_id",
            Value::Integer(self.request_id),
        ));
        cols.push(ColumnValue::new("from_uid", Value::Integer(self.from_uid)));
        cols.push(ColumnValue::new("to_uid", Value::Integer(self.to_uid)));
        cols.push(ColumnValue::new("reason", Value::Text(self.reason.clone())));
        cols.push(ColumnValue::new(
            "source",
            Value::Integer(self.source as i64),
        ));
        cols.push(ColumnValue::new(
            "remark",
            Value::Text(self.remark.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "nickname",
            Value::Text(self.nickname.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "peer_remark",
            Value::Text(self.peer_remark.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "peer_nickname",
            Value::Text(self.peer_nickname.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "created_at",
            Value::Integer(self.created_at),
        ));
        if let Some(decided_at) = self.decided_at {
            cols.push(ColumnValue::new("decided_at", Value::Integer(decided_at)));
        }
        if let Some(accepted) = self.accepted {
            cols.push(ColumnValue::new(
                "accepted",
                Value::Integer(accepted as i64),
            ));
        }
        cols.push(ColumnValue::new(
            "updated_at",
            Value::Integer(self.updated_at),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static FRIEND_REQUEST_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "friend_request",
        comment = "好友申请记录",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!(
                "request_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "请求唯一 ID"
            ),
            column_def!(
                "from_uid",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "申请发起人 UID"
            ),
            column_def!(
                "to_uid",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "申请接收人 UID"
            ),
            column_def!(
                "reason",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "申请附言"
            ),
            column_def!(
                "source",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "申请来源"
            ),
            column_def!(
                "remark",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "申请备注"
            ),
            column_def!(
                "nickname",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "展示昵称"
            ),
            column_def!(
                "peer_remark",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "对端处理时的备注"
            ),
            column_def!(
                "peer_nickname",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "对端处理时的昵称"
            ),
            column_def!(
                "created_at",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "创建时间戳"
            ),
            column_def!(
                "decided_at",
                ColumnType::Integer,
                constraints = "NULL",
                comment = "审批时间戳"
            ),
            column_def!(
                "accepted",
                ColumnType::Integer,
                constraints = "NULL",
                comment = "是否同意"
            ),
            column_def!(
                "updated_at",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "最后更新时间"
            )
        ],
        indexes = [
            unique_index!("idx_friend_request_id", ["request_id"]),
            normal_index!("idx_friend_request_created_at", ["created_at"]),
            normal_index!("idx_friend_request_updated_at", ["updated_at"])
        ]
    }
});

pub fn friend_request_table_def() -> &'static TableDef {
    &FRIEND_REQUEST_TABLE_DEF
}
