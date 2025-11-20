use std::{collections::HashSet, marker::PhantomData};

use rusqlite::{types::Value, Row, ToSql};
use serde::{Deserialize, Serialize};

use super::{db, schema::TableDef};

/// 表字段值的封装，便于统一生成 SQL。
#[derive(Debug, Clone)]
pub struct ColumnValue {
    pub name: &'static str,
    pub value: Value,
}

impl ColumnValue {
    pub fn new(name: &'static str, value: Value) -> Self {
        Self { name, value }
    }
}

/// 需要持久化到 SQLite 的实体需要实现此 trait，用于生成 SQL 参数。
pub trait TableEntity: Send + Sync {
    fn column_values(&self) -> Vec<ColumnValue>;
    fn primary_key(&self) -> Option<ColumnValue>;
}

/// SQLite 数据访问抽象，封装常用增删改查与分页操作。
pub struct Repository<T: TableEntity> {
    table_def: &'static TableDef,
    column_names: HashSet<&'static str>,
    _marker: PhantomData<T>,
}

impl<T: TableEntity> Repository<T> {
    pub fn new(table_def: &'static TableDef) -> Self {
        Self {
            table_def,
            column_names: table_def
                .columns
                .iter()
                .map(|col| col.name)
                .collect::<HashSet<_>>(),
            _marker: PhantomData,
        }
    }

    /// 根据 TableDef 和实体值动态构建 INSERT 语句。
    pub fn insert(&self, entity: T) -> Result<usize, String> {
        let column_values = entity.column_values();
        if column_values.is_empty() {
            return Err("insert requires at least one column".into());
        }
        self.ensure_columns(column_values.iter().map(|col| col.name))?;

        let columns: Vec<&str> = column_values.iter().map(|col| col.name).collect();
        let placeholders = vec!["?"; columns.len()].join(", ");
        let sql = format!(
            "INSERT INTO {} ({}) VALUES ({})",
            self.table_def.name,
            columns.join(", "),
            placeholders
        );

        let owned_values: Vec<Value> = column_values.iter().map(|col| col.value.clone()).collect();
        let params: Vec<&dyn ToSql> = owned_values.iter().map(|v| v as &dyn ToSql).collect();

        let conn = db::connection()?;
        conn.execute(&sql, params.as_slice()).map_err(to_err)
    }

    /// 根据 TableDef 动态构建 UPDATE 语句。
    pub fn update(&self, entity: T) -> Result<usize, String> {
        let pk = entity
            .primary_key()
            .ok_or_else(|| "update requires primary key".to_string())?;

        let column_values: Vec<ColumnValue> = entity
            .column_values()
            .into_iter()
            .filter(|col| col.name != pk.name)
            .collect();

        if column_values.is_empty() {
            return Err("update requires at least one non-primary column".into());
        }

        self.ensure_columns(column_values.iter().map(|col| col.name))?;
        self.ensure_columns([pk.name].into_iter())?;

        let assignments = column_values
            .iter()
            .map(|col| format!("{} = ?", col.name))
            .collect::<Vec<_>>()
            .join(", ");
        let sql = format!(
            "UPDATE {} SET {} WHERE {} = ?",
            self.table_def.name, assignments, pk.name
        );

        let mut owned_values: Vec<Value> =
            column_values.iter().map(|col| col.value.clone()).collect();
        owned_values.push(pk.value.clone());
        let params: Vec<&dyn ToSql> = owned_values.iter().map(|v| v as &dyn ToSql).collect();

        let conn = db::connection()?;
        conn.execute(&sql, params.as_slice()).map_err(to_err)
    }

    /// 根据 TableDef 动态构建 DELETE 语句。
    pub fn delete(&self, entity: T) -> Result<usize, String> {
        let pk = entity
            .primary_key()
            .ok_or_else(|| "delete requires primary key".to_string())?;
        self.ensure_columns([pk.name].into_iter())?;
        let sql = format!("DELETE FROM {} WHERE {} = ?", self.table_def.name, pk.name);
        let owned_values = vec![pk.value];
        let params: Vec<&dyn ToSql> = owned_values.iter().map(|v| v as &dyn ToSql).collect();

        let conn = db::connection()?;
        conn.execute(&sql, params.as_slice()).map_err(to_err)
    }

    /// 查询单条记录并映射成实体。
    pub fn query_one<U, F>(
        &self,
        conditions: &[QueryCondition],
        mapper: F,
    ) -> Result<Option<U>, String>
    where
        F: FnOnce(&Row) -> Result<U, rusqlite::Error>,
    {
        let (mut sql, values) = self.build_select_sql(conditions)?;
        sql.push_str(" LIMIT 1");
        let params: Vec<&dyn ToSql> = values.iter().map(|v| v as &dyn ToSql).collect();
        let conn = db::connection()?;
        let mut stmt = conn.prepare(&sql).map_err(to_err)?;
        let mut rows = stmt.query(params.as_slice()).map_err(to_err)?;
        if let Some(row) = rows.next().map_err(to_err)? {
            Ok(Some(mapper(row).map_err(to_err)?))
        } else {
            Ok(None)
        }
    }

    /// 查询多条记录并映射。
    pub fn query_list<U, F>(
        &self,
        conditions: &[QueryCondition],
        mapper: F,
    ) -> Result<Vec<U>, String>
    where
        F: Fn(&Row) -> Result<U, rusqlite::Error>,
    {
        let (sql, values) = self.build_select_sql(conditions)?;
        let params: Vec<&dyn ToSql> = values.iter().map(|v| v as &dyn ToSql).collect();
        let conn = db::connection()?;
        let mut stmt = conn.prepare(&sql).map_err(to_err)?;
        let mut rows = stmt.query(params.as_slice()).map_err(to_err)?;
        let mut result = Vec::new();
        while let Some(row) = rows.next().map_err(to_err)? {
            result.push(mapper(row).map_err(to_err)?);
        }
        Ok(result)
    }

