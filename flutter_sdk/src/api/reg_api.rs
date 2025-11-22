use flutter_rust_bridge::frb;

use crate::api::app_api_types::OperationStatus;
use crate::api::reg_api_types::{BuildRegisterCodeRequest, BuildRegisterCodeResponse, VerifyRegisterCodeRequest};
use crate::api::utils::post_request;

#[frb]
/// 拉取注册验证码（邮箱/手机号）。
pub fn build_register_code(payload: BuildRegisterCodeRequest) -> Result<BuildRegisterCodeResponse, String> {
    post_request("/register/code", &payload)
}

#[frb]
/// 校验注册验证码。
pub fn verify_register_code(payload: VerifyRegisterCodeRequest) -> Result<OperationStatus, String> {
    post_request("/register/verify", &payload)
}
