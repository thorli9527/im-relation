use crate::common::{db, repository::TableEntity};
use crate::domain::sync_state_entity::SyncStateEntity;

pub struct SyncStateService;

impl SyncStateService {
    pub fn init() -> Result<(), String> {
        let db = db::connection()?;
        let ddl = crate::domain::sync_state_entity::SYNC_STATE_TABLE_DEF.create_table_sql();
        db.execute_batch(&ddl).map_err(|e| e.to_string())?;
        Ok(())
    }

    /// 确保单行存在，若不存在则插入默认游标。
    pub fn ensure_row() -> Result<(), String> {
        let db = db::connection()?;
        let mut stmt = db
            .prepare("SELECT COUNT(1) FROM sync_state WHERE id = 1")
            .map_err(|e| e.to_string())?;
        let count: i64 = stmt
            .query_row([], |row| row.get(0))
            .map_err(|e| e.to_string())?;
        if count == 0 {
            let entity = SyncStateEntity::new();
            let mut cols = entity.column_values();
            let fields: Vec<String> = cols.iter().map(|c| c.name.to_string()).collect();
            let placeholders: Vec<String> = (0..cols.len()).map(|_| "?".to_string()).collect();
            let values: Vec<rusqlite::types::Value> = cols.drain(..).map(|c| c.value).collect();
            let sql = format!(
                "INSERT INTO sync_state ({}) VALUES ({})",
                fields.join(", "),
                placeholders.join(", ")
            );
            let mut insert_stmt = db.prepare(&sql).map_err(|e| e.to_string())?;
            let params: Vec<&dyn rusqlite::ToSql> =
                values.iter().map(|v| v as &dyn rusqlite::ToSql).collect();
            insert_stmt
                .execute(rusqlite::params_from_iter(params))
                .map_err(|e| e.to_string())?;
        }
        Ok(())
    }

    pub fn update_seqs(friend_seq: i64, group_seq: i64, system_seq: i64) -> Result<(), String> {
        let db = db::connection()?;
        let sql = "UPDATE sync_state SET friend_last_seq = ?, group_last_seq = ?, system_last_seq = ? WHERE id = 1";
        db.execute(sql, rusqlite::params![friend_seq, group_seq, system_seq])
            .map(|_| ())
            .map_err(|e| e.to_string())
    }

    pub fn fetch() -> Result<SyncStateEntity, String> {
        let db = db::connection()?;
        let mut stmt = db
            .prepare("SELECT id, friend_last_seq, group_last_seq, system_last_seq FROM sync_state WHERE id = 1")
            .map_err(|e| e.to_string())?;
        stmt.query_row([], |row| {
            Ok(SyncStateEntity {
                id: row.get("id")?,
                friend_last_seq: row.get("friend_last_seq")?,
                group_last_seq: row.get("group_last_seq")?,
                system_last_seq: row.get("system_last_seq")?,
            })
        })
        .map_err(|e| e.to_string())
    }
}
