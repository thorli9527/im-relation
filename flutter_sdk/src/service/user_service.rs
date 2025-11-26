use std::time::{SystemTime, UNIX_EPOCH};

use crate::api::app_api::LoginResult;
use once_cell::sync::OnceCell;
use rusqlite::Row;

use crate::common::{
    db,
    repository::{QueryCondition, QueryType, Repository, SortOrder},
};
use crate::domain::user_entity::{user_table_def, UserInfoEntity};

static INSTANCE: OnceCell<UserService> = OnceCell::new();

pub struct UserService {
    repo: Repository<UserInfoEntity>,
}

impl UserService {
    pub fn init() -> Result<(), String> {
        let service = UserService {
            repo: Repository::new(user_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "UserService already initialized".to_string())
    }

    pub fn get() -> &'static Self {
        INSTANCE.get().expect("UserService is not initialized")
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = user_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for index_sql in user_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    /// 登录后缓存用户信息，便于后续会话/好友头像、别名等展示。
    pub fn upsert_from_login(&self, login: &LoginResult) -> Result<(), String> {
        let now = current_millis();
        let entity = UserInfoEntity {
            id: None,
            uid: login.uid,
            name: login.name.clone(),
            avatar: login.avatar.clone(),
            nickname: login.nickname.clone(),
            session_token: Some(login.token.clone()),
            expires_at: login.expires_at as i64,
            version: login.version as i64,
            gender: login.gender,
            country: login.country.clone(),
            language: login.language.clone(),
            email: login.email.clone(),
            phone: login.phone.clone(),
            updated_at: now,
        };
        self.upsert(entity)
    }

    pub fn upsert(&self, mut entity: UserInfoEntity) -> Result<(), String> {
        if let Some(existing) = self.get_by_uid(entity.uid)? {
            entity.id = existing.id;
            self.repo.update(entity)?;
        } else {
            self.repo.insert(entity)?;
        }
        Ok(())
    }

    /// 应用资料变更（昵称/头像/版本），用于 socket 推送。
    pub fn apply_profile_update(
        &self,
        uid: i64,
        nickname: Option<String>,
        avatar: Option<String>,
        version: Option<i64>,
        updated_at: i64,
    ) -> Result<(), String> {
        if nickname.is_none() && avatar.is_none() && version.is_none() {
            return Ok(());
        }
        let mut entity = self
            .get_by_uid(uid)?
            .unwrap_or_else(|| UserInfoEntity::new(uid));
        if let Some(nick) = nickname {
            entity.nickname = Some(nick);
        }
        if let Some(av) = avatar {
            entity.avatar = av;
        }
        if let Some(ver) = version {
            if ver > entity.version {
                entity.version = ver;
            }
        }
        entity.updated_at = updated_at;
        if entity.id.is_some() {
            self.repo.update(entity)?;
        } else {
            self.repo.insert(entity)?;
        }
        Ok(())
    }

    pub fn get_by_uid(&self, uid: i64) -> Result<Option<UserInfoEntity>, String> {
        self.repo.query_one(
            &[QueryCondition::new(
                "uid",
                QueryType::Equal,
                vec![rusqlite::types::Value::Integer(uid)],
            )],
            Self::map_row,
        )
    }

    pub fn list_all(&self) -> Result<Vec<UserInfoEntity>, String> {
        self.repo.query_all(Self::map_row)
    }

    /// 最近一次登录的用户。
    pub fn latest_user(&self) -> Result<Option<UserInfoEntity>, String> {
        let page = self.repo.query_by_page(
            &[],
            Some(("updated_at", SortOrder::Desc)),
            1,
            1,
            Self::map_row,
        )?;
        Ok(page.items.into_iter().next())
    }

    fn map_row(row: &Row) -> Result<UserInfoEntity, rusqlite::Error> {
        let nickname: String = row.get("nickname")?;
        let session_token: String = row.get("session_token")?;
        let expires_at: i64 = row.get("expires_at")?;
        let country: String = row.get("country")?;
        let language: String = row.get("language")?;
        let email: String = row.get("email")?;
        let phone: String = row.get("phone")?;
        Ok(UserInfoEntity {
            id: Some(row.get("id")?),
            uid: row.get("uid")?,
            name: row.get("name")?,
            avatar: row.get("avatar")?,
            nickname: normalize_optional(nickname),
            session_token: normalize_optional(session_token),
            expires_at,
            version: row.get("version")?,
            gender: row.get("gender")?,
            country: normalize_optional(country),
            language: normalize_optional(language),
            email: normalize_optional(email),
            phone: normalize_optional(phone),
            updated_at: row.get("updated_at")?,
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

fn current_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|dur| dur.as_millis() as i64)
        .unwrap_or_default()
}
