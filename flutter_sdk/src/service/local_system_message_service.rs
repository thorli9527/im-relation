use once_cell::sync::OnceCell;
use rusqlite::Row;

use crate::{
    common::{
        db,
        repository::{PageResult, QueryCondition, QueryType, Repository, SortOrder},
    },
    domain::{local_system_message_table_def, LocalSystemMessageEntity},
};
use rusqlite::types::Value;

static INSTANCE: OnceCell<LocalSystemMessageService> = OnceCell::new();

pub struct LocalSystemMessageService {
    pub repo: Repository<LocalSystemMessageEntity>,
}

impl LocalSystemMessageService {
    pub fn init() -> Result<(), String> {
        let service = LocalSystemMessageService {
            repo: Repository::new(local_system_message_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "LocalSystemMessageService already initialized".to_string())
    }

    pub fn get() -> &'static LocalSystemMessageService {
        INSTANCE
            .get()
            .expect("LocalSystemMessageService is not initialized")
    }

    pub fn insert(&self, entity: LocalSystemMessageEntity) -> Result<(), String> {
        self.repo.insert(entity)?;
        Ok(())
    }

    pub fn list_by_owner_and_target(
        &self,
        owner_uid: i64,
        target_id: i64,
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<LocalSystemMessageEntity>, String> {
        let conditions = vec![
            QueryCondition::new(
                "owner_uid",
                QueryType::Equal,
                vec![Value::Integer(owner_uid)],
            ),
            QueryCondition::new(
                "target_id",
                QueryType::Equal,
                vec![Value::Integer(target_id)],
            ),
        ];
        self.repo.query_by_page(
            &conditions,
            Some(("created_at", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row,
        )
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = local_system_message_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for sql in local_system_message_table_def().create_index_sqls() {
            conn.execute(&sql, []).map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<LocalSystemMessageEntity, rusqlite::Error> {
        Ok(LocalSystemMessageEntity {
            id: Some(row.get("id")?),
            owner_uid: row.get("owner_uid")?,
            target_id: row.get("target_id")?,
            content: row.get("content")?,
            created_at: row.get("created_at")?,
            unread: row.get::<_, i64>("unread")? != 0,
        })
    }
}
