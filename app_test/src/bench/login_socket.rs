//! 登录后Socket压测模块
//!
//! 提供登录获取Socket地址后进行Socket压测的功能

use std::time::Instant;

use crate::bench::login::{LoginType, login_and_get_socket};
use crate::bench::socket::{SocketBenchConfig, SocketBenchResult, run_socket_bench};

/// 登录Socket压测配置
pub struct LoginSocketBenchConfig {
    /// 用户名/手机号/邮箱
    pub target: String,
    /// 密码
    pub password: String,
    /// 登录类型
    pub login_type: LoginType,
    /// 连接数量
    pub connections: usize,
    /// 每个连接发送的消息数
    pub messages_per_conn: usize,
    /// 并发连接数
    pub concurrency: usize,
    /// 连接间隔(毫秒)
    pub conn_interval_ms: u64,
    /// 消息发送间隔(毫秒)
    pub msg_interval_ms: u64,
}

impl Default for LoginSocketBenchConfig {
    fn default() -> Self {
        Self {
            target: "test_user".to_string(),
            password: "password123".to_string(),
            login_type: LoginType::Username,
            connections: 100,
            messages_per_conn: 10,
            concurrency: 50,
            conn_interval_ms: 20,
            msg_interval_ms: 100,
        }
    }
}

/// 执行登录后Socket压测
pub async fn login_socket_bench(
    config: LoginSocketBenchConfig,
) -> Result<SocketBenchResult, String> {
    println!("开始登录获取Socket地址...");
    let start_time = Instant::now();

    // 执行登录获取Socket地址
    let login_result =
        match login_and_get_socket(&config.target, &config.password, config.login_type).await {
            Ok(result) => result,
            Err(e) => return Err(format!("登录失败: {}", e)),
        };

    if !login_result.success {
        return Err("登录失败: 用户名或密码错误".to_string());
    }

    let login_time = start_time.elapsed().as_millis();
    println!("登录成功! 耗时: {}ms", login_time);
    println!("会话令牌: {}", login_result.session_token);
    println!("Token过期时间: {}", login_result.expires_at);
    println!("Socket地址: {}", login_result.socket_addr);

    // 构建Socket压测配置
    let socket_config = SocketBenchConfig {
        connections: config.connections,
        server_addr: login_result.socket_addr,
        messages_per_conn: config.messages_per_conn,
        message: b"PING".to_vec(),
        concurrency: config.concurrency,
        conn_interval_ms: config.conn_interval_ms,
        msg_interval_ms: config.msg_interval_ms,
        wait_response: true,
    };

    // 执行Socket压测
    println!("开始Socket压测...");
    let result = run_socket_bench(socket_config).await;

    Ok(result)
}
