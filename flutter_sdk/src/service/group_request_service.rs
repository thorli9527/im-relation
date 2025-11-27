use once_cell::sync::OnceCell;
use rusqlite::{types::Value, Row};

use crate::common::{
    db,
    repository::{PageResult, QueryCondition, QueryType, Repository, SortOrder},
};
use crate::domain::{group_request_table_def, GroupRequestEntity};
use crate::generated::message::{GroupJoinDecisionPayload, GroupJoinRequestPayload};

static INSTANCE: OnceCell<GroupRequestService> = OnceCell::new();

pub struct GroupRequestService {
    repo: Repository<GroupRequestEntity>,
}

impl GroupRequestService {
    pub fn init() -> Result<(), String> {
        let service = GroupRequestService {
            repo: Repository::new(group_request_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "GroupRequestService already initialized".to_string())
    }

    pub fn get() -> &'static Self {
        INSTANCE
            .get()
            .expect("GroupRequestService is not initialized")
    }

    pub fn upsert_request(&self, payload: &GroupJoinRequestPayload) -> Result<(), String> {
        let mut entity = self
            .get_by_request_id(payload.request_id as i64)?
            .unwrap_or_else(|| {
                GroupRequestEntity::new(
                    payload.request_id as i64,
                    payload.group_id,
                    payload.applicant_id,
                    payload.created_at,
                )
            });
        entity.reason = payload.reason.clone();
        entity.via_member_ids = payload.via_member_ids.clone();
        entity.created_at = payload.created_at;
        entity.updated_at = payload.created_at;
        self.upsert_entity(entity)
    }

    pub fn apply_decision(
        &self,
        payload: &GroupJoinDecisionPayload,
        decided_at: i64,
    ) -> Result<(), String> {
        let mut entity = self
            .get_by_request_id(payload.request_id as i64)?
            .unwrap_or_else(|| {
                GroupRequestEntity::new(
                    payload.request_id as i64,
                    payload.group_id,
                    0,
                    decided_at,
                )
            });
        entity.decided_at = Some(decided_at);
        entity.approved = Some(payload.approved);
        entity.remark = normalize_optional(&payload.remark);
        entity.approved_member_ids = payload.approved_member_ids.clone();
        entity.updated_at = decided_at;
        self.upsert_entity(entity)
    }

    pub fn list(
        &self,
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<GroupRequestEntity>, String> {
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
    ) -> Result<Option<GroupRequestEntity>, String> {
        let conditions = vec![QueryCondition::new(
            "request_id",
            QueryType::Equal,
            vec![Value::Integer(request_id)],
        )];
        self.repo.query_one(&conditions, Self::map_row)
    }

    fn upsert_entity(&self, mut entity: GroupRequestEntity) -> Result<(), String> {
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
        let ddl = group_request_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for index_sql in group_request_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<GroupRequestEntity, rusqlite::Error> {
        let via_member_ids: String = row.get("via_member_ids")?;
        let approved_member_ids: String = row.get("approved_member_ids")?;
        let remark: String = row.get("remark")?;
        Ok(GroupRequestEntity {
            id: Some(row.get("id")?),
            request_id: row.get("request_id")?,
            group_id: row.get("group_id")?,
            applicant_id: row.get("applicant_id")?,
            reason: row.get("reason")?,
            created_at: row.get("created_at")?,
            via_member_ids: serde_json::from_str(&via_member_ids).unwrap_or_default(),
            decided_at: row.get::<_, Option<i64>>("decided_at")?,
            approved: row.get::<_, Option<i64>>("approved")?.map(|v| v != 0),
            remark: normalize_optional(&remark),
            approved_member_ids: serde_json::from_str(&approved_member_ids).unwrap_or_default(),
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
