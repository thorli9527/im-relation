use flutter_rust_bridge::frb;
use log::Level;

/// 从 Dart/桌面侧桥接日志到 Rust logger（落地到文件与 SQLite 日志表）。
#[frb]
pub fn bridge_log(level: String, target: Option<String>, message: String) -> Result<(), String> {
    let lvl = level
        .parse::<Level>()
        .unwrap_or(Level::Info);
    let target = target.unwrap_or_else(|| "app_desktop".to_string());
    log::log!(target: &target, lvl, "{}", message);
    Ok(())
}
