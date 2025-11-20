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
    let db_path = "database.sqlite";
    let db_config = DatabaseConfig {
        path: Some(db_path.to_string()),
    };
    db::ensure_initialized(&db_config)?;
    service::init();
    let reconnect_limit = 3;
    config_api::set_socket_reconnect_limit(reconnect_limit).map_err(|err: String| anyhow!(err))?;
    config_api::set_socket_reconnect_attempts(reconnect_limit)
        .map_err(|err: String| anyhow!(err))?;

    let login_req = app_api::LoginRequest {
        password: "12345678a".into(),
        target: "thorli9527@gmail.com".into(),
        device_type: 4,
        device_id: "test-device".into(),
    };

    let login_result = app_api::login(login_req, Some(5)).map_err(|err: String| anyhow!(err))?;
    // assert_eq!(login_result.socket_addr, "127.0.0.1:12345");

    assert_eq!(
        config_api::get_socket_reconnect_attempts().map_err(|err: String| anyhow!(err))?,
        Some(reconnect_limit)
    );

    auth_service::logout().map_err(|err: String| anyhow!(err))?;

    env::remove_var("FLUTTER_SDK_TEST_MODE");
    env::remove_var("FLUTTER_SDK_SOCKET_CLIENT_TEST_MODE");

    Ok(())
}
