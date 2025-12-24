use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, normal_index, table_def};

pub fn init() {
    let _ = &*LOG_TABLE_DEF;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LogEntity {
    pub id: Option<i64>,
    pub source: String,
    pub level: String,
    pub target: String,
    pub message: String,
    pub timestamp_ms: i64,
}

impl TableEntity for LogEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new(
            "source",
            Value::Text(self.source.clone()),
        ));
        cols.push(ColumnValue::new(
            "level",
            Value::Text(self.level.clone()),
        ));
        cols.push(ColumnValue::new(
            "target",
            Value::Text(self.target.clone()),
        ));
        cols.push(ColumnValue::new(
            "message",
            Value::Text(self.message.clone()),
        ));
        cols.push(ColumnValue::new(
            "timestamp_ms",
            Value::Integer(self.timestamp_ms),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub fn log_table_def() -> &'static TableDef {
    &LOG_TABLE_DEF
}

pub static LOG_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "logs",
        comment = "flutter_sdk 日志（捕获 SDK 与客户端侧日志）",
        columns = [
            column_def!("id", ColumnType::Integer, constraints = "PRIMARY KEY AUTOINCREMENT"),
            column_def!("source", ColumnType::Text, constraints = "NOT NULL", comment = "日志来源：flutter_sdk/client"),
            column_def!("level", ColumnType::Text, constraints = "NOT NULL", comment = "日志级别"),
            column_def!("target", ColumnType::Text, constraints = "NOT NULL", comment = "日志 target/模块"),
            column_def!("message", ColumnType::Text, constraints = "NOT NULL", comment = "日志正文"),
            column_def!("timestamp_ms", ColumnType::Integer, constraints = "NOT NULL", comment = "日志时间戳（毫秒）")
        ],
        indexes = [
            normal_index!("idx_logs_time", ["timestamp_ms"]),
            normal_index!("idx_logs_source_time", ["source", "timestamp_ms"])
        ]
    }
});
