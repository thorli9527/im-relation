use once_cell::sync::OnceCell;
use rusqlite::{params, Row};

use crate::{
    common::{
        db,
        repository::{QueryCondition, QueryType, Repository, SortOrder},
    },
    domain::{read_cursor_table_def, ReadCursorEntity},
};

static INSTANCE: OnceCell<ReadCursorService> = OnceCell::new();

pub struct ReadCursorService {
    pub repo: Repository<ReadCursorEntity>,
}

impl ReadCursorService {
    pub fn init() -> Result<(), String> {
        let svc = ReadCursorService {
            repo: Repository::new(read_cursor_table_def()),
        };
        svc.ensure_schema()?;
        INSTANCE
            .set(svc)
            .map_err(|_| "ReadCursorService already initialized".to_string())
    }

    pub fn get() -> &'static Self {
        INSTANCE.get().expect("ReadCursorService is not initialized")
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = read_cursor_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        // 唯一索引确保同一个 uid/scene/target_id 只有一条记录。
        conn.execute(
            "CREATE UNIQUE INDEX IF NOT EXISTS idx_read_cursor_uni ON read_cursor(uid, scene, target_id)",
            [],
        )
        .map_err(|err| err.to_string())?;
        for sql in read_cursor_table_def().create_index_sqls() {
            conn.execute(&sql, []).map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    /// upsert 已读游标
    pub fn upsert_cursor(
        &self,
        uid: i64,
        scene: i32,
        target_id: i64,
        last_read_seq: i64,
    ) -> Result<(), String> {
        let updated_at = current_millis();
        let conn = db::connection()?;
        conn.execute(
            "INSERT INTO read_cursor (uid, scene, target_id, last_read_seq, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5)
             ON CONFLICT(uid, scene, target_id)
             DO UPDATE SET last_read_seq=excluded.last_read_seq, updated_at=excluded.updated_at",
            params![uid, scene, target_id, last_read_seq, updated_at],
        )
        .map(|_| ())
        .map_err(|err| err.to_string())
    }

    /// 查询单个目标的游标
    pub fn get_cursor(
        &self,
        uid: i64,
        scene: i32,
        target_id: i64,
    ) -> Result<Option<ReadCursorEntity>, String> {
        let conditions = vec![
            QueryCondition::new("uid", QueryType::Equal, vec![uid.into()]),
            QueryCondition::new("scene", QueryType::Equal, vec![scene.into()]),
            QueryCondition::new("target_id", QueryType::Equal, vec![target_id.into()]),
        ];
        self.repo.query_one(&conditions, Self::map_row)
    }

    /// 查询用户的所有游标，按更新时间倒序
    pub fn list_by_user(&self, uid: i64) -> Result<Vec<ReadCursorEntity>, String> {
        let conditions = vec![QueryCondition::new("uid", QueryType::Equal, vec![uid.into()])];
        self.repo.query_by_page(
            &conditions,
            Some(("updated_at", SortOrder::Desc)),
            1,
            1000,
            Self::map_row,
        ).map(|page| page.items)
    }

    fn map_row(row: &Row) -> Result<ReadCursorEntity, rusqlite::Error> {
        Ok(ReadCursorEntity {
            id: Some(row.get("id")?),
            uid: row.get("uid")?,
            scene: row.get("scene")?,
            target_id: row.get("target_id")?,
            last_read_seq: row.get("last_read_seq")?,
            updated_at: row.get("updated_at")?,
        })
    }
}

fn current_millis() -> i64 {
    use std::time::{SystemTime, UNIX_EPOCH};
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}
