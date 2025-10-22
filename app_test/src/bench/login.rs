//! 登录模块
//!
//! 提供登录功能，获取Socket地址

use std::time::{SystemTime, UNIX_EPOCH};
use tonic::Request;
use tonic::transport::Channel;

use crate::api::proto::{ApiServiceClient, LoginRequest, LoginResponse};

/// 登录类型
#[derive(Debug, Clone, Copy)]
pub enum LoginType {
    /// 手机号登录
    Phone = 1,
    /// 邮箱登录
    Email = 2,
    /// 用户名登录
    Username = 4,
}

/// 登录结果
pub struct LoginResult {
    /// 是否成功
    pub success: bool,
    /// 会话令牌
    pub session_token: String,
    /// 会话过期时间
    pub expires_at: u64,
    /// Socket地址
    pub socket_addr: String,
}

/// 执行登录并获取Socket地址
pub async fn login_and_get_socket(
    target: &str,
    password: &str,
    login_type: LoginType,
) -> Result<LoginResult, Box<dyn std::error::Error>> {
    // 获取API客户端
    let mut client = get_api_client().await;
    let timestamp_ms = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis();

    // 构建登录请求
    let request = Request::new(LoginRequest {
        login_type: login_type as i32,
        target: target.to_string(),
        password: password.to_string(),
        device_type: 1, // 默认设备类型为Web
        device_id: format!("test_device_{}", timestamp_ms),
    });

    // 发送登录请求
    let response = client.login(request).await?;
    let login_response: LoginResponse = response.into_inner();
    let success = !login_response.token.is_empty();

    // 检查登录是否成功
    if !success {
        return Ok(LoginResult {
            success: false,
            session_token: String::new(),
            expires_at: 0,
            socket_addr: String::new(),
        });
    }

    // 获取Socket地址
    let socket_addr = login_response.socket_addr;

    Ok(LoginResult {
        success: true,
        session_token: login_response.token,
        expires_at: login_response.expires_at,
        socket_addr,
    })
}

/// 获取API客户端连接
async fn get_api_client() -> ApiServiceClient<Channel> {
    crate::api::connect_client().await
}
