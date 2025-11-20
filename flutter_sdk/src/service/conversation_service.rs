use once_cell::sync::OnceCell;
use rusqlite::Row;

use crate::{
    common::{
        db,
        repository::{PageResult, QueryCondition, Repository, SortOrder},
    },
    domain::{conversation_table_def, ConversationEntity},
};

static INSTANCE: OnceCell<ConversationService> = OnceCell::new();

pub struct ConversationService {
    pub repo: Repository<ConversationEntity>,
}

impl ConversationService {
    pub fn init() -> Result<(), String> {
        let service = ConversationService {
            repo: Repository::new(conversation_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "ConversationService already initialized".to_string())
    }

    pub fn get() -> &'static ConversationService {
        INSTANCE
            .get()
            .expect("ConversationService is not initialized")
    }

    pub fn list(
        &self,
        conditions: &[QueryCondition],
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<ConversationEntity>, String> {
        self.repo.query_by_page(
            conditions,
            Some(("last_message_time", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row,
        )
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = conversation_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for sql in conversation_table_def().create_index_sqls() {
            conn.execute(&sql, []).map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<ConversationEntity, rusqlite::Error> {
        Ok(ConversationEntity {
            id: Some(row.get("id")?),
            conversation_type: row.get("conversation_type")?,
            target_id: row.get("target_id")?,
            unread_count: row.get("unread_count")?,
            last_message_time: row.get("last_message_time")?,
            last_message_content: row.get("last_message_content")?,
        })
    }
}
