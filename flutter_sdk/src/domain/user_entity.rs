use once_cell::sync::Lazy;
use rusqlite::types::Value;
use serde::{Deserialize, Serialize};

use crate::common::{
    repository::{ColumnValue, TableEntity},
    schema::{ColumnType, TableDef},
};
use crate::{column_def, table_def, unique_index};

pub fn init() {
    let _ = &*USER_TABLE_DEF;
}

/// 本地缓存的用户信息。
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UserInfoEntity {
    pub id: Option<i64>,
    pub uid: i64,
    pub name: String,
    pub avatar: String,
    pub alias: Option<String>,
    pub session_token: Option<String>,
    pub expires_at: i64,
    pub gender: i32,
    pub country: Option<String>,
    pub language: Option<String>,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub profile_version: i64,
    pub updated_at: i64,
}

impl UserInfoEntity {
    pub fn new(uid: i64) -> Self {
        Self {
            id: None,
            uid,
            name: String::new(),
            avatar: String::new(),
            alias: None,
            session_token: None,
            expires_at: 0,
            gender: 0,
            country: None,
            language: None,
            email: None,
            phone: None,
            profile_version: 0,
            updated_at: 0,
        }
    }
}

impl TableEntity for UserInfoEntity {
    fn column_values(&self) -> Vec<ColumnValue> {
        let mut cols = Vec::new();
        if let Some(id) = self.id {
            cols.push(ColumnValue::new("id", Value::Integer(id)));
        }
        cols.push(ColumnValue::new("uid", Value::Integer(self.uid)));
        cols.push(ColumnValue::new("name", Value::Text(self.name.clone())));
        cols.push(ColumnValue::new("avatar", Value::Text(self.avatar.clone())));
        cols.push(ColumnValue::new(
            "alias",
            Value::Text(self.alias.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "session_token",
            Value::Text(self.session_token.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "expires_at",
            Value::Integer(self.expires_at),
        ));
        cols.push(ColumnValue::new("gender", Value::Integer(self.gender as i64)));
        cols.push(ColumnValue::new(
            "country",
            Value::Text(self.country.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "language",
            Value::Text(self.language.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "email",
            Value::Text(self.email.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "phone",
            Value::Text(self.phone.clone().unwrap_or_default()),
        ));
        cols.push(ColumnValue::new(
            "profile_version",
            Value::Integer(self.profile_version),
        ));
        cols.push(ColumnValue::new(
            "updated_at",
            Value::Integer(self.updated_at),
        ));
        cols
    }

    fn primary_key(&self) -> Option<ColumnValue> {
        self.id.map(|id| ColumnValue::new("id", Value::Integer(id)))
    }
}

pub static USER_TABLE_DEF: Lazy<TableDef> = Lazy::new(|| {
    table_def! {
        "user_info",
        comment = "本地缓存的用户资料",
        columns = [
            column_def!(
                "id",
                ColumnType::Integer,
                constraints = "PRIMARY KEY AUTOINCREMENT",
                comment = "自增主键"
            ),
            column_def!(
                "uid",
                ColumnType::Integer,
                constraints = "NOT NULL UNIQUE",
                comment = "用户 ID"
            ),
            column_def!(
                "name",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "用户名/昵称"
            ),
            column_def!(
                "avatar",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "头像 URL"
            ),
            column_def!(
                "alias",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "别名"
            ),
            column_def!(
                "session_token",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "会话 token"
            ),
            column_def!(
                "expires_at",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "token 过期时间戳"
            ),
            column_def!(
                "gender",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "性别"
            ),
            column_def!(
                "country",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "国家"
            ),
            column_def!(
                "language",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "语言"
            ),
            column_def!(
                "email",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "邮箱"
            ),
            column_def!(
                "phone",
                ColumnType::Text,
                constraints = "NOT NULL DEFAULT ''",
                comment = "手机号"
            ),
            column_def!(
                "profile_version",
                ColumnType::Integer,
                constraints = "NOT NULL DEFAULT 0",
                comment = "资料版本"
            ),
            column_def!(
                "updated_at",
                ColumnType::Integer,
                constraints = "NOT NULL",
                comment = "本地更新时间（毫秒）"
            )
        ],
        indexes = [
            unique_index!("idx_user_uid", ["uid"])
        ]
    }
});

pub fn user_table_def() -> &'static TableDef {
    &USER_TABLE_DEF
}
