use std::fmt::Write;

/// 定义一张表的结构信息，用于集中维护 SQLite DDL。
#[derive(Debug, Clone)]
pub struct TableDef {
    pub name: &'static str,
    pub comment: Option<&'static str>,
    pub columns: Vec<ColumnDef>,
    pub indexes: Vec<IndexDef>,
}

impl TableDef {
    pub fn new(
        name: &'static str,
        comment: Option<&'static str>,
        columns: Vec<ColumnDef>,
        indexes: Vec<IndexDef>,
    ) -> Self {
        Self {
            name,
            comment,
            columns,
            indexes,
        }
    }

    /// 生成 `CREATE TABLE IF NOT EXISTS ...` 语句。
    pub fn create_table_sql(&self) -> String {
        let mut sql = String::new();
        writeln!(sql, "CREATE TABLE IF NOT EXISTS {} (", self.name).unwrap();
        for (idx, column) in self.columns.iter().enumerate() {
            let suffix = if idx == self.columns.len() - 1 {
                ""
            } else {
                ","
            };
            let constraint_part = column
                .constraints
                .map(|c| format!(" {c}"))
                .unwrap_or_default();
            writeln!(
                sql,
                "    {} {}{}{}",
                column.name,
                column.data_type.as_sql(),
                constraint_part,
                suffix
            )
            .unwrap();
        }
        sql.push_str(")\n");
        sql
    }

    /// 生成表上所有索引的 `CREATE [UNIQUE] INDEX IF NOT EXISTS ...` 语句。
    pub fn create_index_sqls(&self) -> Vec<String> {
        self.indexes
            .iter()
            .map(|index| index.create_sql(self.name))
            .collect()
    }
}

/// 列支持的数据类型枚举。
#[derive(Debug, Clone)]
pub enum ColumnType {
    Integer,
    Text,
    Real,
    Boolean,
    Blob,
    Custom(&'static str),
}

impl ColumnType {
    pub fn as_sql(&self) -> &'static str {
        match self {
            ColumnType::Integer => "INTEGER",
            ColumnType::Text => "TEXT",
            ColumnType::Real => "REAL",
            ColumnType::Boolean => "INTEGER",
            ColumnType::Blob => "BLOB",
            ColumnType::Custom(raw) => raw,
        }
    }
}

/// 字段定义，包含类型、约束与备注。
#[derive(Debug, Clone)]
pub struct ColumnDef {
    pub name: &'static str,
    pub data_type: ColumnType,
    pub constraints: Option<&'static str>,
    pub comment: Option<&'static str>,
}

impl ColumnDef {
    pub fn new(
        name: &'static str,
        data_type: ColumnType,
        constraints: Option<&'static str>,
        comment: Option<&'static str>,
    ) -> Self {
        Self {
            name,
            data_type,
            constraints,
            comment,
        }
    }
}

/// 索引类型，只区分普通索引与唯一索引。
#[derive(Debug, Clone)]
pub enum IndexType {
    Normal,
    Unique,
}

/// 索引定义，支持多字段。
#[derive(Debug, Clone)]
pub struct IndexDef {
    pub name: &'static str,
    pub kind: IndexType,
    pub columns: Vec<&'static str>,
}

impl IndexDef {
    pub fn new(name: &'static str, kind: IndexType, columns: Vec<&'static str>) -> Self {
        Self {
            name,
            kind,
            columns,
        }
    }

    pub fn unique(name: &'static str, columns: Vec<&'static str>) -> Self {
        Self::new(name, IndexType::Unique, columns)
    }

    pub fn normal(name: &'static str, columns: Vec<&'static str>) -> Self {
        Self::new(name, IndexType::Normal, columns)
    }

    pub fn create_sql(&self, table: &str) -> String {
        let cols = self.columns.join(", ");
        let prefix = match self.kind {
            IndexType::Normal => "CREATE INDEX IF NOT EXISTS",
            IndexType::Unique => "CREATE UNIQUE INDEX IF NOT EXISTS",
        };
        format!("{prefix} {} ON {table}({cols})", self.name)
    }
}

/// 列定义辅助宏，避免重复书写样板代码。
#[macro_export]
macro_rules! column_def {
    ($name:expr, $data_type:expr $(, constraints = $constraints:expr)? $(, comment = $comment:expr)? $(,)?) => {{
        $crate::common::schema::ColumnDef::new(
            $name,
            $data_type,
            column_def!(@constraints $( $constraints )?),
            column_def!(@comment $( $comment )?),
        )
    }};
    (@constraints) => {
        None
    };
    (@constraints $constraints:expr) => {
        Some($constraints)
    };
    (@comment) => {
        None
    };
    (@comment $comment:expr) => {
        Some($comment)
    };
}

/// 普通索引定义宏。
#[macro_export]
macro_rules! index_def {
    ($name:expr, [$($field:expr),+ $(,)?]) => {{
        $crate::common::schema::IndexDef::normal($name, vec![$($field),+])
    }};
}

/// 普通索引定义宏（语义化别名）。
#[macro_export]
macro_rules! normal_index {
    ($name:expr, [$($field:expr),+ $(,)?]) => {{
        $crate::common::schema::IndexDef::normal($name, vec![$($field),+])
    }};
}

/// 唯一索引定义宏。
#[macro_export]
macro_rules! unique_index {
    ($name:expr, [$($field:expr),+ $(,)?]) => {{
        $crate::common::schema::IndexDef::unique($name, vec![$($field),+])
    }};
}

/// 表结构定义宏，组合列与索引信息。
#[macro_export]
macro_rules! table_def {
    ($name:expr $(, comment = $comment:expr)? , columns = [$($col:expr),+ $(,)?] $(, indexes = [$($idx:expr),* $(,)?])? $(,)?) => {{
        $crate::common::schema::TableDef::new(
            $name,
            table_def!(@comment $( $comment )?),
            vec![$($col),+],
            table_def!(@indexes $( [$($idx),*] )?),
        )
    }};
    (@comment) => {
        None
    };
    (@comment $comment:expr) => {
        Some($comment)
    };
    (@indexes) => {
        Vec::new()
    };
    (@indexes [$($idx:expr),*]) => {
        vec![$($idx),*]
    };
}
