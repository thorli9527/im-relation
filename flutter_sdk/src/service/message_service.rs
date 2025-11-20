use crate::{
    common::{
        db,
        repository::{PageResult, QueryCondition, QueryType, Repository, SortOrder},
    },
    domain::{message_table_def, MessageEntity, MessageScene, MessageSource},
};
use once_cell::sync::OnceCell;
use rusqlite::{params, types::Value, Row, ToSql};

static INSTANCE: OnceCell<MessageService> = OnceCell::new();

pub struct MessageService {
    pub repo: Repository<MessageEntity>,
}

impl MessageService {
    pub fn init() -> Result<(), String> {
        let service = MessageService {
            repo: Repository::new(message_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "MessageService already initialized".to_string())
    }

    pub fn get() -> &'static MessageService {
        INSTANCE.get().expect("MessageService is not initialized")
    }

    pub fn list_by_conversation(
        &self,
        conversation_id: i64,
        _message_type: Option<i32>,
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<MessageEntity>, String> {
        let conditions = vec![QueryCondition::new(
            "conversation_id",
            QueryType::Equal,
            vec![Value::Integer(conversation_id)],
        )];
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
        let ddl = message_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for sql in message_table_def().create_index_sqls() {
            conn.execute(&sql, []).map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<MessageEntity, rusqlite::Error> {
        Ok(MessageEntity {
            id: Some(row.get("id")?),
            conversation_id: row.get("conversation_id")?,
            sender_type: row.get("sender_type")?,
            sender_id: row.get("sender_id")?,
            is_session_message: row.get::<_, i64>("is_session_message")? != 0,
            content: serde_json::from_str(&row.get::<_, String>("content")?)
                .unwrap_or_else(|_| serde_json::Value::Null),
            extra: row.get("extra")?,
            created_at: row.get("created_at")?,
            scene: MessageScene::from(row.get::<_, i64>("scene")?),
            data_source: MessageSource::from(row.get::<_, i64>("data_source")?),
            sending_status: row.get::<_, i64>("sending_status")? != 0,
            ack_status: row.get::<_, i64>("ack_status")? != 0,
            send_count: row.get::<_, i64>("send_count")? as i32,
        })
    }

    pub fn find_by_id(&self, id: i64) -> Result<Option<MessageEntity>, String> {
        let conditions = vec![QueryCondition::new(
            "id",
            QueryType::Equal,
            vec![Value::Integer(id)],
        )];
        self.repo
            .query_one(&conditions, Self::map_row)
            .map_err(|err| err.to_string())
    }
}

impl MessageService {
    pub fn insert(&self, entity: &MessageEntity) -> Result<i64, String> {
        let columns = [
            "conversation_id",
            "scene",
            "sender_type",
            "sender_id",
            "is_session_message",
            "content",
            "extra",
            "created_at",
            "data_source",
            "sending_status",
            "ack_status",
            "send_count",
        ];
        let placeholders = columns.iter().map(|_| "?").collect::<Vec<_>>().join(", ");
        let sql = format!(
            "INSERT INTO message ({}) VALUES ({})",
            columns.join(", "),
            placeholders
        );
        let values: Vec<Value> = vec![
            Value::Integer(entity.conversation_id),
            Value::Integer(entity.scene as i64),
            Value::Integer(entity.sender_type as i64),
            Value::Integer(entity.sender_id),
            Value::Integer(entity.is_session_message as i64),
            Value::Text(entity.content.to_string()),
            Value::Text(entity.extra.clone()),
            Value::Integer(entity.created_at),
            Value::Integer(entity.data_source as i64),
            Value::Integer(entity.sending_status as i64),
            Value::Integer(entity.ack_status as i64),
            Value::Integer(entity.send_count as i64),
        ];
        let params: Vec<&dyn ToSql> = values.iter().map(|v| v as &dyn ToSql).collect();
        let mut conn = db::connection()?;
        let tx = conn.transaction().map_err(|err| err.to_string())?;
        tx.execute(&sql, params.as_slice())
            .map_err(|err| err.to_string())?;
        let id = tx.last_insert_rowid();
        tx.commit().map_err(|err| err.to_string())?;
        Ok(id)
    }

    pub fn increment_send_count(&self, message_id: i64) -> Result<(), String> {
        let conn = db::connection()?;
        conn.execute(
            "UPDATE message SET send_count = send_count + 1 WHERE id = ?1",
            params![message_id],
        )
        .map(|_| ())
        .map_err(|err| err.to_string())
    }

    pub fn mark_ack(&self, message_id: i64) -> Result<(), String> {
        let conn = db::connection()?;
        conn.execute(
            "UPDATE message SET ack_status = 1, sending_status = 1 WHERE id = ?1",
            params![message_id],
        )
        .map(|_| ())
        .map_err(|err| err.to_string())
    }

    pub fn mark_send_failed(&self, message_id: i64) -> Result<(), String> {
        let conn = db::connection()?;
        conn.execute(
            "UPDATE message SET sending_status = 0 WHERE id = ?1",
            params![message_id],
        )
        .map(|_| ())
        .map_err(|err| err.to_string())
    }

    pub fn list_pending_messages(&self, max_attempts: i32) -> Result<Vec<MessageEntity>, String> {
        let table_def = message_table_def();
        let sql = format!(
            "SELECT * FROM {} WHERE ack_status = 0 AND send_count < ? AND sending_status = 0 ORDER BY created_at ASC",
            table_def.name
        );
        let conn = db::connection()?;
        let mut stmt = conn.prepare(&sql).map_err(|err| err.to_string())?;
        let mut rows = stmt
            .query(params![max_attempts])
            .map_err(|err| err.to_string())?;
        let mut result = Vec::new();
        while let Some(row) = rows.next().map_err(|err| err.to_string())? {
            result.push(Self::map_row(row).map_err(|err| err.to_string())?);
        }
        Ok(result)
    }
}
