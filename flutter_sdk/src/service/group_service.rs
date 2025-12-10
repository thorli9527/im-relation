use once_cell::sync::OnceCell;
use rusqlite::Row;

use crate::{
    common::{
        db,
        repository::{PageResult, QueryCondition, Repository, SortOrder},
    },
    domain::{group_table_def, GroupEntity},
};

static INSTANCE: OnceCell<GroupService> = OnceCell::new();

pub struct GroupService {
    pub repo: Repository<GroupEntity>,
}

impl GroupService {
    pub fn init() -> Result<(), String> {
        let service = GroupService {
            repo: Repository::new(group_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "GroupService already initialized".to_string())
    }

    pub fn get() -> &'static GroupService {
        INSTANCE.get().expect("GroupService is not initialized")
    }

    pub fn list(
        &self,
        conditions: &[QueryCondition],
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<GroupEntity>, String> {
        self.repo.query_by_page(
            conditions,
            Some(("create_time", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row,
        )
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = group_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for index_sql in group_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<GroupEntity, rusqlite::Error> {
        Ok(GroupEntity {
            id: Some(row.get("id")?),
            group_id: row.get("group_id")?,
            avatar: normalize_optional(row.get("avatar")?),
            name: row.get("name")?,
            notice: row.get("notice")?,
            owner_id: row.get("owner_id")?,
            group_type: row.get("group_type")?,
            description: row.get("description")?,
            member_count: row.get("member_count")?,
            create_time: row.get("create_time")?,
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
