use once_cell::sync::OnceCell;
use rusqlite::{types::Value, Row};

use crate::common::QueryType;
use crate::{
    common::{
        db,
        repository::{PageResult, QueryCondition, Repository, SortOrder},
    },
    domain::{friend_table_def, FriendEntity},
};

static INSTANCE: OnceCell<FriendService> = OnceCell::new();

pub struct FriendService {
    pub repo: Repository<FriendEntity>,
}

impl FriendService {
    pub fn init() -> Result<(), String> {
        let service = FriendService {
            repo: Repository::new(friend_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "FriendService already initialized".to_string())
    }

    pub fn get() -> &'static FriendService {
        INSTANCE.get_or_init(|| {
            let service = FriendService {
                repo: Repository::new(friend_table_def()),
            };
            if let Err(err) = service.ensure_schema() {
                panic!("FriendService auto init failed: {}", err);
            }
            service
        })
    }

    pub fn list(
        &self,
        conditions: &[QueryCondition],
        page: u32,
        page_size: u32,
    ) -> Result<PageResult<FriendEntity>, String> {
        self.repo.query_by_page(
            conditions,
            Some(("created_at", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row,
        )
    }

    pub fn list_all(&self) -> Result<Vec<FriendEntity>, String> {
        self.repo.query_all(Self::map_row)
    }

    pub fn list_ids(&self) -> Result<Vec<i64>, String> {
        let conn = db::connection()?;
        let mut stmt = conn
            .prepare(&format!(
                "SELECT friend_id FROM {}",
                friend_table_def().name
            ))
            .map_err(|err| err.to_string())?;
        let mut rows = stmt.query([]).map_err(|err| err.to_string())?;
        let mut ids = Vec::new();
        while let Some(row) = rows.next().map_err(|err| err.to_string())? {
            ids.push(row.get("friend_id").map_err(|err| err.to_string())?);
        }
        Ok(ids)
    }

    pub fn get_by_friend_id(&self, friend_id: i64) -> Result<Option<FriendEntity>, String> {
        let conditions = vec![QueryCondition::new(
            "friend_id",
            QueryType::Equal,
            vec![Value::Integer(friend_id)],
        )];
        self.repo.query_one(&conditions, Self::map_row)
    }

    /// socket 推送资料变更时更新本地好友缓存。
    pub fn apply_profile_update(
        &self,
        friend_id: i64,
        nickname: Option<String>,
        avatar: Option<String>,
        updated_at: i64,
    ) -> Result<(), String> {
        if nickname.is_none() && avatar.is_none() {
            return Ok(());
        }
        let mut entity = self
            .get_by_friend_id(friend_id)?
            .unwrap_or_else(|| FriendEntity::new(friend_id, updated_at));
        if let Some(nick) = nickname {
            entity.nickname = Some(nick);
        }
        if let Some(av) = avatar {
            entity.avatar = av;
        }
        if entity.created_at == 0 {
            entity.created_at = updated_at;
        }
        if entity.id.is_some() {
            self.repo.update(entity)?;
        } else {
            self.repo.insert(entity)?;
        }
        Ok(())
    }

    /// 确保好友记录存在，通常用于好友申请被同意后的落库。
    pub fn ensure_friend(
        &self,
        friend_id: i64,
        remark: Option<String>,
        nickname: Option<String>,
        created_at: i64,
    ) -> Result<(), String> {
        let mut entity = self
            .get_by_friend_id(friend_id)?
            .unwrap_or_else(|| FriendEntity::new(friend_id, created_at));
        if let Some(r) = remark {
            entity.remark = Some(r);
        }
        if let Some(nick) = nickname {
            if !nick.trim().is_empty() {
                entity.nickname = Some(nick);
            }
        }
        if entity.created_at == 0 {
            entity.created_at = created_at;
        }
        if entity.id.is_some() {
            self.repo.update(entity)?;
        } else {
            self.repo.insert(entity)?;
        }
        Ok(())
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = friend_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for index_sql in friend_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    fn map_row(row: &Row) -> Result<FriendEntity, rusqlite::Error> {
        let nickname: String = row.get("nickname")?;
        let remark: String = row.get("remark")?;
        Ok(FriendEntity {
            id: Some(row.get("id")?),
            friend_id: row.get("friend_id")?,
            avatar: row.get("avatar")?,
            nickname: normalize_optional(nickname),
            remark: normalize_optional(remark),
            email: normalize_optional(row.get("email")?),
            phone: normalize_optional(row.get("phone")?),
            last_login_at: row.get("last_login_at").ok(),
            created_at: row.get("created_at")?,
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
