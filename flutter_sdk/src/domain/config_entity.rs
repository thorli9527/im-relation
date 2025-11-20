use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, table_def, unique_index};

pub fn init() {
    let _ = &*CONFIG_TABLE_DEF;
}
/// 配置表实体，用于承载 `config` 表中的键值数据。
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ConfigEntity {
    pub id: Option<i64>,
    pub code: String,
    pub value: String,
}

impl ConfigEntity {
    pub fn new(code: impl Into<String>, value: impl Into<String>) -> Self {
        Self {
            id: None,
            code: code.into(),
            value: value.into(),
        }
    }
}

impl TableEntity for ConfigEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut columns = Vec::new();
        if let Some(id) = self.id {
            columns.push(ColumnValue::new("id", Value::Integer(id)));
        }
        columns.push(ColumnValue::new("code", Value::Text(self.code.clone())));
        columns.push(ColumnValue::new("value", Value::Text(self.value.clone())));
        columns
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

/// 统一维护 config 表的结构定义，便于集中创建表与索引。
pub static CONFIG_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "config",
        comment = "客户端配置表",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "主键 ID"
            ),
            column_def!("code", ColumnType::Text, constraints = "NOT NULL", comment = "配置编码"),
            column_def!("value", ColumnType::Text, constraints = "NOT NULL", comment = "配置值"),
        ],
        indexes = [
            unique_index!("idx_default", ["code"])
        ]
    }
});

pub fn config_table_def() -> &'static TableDef {
    &CONFIG_TABLE_DEF
}
