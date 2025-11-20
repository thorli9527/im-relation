use crate::common::{db, PageResult, QueryCondition, QueryType, Repository, SortOrder};
use crate::domain::{config_table_def, ConfigEntity};
use once_cell::sync::OnceCell;
use rusqlite::types::Value;
use rusqlite::Row;

static INSTANCE: OnceCell<ConfigService> = OnceCell::new();

pub struct ConfigService {
    pub repo: Repository<ConfigEntity>,
}

impl ConfigService {
    pub fn init() -> Result<(), String> {
        let service = ConfigService {
            repo: Repository::new(config_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "ConfigService already initialized".to_string())
    }

    pub fn get() -> &'static ConfigService {
        INSTANCE.get().expect("ConfigService is not initialized")
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = config_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for index_sql in config_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    pub fn upsert_value(&self, code: &str, value: &str) -> Result<(), String> {
        let conn = db::connection()?;
        conn.execute(
            "
            INSERT INTO config(code, value) VALUES(?1, ?2)
            ON CONFLICT(code) DO UPDATE SET value = excluded.value
            ",
            (&code, &value),
        )
        .map(|_| ())
        .map_err(|err| err.to_string())
    }

    pub fn get_value(&self, code: &str) -> Result<Option<String>, String> {
        let condition = QueryCondition::new(
            "code",
            QueryType::Equal,
            vec![Value::Text(code.to_string())],
        );
        self.repo
            .query_one(std::slice::from_ref(&condition), |row| {
                row.get::<_, String>("value")
            })
    }

    pub fn list_all(&self) -> Result<Vec<ConfigEntity>, String> {
        self.repo.query_all(Self::map_row_to_entity)
    }

    pub fn list(&self, page: u32, page_size: u32) -> Result<PageResult<ConfigEntity>, String> {
        self.repo.query_by_page(
            &[],
            Some(("id", SortOrder::Desc)),
            page,
            page_size,
            Self::map_row_to_entity,
        )
    }

    pub fn delete(&self, code: &str) -> Result<(), String> {
        let conn = db::connection()?;
        conn.execute("DELETE FROM config WHERE code = ?", [&code])
            .map(|_| ())
            .map_err(|err| err.to_string())
    }

    pub fn map_row_to_entity(row: &Row) -> Result<ConfigEntity, rusqlite::Error> {
        Ok(ConfigEntity {
            id: Some(row.get::<_, i64>("id")?),
            code: row.get::<_, String>("code")?,
            value: row.get::<_, String>("value")?,
        })
    }
}
