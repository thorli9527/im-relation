use std::time::{SystemTime, UNIX_EPOCH};

use once_cell::sync::OnceCell;
use rusqlite::{params, types::Value, OptionalExtension, Row, ToSql};

use crate::{
    api::app_api_types::{CachedGroupMembersQuery, GroupMember, GroupMembersResult},
    api::user_api,
    common::{
        db,
        repository::{QueryCondition, QueryType, Repository, SortOrder},
    },
    domain::{group_member_table_def, GroupMemberEntity},
};

static INSTANCE: OnceCell<GroupMemberService> = OnceCell::new();
const GROUP_MEMBER_TTL_MS: i64 = 10 * 60 * 1000; // 10分钟缓存
const GROUP_MEMBER_PAGE_SIZE: u32 = 100;

pub struct GroupMemberService {
    pub repo: Repository<GroupMemberEntity>,
}

impl GroupMemberService {
    pub fn init() -> Result<(), String> {
        let service = GroupMemberService {
            repo: Repository::new(group_member_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "GroupMemberService already initialized".to_string())
    }

    pub fn get() -> &'static GroupMemberService {
        INSTANCE
            .get()
            .expect("GroupMemberService is not initialized")
    }

    pub fn list_by_group(
        &self,
        query: CachedGroupMembersQuery,
    ) -> Result<GroupMembersResult, String> {
        let conditions = vec![QueryCondition::new(
            "group_id",
            QueryType::Equal,
            vec![rusqlite::types::Value::Integer(query.group_id)],
        )];
        let page = query.page.unwrap_or(1);
        let page_size = query.page_size.unwrap_or(50).clamp(1, 500);
        let page_data = self.repo.query_by_page(
            &conditions,
            Some(("updated_at", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row,
        )?;
        Ok(GroupMembersResult {
            members: page_data
                .items
                .into_iter()
                .map(|m| GroupMember {
                    group_id: m.group_id,
                    member_id: m.member_id,
                    nickname: m.nickname,
                    avatar: m.avatar.unwrap_or_default(),
                    role: m.role,
                })
                .collect(),
            page,
            page_size,
            has_more: page_data.has_next,
        })
    }

    pub fn get_member(
        &self,
        group_id: i64,
        member_id: i64,
    ) -> Result<Option<GroupMemberEntity>, String> {
        let conditions = vec![
            QueryCondition::new(
                "group_id",
                QueryType::Equal,
                vec![rusqlite::types::Value::Integer(group_id)],
            ),
            QueryCondition::new(
                "member_id",
                QueryType::Equal,
                vec![rusqlite::types::Value::Integer(member_id)],
            ),
        ];
        self.repo.query_one(&conditions, Self::map_row)
    }

    /// 根据资料事件批量刷新本地群成员昵称/头像。
    pub fn apply_profile_update(
        &self,
        member_id: i64,
        nickname: String,
        avatar: Option<String>,
        updated_at: i64,
        version: Option<i64>,
    ) -> Result<(), String> {
        if nickname.is_empty() && avatar.is_none() && version.is_none() {
            return Ok(());
        }
        let conditions = vec![QueryCondition::new(
            "member_id",
            QueryType::Equal,
            vec![Value::Integer(member_id)],
        )];
        let mut members = self
            .repo
            .query_list(&conditions, Self::map_row)
            .map_err(|err| err.to_string())?;
        if members.is_empty() {
            return Ok(());
        }
        for mut m in members.drain(..) {
            if let Some(ver) = version {
                if ver < m.version {
                    continue;
                }
                m.version = ver;
            }
            if !nickname.is_empty() {
                m.nickname = nickname.clone();
            }
            if let Some(av) = avatar.clone() {
                m.avatar = Some(av);
            }
            m.updated_at = updated_at;
            self.repo.update(m)?;
        }
        Ok(())
    }

    pub fn refresh_group_members(
        &self,
        session_token: &str,
        group_id: i64,
        force_refresh: bool,
    ) -> Result<(Vec<GroupMember>, bool, bool), String> {
        let now = current_millis();
        let cached_ts = self.latest_updated_at(group_id)?;
        if !force_refresh {
            if let Some(ts) = cached_ts {
                if now - ts < GROUP_MEMBER_TTL_MS {
                    let cached = self.list_all_by_group(group_id)?;
                    return Ok((cached, true, false));
                }
            }
        }

        match self.fetch_and_replace(session_token, group_id, now) {
            Ok(fetched) => Ok((fetched, false, false)),
            Err(err) => {
                let cached = self.list_all_by_group(group_id)?;
                if cached.is_empty() {
                    Err(err)
                } else {
                    Ok((cached, true, true))
                }
            }
        }
    }

    fn fetch_and_replace(
        &self,
        session_token: &str,
        group_id: i64,
        fetched_at: i64,
    ) -> Result<Vec<GroupMember>, String> {
        let mut page = 1;
        let mut members = Vec::new();
        loop {
            let req = crate::api::app_api_types::GroupMembersQuery {
                session_token: session_token.to_string(),
                group_id,
                page: Some(page),
                page_size: Some(GROUP_MEMBER_PAGE_SIZE),
            };
            let resp = user_api::get_group_members(req)?;
            for m in &resp.members {
                members.push(m.clone());
            }
            if !resp.has_more {
                break;
            }
            page += 1;
        }

        let mut conn = db::connection()?;
        let tx = conn.transaction().map_err(|err| err.to_string())?;
        tx.execute(
            &format!(
                "DELETE FROM {} WHERE group_id = ?1",
                group_member_table_def().name
            ),
            params![group_id],
        )
        .map_err(|err| err.to_string())?;

        for member in &members {
            let entity = GroupMemberEntity {
                id: None,
                group_id,
                member_id: member.member_id,
                nickname: member.nickname.clone(),
                avatar: Some(member.avatar.clone()),
                role: member.role,
                muted: false,
                join_time: 0,
                updated_at: fetched_at,
                version: 0,
            };
            self.insert_with_tx(&tx, entity)?;
        }
        tx.commit().map_err(|err| err.to_string())?;
        Ok(members)
    }

    fn list_all_by_group(&self, group_id: i64) -> Result<Vec<GroupMember>, String> {
        let conditions = vec![QueryCondition::new(
            "group_id",
            QueryType::Equal,
            vec![rusqlite::types::Value::Integer(group_id)],
        )];
        let all = self
            .repo
            .query_list(&conditions, Self::map_row)
            .map_err(|err| err.to_string())?;
        Ok(all
            .into_iter()
            .map(|m| GroupMember {
                group_id: m.group_id,
                member_id: m.member_id,
                nickname: m.nickname,
                avatar: m.avatar.unwrap_or_default(),
                role: m.role,
            })
            .collect())
    }

    fn latest_updated_at(&self, group_id: i64) -> Result<Option<i64>, String> {
        let conn = db::connection()?;
        let mut stmt = conn
            .prepare(&format!(
                "SELECT MAX(updated_at) as ts FROM {} WHERE group_id = ?1",
                group_member_table_def().name
            ))
            .map_err(|err| err.to_string())?;
        let ts: Option<i64> = stmt
            .query_row(params![group_id], |row| row.get(0))
            .optional()
            .map_err(|err| err.to_string())?;
        Ok(ts)
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = group_member_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for sql in group_member_table_def().create_index_sqls() {
            conn.execute(&sql, []).map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<GroupMemberEntity, rusqlite::Error> {
        Ok(GroupMemberEntity {
            id: Some(row.get("id")?),
            group_id: row.get("group_id")?,
            member_id: row.get("member_id")?,
            nickname: row.get("nickname")?,
            avatar: normalize_optional(row.get("avatar")?),
            role: row.get("role")?,
            muted: row.get::<_, i64>("muted")? != 0,
            join_time: row.get("join_time")?,
            updated_at: row.get("updated_at")?,
            version: row.get("version")?,
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
impl GroupMemberService {
    fn insert_with_tx(
        &self,
        tx: &rusqlite::Transaction,
        entity: GroupMemberEntity,
    ) -> Result<usize, String> {
        use crate::common::repository::TableEntity;
        let column_values = entity.column_values();
        let columns: Vec<&str> = column_values.iter().map(|c| c.name).collect();
        let placeholders = vec!["?"; columns.len()].join(", ");
        let sql = format!(
            "INSERT INTO {} ({}) VALUES ({})",
            group_member_table_def().name,
            columns.join(", "),
            placeholders
        );
        let owned_values: Vec<rusqlite::types::Value> =
            column_values.iter().map(|c| c.value.clone()).collect();
        let params: Vec<&dyn ToSql> = owned_values.iter().map(|v| v as &dyn ToSql).collect();
        tx.execute(&sql, params.as_slice())
            .map_err(|err| err.to_string())
    }
}

fn current_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|dur| dur.as_millis() as i64)
        .unwrap_or_default()
}
