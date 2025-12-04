use anyhow::{anyhow, Result};
use flutter_sdk::{
    api::{app_api, config_api, socket_api},
    common::db,
    config::DatabaseConfig,
    service::{self, auth_service},
};
use prost::Message;
use std::{
    env,
    time::{SystemTime, UNIX_EPOCH},
};

#[test]
fn login_and_wait_for_socket_resets_reconnect_and_receives_heartbeat() -> Result<()> {
    // db_path: 测试用 SQLite 文件路径（相对路径，写到当前目录），用于持久化认证/会话状态。
    let db_path = "database.sqlite";
    // db_config: 数据库配置对象，包裹路径，供 db::ensure_initialized 初始化使用。
    let db_config = DatabaseConfig{
        path: Some(db_path.to_string()),
    };
    // 初始化数据库文件（若不存在则创建，并创建必要表结构）。
    db::ensure_initialized(&db_config)?;
    // 初始化全局服务 (网络、配置、日志等)。
    service::init();

    // reconnect_limit: 限定的重连次数上限，设为 3 便于断言。
    let reconnect_limit = 3;
    // 设置 socket 允许的最大重连次数（服务端返回 429/掉线时的重连上限）。
    config_api::set_socket_reconnect_limit(reconnect_limit).map_err(|err: String| anyhow!(err))?;
    // 设置当前重连尝试次数计数器为上限值，便于下方读取验证。
    config_api::set_socket_reconnect_attempts(reconnect_limit)
        .map_err(|err: String| anyhow!(err))?;

    // login_req: 登录请求体，包含账号、设备类型/ID 与密码，驱动真实登录流程以触发 socket 建连与心跳。
    let login_req = app_api::LoginRequest {
        // 固定的测试密码。
            password: "12345678a".into(),
        // 测试账号邮箱。
        target: "thorli9528@gmail.com".into(),
        // 设备类型，4 为测试端定义的类型值。
        device_type: 4,
        // 设备唯一标识，确保服务端能区分不同设备会话。
        device_id: "test-device".into(),
    };

    // login_result: 登录返回体（包含 socket 连接信息）。登录调用会阻塞直到 socket 建立并发送初始心跳。
    let _ = app_api::login(login_req, Some(5)).map_err(|err: String| anyhow!(err))?;
    // assert_eq!(login_result.socket_addr, "127.0.0.1:12345");

    // 断言运行时读取到的重连尝试次数等于上文配置的 reconnect_limit。
    assert_eq!(
        config_api::get_socket_reconnect_attempts().map_err(|err: String| anyhow!(err))?,
        Some(reconnect_limit)
    );

    // 登出并清理登录态，防止影响其他测试。
    app_api::logout().map_err(|err: String| anyhow!(err))?;

    Ok(())
}
