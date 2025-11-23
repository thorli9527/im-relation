use once_cell::sync::OnceCell;
use rusqlite::Row;

use crate::{
    common::{
        db,
        repository::{PageResult, QueryCondition, Repository, SortOrder},
    },
    domain::{friend_table_def, FriendEntity},
};

static INSTANCE: OnceCell<FriendService> = OnceCell::new();

pub struct FriendService {
    pub repo: Repository<FriendEntity>,
}

impl FriendService {
    pub fn init() -> Result<(), String> {
        let service = FriendService {
            repo: Repository::new(friend_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "FriendService already initialized".to_string())
    }

    pub fn get() -> &'static FriendService {
        INSTANCE.get().expect("FriendService is not initialized")
    }

    pub fn list(
        &self,
        conditions: &[QueryCondition],
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<FriendEntity>, String> {
        self.repo.query_by_page(
            conditions,
            Some(("created_at", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row,
        )
    }

    pub fn list_all(&self) -> Result<Vec<FriendEntity>, String> {
        self.repo.query_all(Self::map_row)
    }

    pub fn list_ids(&self) -> Result<Vec<i64>, String> {
        let mut conn = db::connection()?;
        let mut stmt = conn
            .prepare(&format!("SELECT friend_id FROM {}", friend_table_def().name))
            .map_err(|err| err.to_string())?;
        let mut rows = stmt.query([]).map_err(|err| err.to_string())?;
        let mut ids = Vec::new();
        while let Some(row) = rows.next().map_err(|err| err.to_string())? {
            ids.push(row.get("friend_id").map_err(|err| err.to_string())?);
        }
        Ok(ids)
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = friend_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for index_sql in friend_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<FriendEntity, rusqlite::Error> {
        let alias: String = row.get("alias")?;
        let remark: String = row.get("remark")?;
        Ok(FriendEntity {
            id: Some(row.get("id")?),
            friend_id: row.get("friend_id")?,
            avatar: row.get("avatar")?,
            alias: normalize_optional(alias),
            remark: normalize_optional(remark),
            created_at: row.get("created_at")?,
        })
    }
}

fn normalize_optional(value: String) -> Option<String> {
    if value.is_empty() {
        None
    } else {
        Some(value)
    }
}
