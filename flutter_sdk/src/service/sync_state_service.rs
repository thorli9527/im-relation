use crate::common::db;
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
        use std::time::Duration;
        let db = db::connection()?;
        db.busy_timeout(Duration::from_secs(5))
            .map_err(|e| e.to_string())?;

        // 先检查是否已存在，避免重复写入。
        let count: i64 = db
            .query_row("SELECT COUNT(1) FROM sync_state WHERE id = 1", [], |row| {
                row.get(0)
            })
            .map_err(|e| e.to_string())?;
        if count == 0 {
            // 直接插入固定默认值，避免动态拼装带来的复杂度/潜在阻塞。
            db.execute(
                "INSERT INTO sync_state (id, friend_last_seq, group_last_seq, system_last_seq) VALUES (1, 0, 0, 0)",
                [],
            )
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
