use std::sync::Arc;

use anyhow::Result;
use common::config::MySqlPool;

pub mod elias_fano;
pub mod friend_list_ef;

pub async fn apply_schema_from_ddl(pool: &Arc<MySqlPool>, ddl: &str) -> Result<()> {
    common::support::util::schema::apply_mysql_schema(pool, ddl).await
}
