use once_cell::sync::OnceCell;

use crate::common::{db, Repository};
use crate::domain::{log_table_def, LogEntity};

static INSTANCE: OnceCell<LogService> = OnceCell::new();

pub struct LogService {
    repo: Repository<LogEntity>,
}

impl LogService {
    pub fn init() -> Result<(), String> {
        let service = LogService {
            repo: Repository::new(log_table_def()),
        };
        service.ensure_schema()?;
        INSTANCE
            .set(service)
            .map_err(|_| "LogService already initialized".to_string())
            .map(|_| crate::common::logging::flush_log_buffer_if_ready())
    }

    pub fn get() -> &'static LogService {
        INSTANCE.get().expect("LogService is not initialized")
    }

    pub fn get_opt() -> Option<&'static LogService> {
        INSTANCE.get()
    }

    pub fn append_line(
        &self,
        source: &str,
        level: &str,
        target: &str,
        message: &str,
        timestamp_ms: i64,
    ) -> Result<(), String> {
        let entry = LogEntity {
            id: None,
            source: source.to_string(),
            level: level.to_string(),
            target: target.to_string(),
            message: message.to_string(),
            timestamp_ms,
        };
        self.repo.insert(entry).map(|_| ()).map_err(|err| err.to_string())
    }

    pub fn is_ready() -> bool {
        INSTANCE.get().is_some()
    }

    fn ensure_schema(&self) -> Result<(), String> {
        let conn = db::connection()?;
        let ddl = log_table_def().create_table_sql();
        conn.execute(&ddl, []).map_err(|err| err.to_string())?;
        for index_sql in log_table_def().create_index_sqls() {
            conn.execute(&index_sql, [])
                .map_err(|err| err.to_string())?;
        }
        Ok(())
    }
}
