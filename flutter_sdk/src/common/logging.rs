use chrono::{Local, Utc};
use log::{LevelFilter, Metadata, Record};
use std::fs::{self, File, OpenOptions};
use std::io::Write;
use std::path::Path;
use std::sync::{Mutex, Once, OnceLock};

use crate::service::log_service::LogService;

static LOGGER: SimpleLogger = SimpleLogger;
static INIT: Once = Once::new();
static LOG_FILE: OnceLock<Mutex<Option<File>>> = OnceLock::new();
static LOG_BUFFER: OnceLock<Mutex<Vec<BufferedLog>>> = OnceLock::new();
static LOG_SOURCE: OnceLock<String> = OnceLock::new();

#[derive(Clone)]
struct BufferedLog {
    timestamp_ms: i64,
    level: String,
    target: String,
    message: String,
}

/// 初始化日志（只执行一次）。支持通过环境变量 `FLUTTER_SDK_LOG` / `RUST_LOG`
/// 指定日志级别，默认使用 info。
pub fn init_logging() {
    INIT.call_once(|| {
        let level = resolve_level();
        match log::set_logger(&LOGGER) {
            Ok(_) => log::set_max_level(level),
            Err(err) => eprintln!("init_logging skipped: {err}"),
        }
    });
}

fn resolve_level() -> LevelFilter {
    let env_level = std::env::var("FLUTTER_SDK_LOG")
        .or_else(|_| std::env::var("RUST_LOG"))
        .unwrap_or_else(|_| "info".to_string());
    env_level
        .parse::<LevelFilter>()
        .unwrap_or(LevelFilter::Info)
}

struct SimpleLogger;

impl log::Log for SimpleLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= log::max_level()
    }

    fn log(&self, record: &Record) {
        if self.enabled(record.metadata()) {
            let line = format!(
                "[{}][{}][{}] {}",
                timestamp_human(),
                record.level(),
                record.target(),
                record.args()
            );
            eprintln!("{line}");
            append_to_file(&line);
            append_to_db(record);
        }
    }

    fn flush(&self) {}
}

fn timestamp_human() -> String {
    // Local time with milliseconds, e.g. 2025-02-12 10:30:15.123
    Local::now().format("%Y-%m-%d %H:%M:%S%.3f").to_string()
}

/// 追加日志到磁盘，默认写入 `logs/app.log`，可通过 `APP_LOG_PATH` 覆盖。
fn append_to_file(line: &str) {
    let guard = LOG_FILE
        .get_or_init(|| Mutex::new(open_log_file()))
        .lock();
    if let Ok(mut file_slot) = guard {
        if let Some(file) = file_slot.as_mut() {
            let _ = writeln!(file, "{line}");
        }
    }
}

fn open_log_file() -> Option<File> {
    let path = std::env::var("APP_LOG_PATH").unwrap_or_else(|_| "logs/app.log".to_string());
    let path_ref = Path::new(&path);
    if let Some(parent) = path_ref.parent() {
        if let Err(err) = fs::create_dir_all(parent) {
            eprintln!("init_logging skipped creating log dir: {err}");
            return None;
        }
    }
    match OpenOptions::new()
        .create(true)
        .append(true)
        .open(path_ref)
    {
        Ok(file) => Some(file),
        Err(err) => {
            eprintln!("init_logging skipped file logger: {err}");
            None
        }
    }
}

fn append_to_db(record: &Record) {
    let entry = BufferedLog {
        timestamp_ms: Utc::now().timestamp_millis(),
        level: record.level().to_string(),
        target: record.target().to_string(),
        message: record.args().to_string(),
    };
    persist_log(entry);
}

fn persist_log(entry: BufferedLog) {
    if let Some(service) = LogService::get_opt() {
        flush_buffer_with(service);
        if let Err(err) = service.append_line(
            resolve_log_source(),
            &entry.level,
            &entry.target,
            &entry.message,
            entry.timestamp_ms,
        ) {
            eprintln!("append log to db failed: {err}");
            buffer_log(entry);
        }
    } else {
        buffer_log(entry);
    }
}

fn flush_buffer_with(service: &LogService) {
    if let Ok(mut buf) = LOG_BUFFER.get_or_init(|| Mutex::new(Vec::new())).lock() {
        if buf.is_empty() {
            return;
        }
        let mut failed = Vec::new();
        for pending in buf.drain(..) {
            if let Err(err) = service.append_line(
                resolve_log_source(),
                &pending.level,
                &pending.target,
                &pending.message,
                pending.timestamp_ms,
            ) {
                eprintln!("flush buffered log failed: {err}");
                failed.push(pending);
            }
        }
        if !failed.is_empty() {
            buf.extend(failed);
        }
    }
}

fn buffer_log(entry: BufferedLog) {
    if let Ok(mut buf) = LOG_BUFFER.get_or_init(|| Mutex::new(Vec::new())).lock() {
        buf.push(entry);
    }
}

fn resolve_log_source() -> &'static str {
    LOG_SOURCE
        .get_or_init(|| {
            std::env::var("APP_LOG_SOURCE")
                .unwrap_or_else(|_| "flutter_sdk".to_string())
        })
        .as_str()
}

pub(crate) fn flush_log_buffer_if_ready() {
    if let Some(service) = LogService::get_opt() {
        flush_buffer_with(service);
    }
}
