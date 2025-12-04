use once_cell::sync::OnceCell;
use rusqlite::Row;

use crate::{
    common::{
        db,
        repository::{PageResult, QueryCondition, QueryType, Repository, SortOrder},
    },
    domain::{conversation_table_def, ConversationEntity},
};
use rusqlite::types::Value;
use rusqlite::Connection;

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

    /// 查询单条会话（按类型+目标 ID）。
    pub fn get_by_type_and_target(
        &self,
        owner_uid: i64,
        conversation_type: i32,
        target_id: i64,
    ) -> Result<Option<ConversationEntity>, String> {
        let conditions = vec![
            QueryCondition::new(
                "owner_uid",
                QueryType::Equal,
                vec![Value::Integer(owner_uid)],
            ),
            QueryCondition::new(
                "conversation_type",
                QueryType::Equal,
                vec![Value::Integer(conversation_type as i64)],
            ),
            QueryCondition::new(
                "target_id",
                QueryType::Equal,
                vec![Value::Integer(target_id)],
            ),
        ];
        self.repo.query_one(&conditions, Self::map_row)
    }

    /// 插入或更新会话。
    pub fn upsert(&self, mut entity: ConversationEntity) -> Result<(), String> {
        // 若已存在则更新，否则插入。
        let existing = self.get_by_type_and_target(
            entity.owner_uid,
            entity.conversation_type,
            entity.target_id,
        )?;
        if let Some(mut found) = existing {
            entity.id = found.id.take();
            if found.owner_uid == 0 {
                found.owner_uid = entity.owner_uid;
            }
            entity.owner_uid = found.owner_uid;
            self.repo.update(entity)?;
        } else {
            self.repo.insert(entity)?;
        }
        Ok(())
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = conversation_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        ensure_column(
            &conn,
            conversation_table_def().name,
            "owner_uid",
            "ALTER TABLE conversation ADD COLUMN owner_uid INTEGER NOT NULL DEFAULT 0",
        )?;
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
            owner_uid: row.get("owner_uid")?,
        })
    }
}

fn ensure_column(
    conn: &Connection,
    table: &str,
    column: &str,
    alter_sql: &str,
) -> Result<(), String> {
    let mut stmt = conn
        .prepare(&format!("PRAGMA table_info({})", table))
        .map_err(|err| err.to_string())?;
    let mut rows = stmt.query([]).map_err(|err| err.to_string())?;
    while let Some(row) = rows.next().map_err(|err| err.to_string())? {
        let name: String = row.get("name").map_err(|err| err.to_string())?;
        if name == column {
            return Ok(());
        }
    }
    conn.execute(alter_sql, [])
        .map(|_| ())
        .map_err(|err| err.to_string())
}
