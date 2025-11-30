use once_cell::sync::OnceCell;
use rusqlite::{types::Value, Row};

use crate::common::{
    db,
    repository::{PageResult, QueryCondition, QueryType, Repository, SortOrder},
};
use crate::domain::{friend_request_table_def, FriendRequestEntity};
use crate::generated::message::{FriendRequestDecisionPayload, FriendRequestPayload};

static INSTANCE: OnceCell<FriendRequestService> = OnceCell::new();

pub struct FriendRequestService {
    repo: Repository<FriendRequestEntity>,
}

impl FriendRequestService {
    pub fn init() -> Result<(), String> {
        let service = FriendRequestService {
            repo: Repository::new(friend_request_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "FriendRequestService already initialized".to_string())
    }

    pub fn get() -> &'static Self {
        INSTANCE
            .get()
            .expect("FriendRequestService is not initialized")
    }

    pub fn upsert_request(&self, payload: &FriendRequestPayload) -> Result<(), String> {
        let mut entity = self
            .get_by_request_id(payload.request_id as i64)?
            .unwrap_or_else(|| FriendRequestEntity::new(
                payload.request_id as i64,
                payload.from_uid,
                payload.to_uid,
                payload.created_at,
            ));
        entity.reason = payload.reason.clone();
        entity.source = payload.source;
        entity.remark = normalize_optional(&payload.remark);
        entity.nickname = normalize_optional(&payload.nickname);
        entity.created_at = payload.created_at;
        entity.updated_at = payload.created_at;
        self.upsert_entity(entity)
    }

    pub fn apply_decision(
        &self,
        payload: &FriendRequestDecisionPayload,
        sender_id: i64,
        receiver_id: i64,
        timestamp: i64,
    ) -> Result<(), String> {
        let decided_at = if payload.decided_at > 0 {
            payload.decided_at
        } else {
            timestamp
        };
        let mut entity = self
            .get_by_request_id(payload.request_id as i64)?
            .unwrap_or_else(|| FriendRequestEntity::new(
                payload.request_id as i64,
                sender_id,
                receiver_id,
                timestamp,
            ));
        entity.decided_at = Some(decided_at);
        entity.accepted = Some(payload.accepted);
        if let Some(existing) = normalize_optional(&payload.remark) {
            entity.peer_remark = Some(existing);
        }
        if let Some(nick) = normalize_optional(&payload.nickname) {
            entity.peer_nickname = Some(nick);
        }
        entity.updated_at = decided_at;
        self.upsert_entity(entity)
    }

    pub fn list(
        &self,
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<FriendRequestEntity>, String> {
        self.repo.query_by_page(
            &[],
            Some(("created_at", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row,
        )
    }

    pub fn get_by_request_id(
        &self,
        request_id: i64,
    ) -> Result<Option<FriendRequestEntity>, String> {
        let conditions = vec![QueryCondition::new(
            "request_id",
            QueryType::Equal,
            vec![Value::Integer(request_id)],
        )];
        self.repo.query_one(&conditions, Self::map_row)
    }

    fn upsert_entity(&self, mut entity: FriendRequestEntity) -> Result<(), String> {
        if let Some(existing) = self.get_by_request_id(entity.request_id)? {
            entity.id = existing.id;
            self.repo.update(entity)?;
        } else {
            self.repo.insert(entity)?;
        }
        Ok(())
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = friend_request_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        // 迁移补齐对端备注/昵称列，兼容旧表。
        for (col, alter) in [
            ("peer_remark", "ALTER TABLE friend_request ADD COLUMN peer_remark TEXT NOT NULL DEFAULT ''"),
            ("peer_nickname", "ALTER TABLE friend_request ADD COLUMN peer_nickname TEXT NOT NULL DEFAULT ''"),
        ] {
            ensure_column(&conn, friend_request_table_def().name, col, alter)?;
        }
        for index_sql in friend_request_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<FriendRequestEntity, rusqlite::Error> {
        let remark: String = row.get("remark")?;
        let nickname: String = row.get("nickname")?;
        let peer_remark: String = row.get("peer_remark")?;
        let peer_nickname: String = row.get("peer_nickname")?;
        let source: i64 = row.get("source")?;
        Ok(FriendRequestEntity {
            id: Some(row.get("id")?),
            request_id: row.get("request_id")?,
            from_uid: row.get("from_uid")?,
            to_uid: row.get("to_uid")?,
            reason: row.get("reason")?,
            source: source as i32,
            remark: normalize_optional(&remark),
            nickname: normalize_optional(&nickname),
            peer_remark: normalize_optional(&peer_remark),
            peer_nickname: normalize_optional(&peer_nickname),
            created_at: row.get("created_at")?,
            decided_at: row.get::<_, Option<i64>>("decided_at")?,
            accepted: row.get::<_, Option<i64>>("accepted")?.map(|v| v != 0),
            updated_at: row.get("updated_at")?,
        })
    }
}

fn normalize_optional(value: &str) -> Option<String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

fn ensure_column(
    conn: &rusqlite::Connection,
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
