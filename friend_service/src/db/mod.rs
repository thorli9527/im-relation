use std::sync::Arc;

use anyhow::{Context, Result};
use common::config::MySqlPool;
use sqlx::Executor;

pub mod elias_fano;
pub mod friend_list_ef;

pub async fn apply_schema_from_ddl(pool: &Arc<MySqlPool>, ddl: &str) -> Result<()> {
    let mut statement = String::new();

    for line in ddl.lines() {
        let trimmed_line = line.trim();

        if trimmed_line.is_empty() {
            continue;
        }

        if trimmed_line.starts_with("--") || trimmed_line.starts_with('#') {
            continue;
        }

        statement.push_str(line);
        statement.push('\n');

        if trimmed_line.ends_with(';') {
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