    /// 查询整表所有记录。
    pub fn query_all<U, F>(&self, mapper: F) -> Result<Vec<U>, String>
    where
        F: Fn(&Row) -> Result<U, rusqlite::Error>,
    {
        self.query_list(&[], mapper)
    }

    /// 便捷分页查询：传入基础 SQL 与分页参数，自动拼接 LIMIT/OFFSET。
    pub fn query_by_page<U, F>(
        &self,
        conditions: &[QueryCondition],
        order_by: Option<(&str, SortOrder)>,
        page: u32,
        page_size: u32,
        mapper: F,
    ) -> Result<PageResult<U>, String>
    where
        F: Fn(&Row) -> Result<U, rusqlite::Error>,
    {
        let page = page.max(1);
        let page_size = page_size.max(1);
        let limit = (page_size + 1) as i64;
        let offset = ((page - 1) * page_size) as i64;
        let (mut sql, mut values) = self.build_select_sql(conditions)?;
        if let Some((column, order)) = order_by {
            self.ensure_columns([column].into_iter())?;
            let dir = match order {
                SortOrder::Asc => "ASC",
                SortOrder::Desc => "DESC",
            };
            sql.push_str(&format!(" ORDER BY {} {}", column, dir));
        }
        sql.push_str(" LIMIT ? OFFSET ?");
        values.push(Value::Integer(limit));
        values.push(Value::Integer(offset));

        let params: Vec<&dyn ToSql> = values.iter().map(|v| v as &dyn ToSql).collect();
        let conn = db::connection()?;
        let mut stmt = conn.prepare(&sql).map_err(to_err)?;
        let mut rows = stmt.query(params.as_slice()).map_err(to_err)?;
        let mut data = Vec::new();
        while let Some(row) = rows.next().map_err(to_err)? {
            data.push(mapper(row).map_err(to_err)?);
        }
        let has_next = data.len() as u32 > page_size;
        if has_next {
            data.pop();
        }
        Ok(PageResult {
            items: data,
            has_next,
            has_prev: page > 1,
        })
    }
    fn ensure_columns<'a>(&self, columns: impl IntoIterator<Item = &'a str>) -> Result<(), String> {
        for column in columns {
            if !self.column_names.contains(column) {
                return Err(format!(
                    "column `{}` is not defined on table `{}`",
                    column, self.table_def.name
                ));
            }
        }
        Ok(())
    }

    fn build_select_sql(
        &self,
        conditions: &[QueryCondition],
    ) -> Result<(String, Vec<Value>), String> {
        let (clause, params) = self.build_where_clause(conditions)?;
        let mut sql = format!("SELECT * FROM {}", self.table_def.name);
        if !clause.is_empty() {
            sql.push_str(" WHERE ");
            sql.push_str(&clause);
        }
        Ok((sql, params))
    }

    fn build_where_clause(
        &self,
        conditions: &[QueryCondition],
    ) -> Result<(String, Vec<Value>), String> {
        if conditions.is_empty() {
            return Ok((String::new(), Vec::new()));
        }

        let mut clauses = Vec::new();
        let mut params = Vec::new();

        for condition in conditions {
            self.ensure_columns([condition.column.as_str()].into_iter())?;
            condition.validate()?;

            match condition.query_type {
                QueryType::Equal => {
                    clauses.push(format!("{} = ?", condition.column));
                    params.push(condition.values[0].clone());
                }
                QueryType::Like => {
                    clauses.push(format!("{} LIKE ?", condition.column));
                    params.push(condition.values[0].clone());
                }
                QueryType::GreaterThan => {
                    clauses.push(format!("{} > ?", condition.column));
                    params.push(condition.values[0].clone());
                }
                QueryType::LessThan => {
                    clauses.push(format!("{} < ?", condition.column));
                    params.push(condition.values[0].clone());
                }
                QueryType::Between => {
                    clauses.push(format!("{} BETWEEN ? AND ?", condition.column));
                    params.push(condition.values[0].clone());
                    params.push(condition.values[1].clone());
                }
                QueryType::In => {
                    let placeholders = vec!["?"; condition.values.len()].join(", ");
                    clauses.push(format!("{} IN ({})", condition.column, placeholders));
                    params.extend(condition.values.iter().cloned());
                }
            }
        }

        Ok((clauses.join(" AND "), params))
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PageResult<T> {
    pub items: Vec<T>,
    pub has_next: bool,
    pub has_prev: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum QueryType {
    Equal,
    Like,
    Between,
    GreaterThan,
    LessThan,
    In,
}

#[derive(Debug, Clone)]
pub struct QueryCondition {
    pub column: String,
    pub query_type: QueryType,
    pub values: Vec<Value>,
}

impl QueryCondition {
    pub fn new(column: impl Into<String>, query_type: QueryType, values: Vec<Value>) -> Self {
        Self {
            column: column.into(),
            query_type,
            values,
        }
    }

    fn validate(&self) -> Result<(), String> {
        let len = self.values.len();
        let valid = match self.query_type {
            QueryType::Equal | QueryType::Like | QueryType::GreaterThan | QueryType::LessThan => {
                len == 1
            }
            QueryType::Between => len == 2,
            QueryType::In => len >= 1,
        };
        if valid {
            Ok(())
        } else {
            Err(format!(
                "invalid value count {} for query type {:?}",
                len, self.query_type
            ))
        }
    }
}

fn to_err<E: std::fmt::Display>(err: E) -> String {
    err.to_string()
}

#[derive(Debug, Clone, Copy)]
pub enum SortOrder {
    Asc,
    Desc,
}
