use crate::config::DatabaseConfig;
use anyhow::{anyhow, Result};
use directories::ProjectDirs;
use once_cell::sync::OnceCell;
use rusqlite::Connection;
use std::fs;
use std::path::Path;
use std::sync::{Mutex, MutexGuard};

const APP_QUALIFIER: &str = "com";
const APP_ORGANIZATION: &str = "imcloud";
const APP_APPLICATION: &str = "im_relation";
const DB_FILE_NAME: &str = "config.sqlite3";

#[derive(Debug)]
pub struct Db {
    conn: Mutex<Connection>,
    path: String,
}

impl Db {
    pub fn new(conn: Connection, path: String) -> Self {
        Self {
            conn: Mutex::new(conn),
            path,
        }
    }

    pub fn init() -> Result<()> {
        let default = DatabaseConfig::default();
        Self::init_with_config(&default)
    }

    pub fn init_with_config(config: &DatabaseConfig) -> Result<()> {
        let path = resolve_db_path(config)?;
        let conn = open_connection(&path)?;
        INSTANCE
            .set(Db::new(conn, path))
            .map_err(|_| anyhow!("config database already initialized"))
    }

    pub fn ensure_initialized(config: &DatabaseConfig) -> Result<()> {
        if INSTANCE.get().is_none() {
            Self::init_with_config(config)?;
        }
        Ok(())
    }

    pub fn get() -> &'static Db {
        INSTANCE.get().expect("config database is not initialized")
    }

    pub fn conn(&self) -> Result<MutexGuard<'_, Connection>> {
        self.conn
            .lock()
            .map_err(|_| anyhow!("config database connection lock poisoned"))
    }

    pub fn path(&self) -> &str {
        &self.path
    }
}

static INSTANCE: OnceCell<Db> = OnceCell::new();

pub fn connection() -> Result<MutexGuard<'static, Connection>, String> {
    Db::get().conn().map_err(|err| err.to_string())
}

pub fn init() -> Result<()> {
    Db::init()
}

pub fn init_with_config(config: &DatabaseConfig) -> Result<()> {
    Db::init_with_config(config)
}

pub fn ensure_initialized(config: &DatabaseConfig) -> Result<()> {
    Db::ensure_initialized(config)
}

fn resolve_db_path(config: &DatabaseConfig) -> Result<String> {
    if let Some(path) = &config.path {
        return Ok(path.clone());
    }
    default_db_path()
}

fn open_connection(db_path: &str) -> Result<Connection> {
    if let Some(parent) = Path::new(db_path).parent() {
        if !parent.exists() {
            fs::create_dir_all(parent)
                .map_err(|err| anyhow!("failed to create database directory: {err}"))?;
        }
    }
    Connection::open(db_path).map_err(|err| anyhow!("open database error: {err}"))
}

fn default_db_path() -> Result<String> {
    let dirs = ProjectDirs::from(APP_QUALIFIER, APP_ORGANIZATION, APP_APPLICATION)
        .ok_or_else(|| anyhow!("unsupported platform for resolving data directory"))?;
    let db_path = dirs.data_dir().join(DB_FILE_NAME);
    Ok(db_path.to_string_lossy().into_owned())
}
