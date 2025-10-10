use std::sync::Arc;

use anyhow::{Context, Result};

use crate::config::MySqlPool;

/// Apply a DDL script (e.g. `migrations/mysql_schema.sql`) against the given MySQL pool.
///
/// Statements are executed one-by-one; lines beginning with `--` or `#` are ignored.
pub async fn apply_mysql_schema(pool: &Arc<MySqlPool>, ddl: &str) -> Result<()> {
    let mut statement = String::new();

    for line in ddl.lines() {
        let trimmed = line.trim();

        if trimmed.is_empty() || trimmed.starts_with("--") || trimmed.starts_with('#') {
            continue;
        }

        statement.push_str(line);
        statement.push('\n');

        if trimmed.ends_with(';') {
            execute_statement(pool, &mut statement).await?;
        }
    }

    if !statement.trim().is_empty() {
        execute_statement(pool, &mut statement).await?;
    }

    Ok(())
}

async fn execute_statement(pool: &Arc<MySqlPool>, statement: &mut String) -> Result<()> {
    let sql = statement.trim();
    if sql.is_empty() {
        statement.clear();
        return Ok(());
    }

    let sql = sql.strip_suffix(';').unwrap_or(sql).trim();

    if !sql.is_empty() {
        sqlx::query(sql)
            .execute(pool.as_ref())
            .await
            .with_context(|| format!("failed to execute DDL statement: {}", sql))?;
    }

    statement.clear();
    Ok(())
}
