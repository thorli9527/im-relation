use log::{LevelFilter, Metadata, Record};
use std::sync::Once;
use std::time::{SystemTime, UNIX_EPOCH};

static LOGGER: SimpleLogger = SimpleLogger;
static INIT: Once = Once::new();

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
            eprintln!(
                "[{}][{}][{}] {}",
                timestamp_millis(),
                record.level(),
                record.target(),
                record.args()
            );
        }
    }

    fn flush(&self) {}
}

fn timestamp_millis() -> String {
    match SystemTime::now().duration_since(UNIX_EPOCH) {
        Ok(dur) => format!("{:010}.{:03}", dur.as_secs(), dur.subsec_millis()),
        Err(_) => String::from("0"),
    }
}
