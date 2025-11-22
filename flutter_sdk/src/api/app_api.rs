use flutter_rust_bridge::frb;
use crate::api::config_api;
use crate::api::utils;
use crate::{common::db, domain, service};
pub use crate::api::{login_api::*, reg_api::*, user_api::*};
pub use crate::api::app_api_types::*;
pub use crate::api::reg_api_types::{
    BuildRegisterCodeRequest,
    BuildRegisterCodeResponse,
    VerifyRegisterCodeRequest,
};
pub use crate::api::login_api_types::*;
pub use crate::api::login_api_types::*;

#[frb(init)]
/// 初始化应用：启动数据库、领域服务，并准备必要的配置（设备 ID、接口地址、重连限制）。
pub fn init_app() -> Result<(), String> {
    crate::common::init_logging();
    db::init().map_err(|err| err.to_string())?;
    domain::init();
    service::init();
    config_api::get_device_id()?;
    config_api::ensure_app_api_base_url_initialized()?;
    let limit = config_api::ensure_socket_reconnect_limit()?;
    let _ = config_api::ensure_attempts(limit)?;
    Ok(())
}
