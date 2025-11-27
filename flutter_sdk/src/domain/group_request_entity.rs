use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, normal_index, table_def, unique_index};

pub fn init() {
    let _ = &*GROUP_REQUEST_TABLE_DEF;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GroupRequestEntity {
    pub id: Option<i64>,
    pub request_id: i64,
    pub group_id: i64,
    pub applicant_id: i64,
    pub reason: String,
    pub created_at: i64,
    pub via_member_ids: Vec<i64>,
    pub decided_at: Option<i64>,
    pub approved: Option<bool>,
    pub remark: Option<String>,
    pub approved_member_ids: Vec<i64>,
    pub updated_at: i64,
}

impl GroupRequestEntity {
    pub fn new(request_id: i64, group_id: i64, applicant_id: i64, created_at: i64) -> Self {
        Self {
            id: None,
            request_id,
            group_id,
            applicant_id,
            reason: String::new(),
            created_at,
            via_member_ids: Vec::new(),
            decided_at: None,
            approved: None,
            remark: None,
            approved_member_ids: Vec::new(),
            updated_at: created_at,
        }
    }
}

impl TableEntity for GroupRequestEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "request_id",
            Value::Integer(self.request_id),
        ));
        cols.push(ColumnValue::new("group_id", Value::Integer(self.group_id)));
        cols.push(ColumnValue::new(
            "applicant_id",
            Value::Integer(self.applicant_id),
        ));
        cols.push(ColumnValue::new("reason", Value::Text(self.reason.clone())));
        cols.push(ColumnValue::new(
            "created_at",
            Value::Integer(self.created_at),
        ));
        cols.push(ColumnValue::new(
            "via_member_ids",
            Value::Text(serde_json::to_string(&self.via_member_ids).unwrap_or_default()),
        ));
        if let Some(decided_at) = self.decided_at {
            cols.push(ColumnValue::new("decided_at", Value::Integer(decided_at)));
        }
        if let Some(approved) = self.approved {
            cols.push(ColumnValue::new(
                "approved",
                Value::Integer(approved as i64),
            ));
        }
        cols.push(ColumnValue::new(
            "remark",
            Value::Text(self.remark.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "approved_member_ids",
            Value::Text(
                serde_json::to_string(&self.approved_member_ids).unwrap_or_default(),
            ),
        ));
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

pub static GROUP_REQUEST_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "group_request",
        comment = "加群申请与审批记录",
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
                "group_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "群 ID"
            ),
            column_def!(
                "applicant_id",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "申请人 UID"
            ),
            column_def!(
                "reason",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "申请理由"
            ),
            column_def!(
                "created_at",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "创建时间戳"
            ),
            column_def!(
                "via_member_ids",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT '[]'",
                comment = "经由成员 ID 列表(JSON)"
            ),
            column_def!(
                "decided_at",
                ColumnType::Integer,
                constraints = "NULL",
                comment = "审批时间"
            ),
            column_def!(
                "approved",
                ColumnType::Integer,
                constraints = "NULL",
                comment = "是否通过"
            ),
            column_def!(
                "remark",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "审批备注"
            ),
            column_def!(
                "approved_member_ids",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT '[]'",
                comment = "通过的成员 IDs(JSON)"
            ),
            column_def!(
                "updated_at",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "最后更新时间"
            )
        ],
        indexes = [
            unique_index!("idx_group_request_id", ["request_id"]),
            normal_index!("idx_group_request_group", ["group_id"]),
            normal_index!("idx_group_request_updated_at", ["updated_at"])
        ]
    }
});

pub fn group_request_table_def() -> &'static TableDef {
    &GROUP_REQUEST_TABLE_DEF
}
