//! 批量用户注册模块
//!
//! 提供高效的批量用户注册功能，用于快速创建大量测试账号

use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::sync::Semaphore;
use tokio::time::sleep;
use tonic::Request;

use crate::api::proto::{ApiServiceClient, BuildRegisterCodeRequest, VerifyRegisterCodeRequest};
use tonic::transport::Channel;

/// 注册类型枚举
#[allow(dead_code)]
pub enum RegisterType {
    /// 手机注册
    Phone = 1,
    /// 邮箱注册
    Email = 2,
    /// 用户名注册（无需验证码）
    Username = 3,
}

/// 批量注册配置
pub struct BatchRegisterConfig {
    /// 注册用户数量
    pub count: usize,
    /// 用户名前缀
    pub username_prefix: String,
    /// 密码
    pub password: String,
    /// 注册类型 (1: 手机, 2: 邮箱, 3: 用户名)
    pub reg_type: i32,
    /// 并发数
    pub concurrency: usize,
    /// 每次注册间隔(毫秒)
    pub interval_ms: u64,
}

impl Default for BatchRegisterConfig {
    fn default() -> Self {
        Self {
            count: 100,
            username_prefix: "test_user".to_string(),
            password: "Test123456".to_string(),
            reg_type: RegisterType::Username as i32, // 默认用户名注册
            concurrency: 10,
            interval_ms: 100,
        }
    }
}

/// 批量注册结果
pub struct BatchRegisterResult {
    /// 成功注册数量
    pub success_count: usize,
    /// 失败注册数量
    pub failed_count: usize,
    /// 总耗时(毫秒)
    pub total_time_ms: u64,
    /// 平均注册时间(毫秒)
    pub avg_time_ms: u64,
}

/// 执行批量注册
pub async fn batch_register(config: BatchRegisterConfig) -> BatchRegisterResult {
    let client: ApiServiceClient<Channel> = get_api_client().await;
    let client = Arc::new(client);

    let semaphore = Arc::new(Semaphore::new(config.concurrency));
    let start_time = Instant::now();

    let mut handles = Vec::with_capacity(config.count);
    let mut success_count = 0;
    let mut failed_count = 0;

    println!(
        "开始批量注册 {} 个用户，并发数: {}",
        config.count, config.concurrency
    );

    for i in 0..config.count {
        let permit = semaphore.clone().acquire_owned().await.unwrap();
        let client = client.clone();
        let username = format!("{}_{}", config.username_prefix, i);
        let password = config.password.clone();
        let reg_type = config.reg_type;

        let handle = tokio::spawn(async move {
            let result = register_single_user(client, &username, &password, reg_type).await;
            drop(permit); // 释放信号量
            result
        });

        handles.push(handle);

        if config.interval_ms > 0 {
            sleep(Duration::from_millis(config.interval_ms)).await;
        }
    }

    for handle in handles {
        match handle.await {
            Ok(true) => success_count += 1,
            _ => failed_count += 1,
        }
    }

    let total_time_ms = start_time.elapsed().as_millis() as u64;
    let avg_time_ms = if success_count > 0 {
        total_time_ms / success_count as u64
    } else {
        0
    };

    println!("批量注册完成:");
    println!("  成功: {} 个", success_count);
    println!("  失败: {} 个", failed_count);
    println!("  总耗时: {}ms", total_time_ms);
    println!("  平均耗时: {}ms/用户", avg_time_ms);

    BatchRegisterResult {
        success_count,
        failed_count,
        total_time_ms,
        avg_time_ms,
    }
}

/// 注册单个用户
async fn register_single_user(
    client: Arc<ApiServiceClient<Channel>>,
    username: &str,
    password: &str,
    reg_type: i32,
) -> bool {
    let mut client = client.as_ref().clone();

    // 用户名注册不需要验证码，直接调用build_register_code
    if reg_type == RegisterType::Username as i32 {
        // 用户名注册直接调用build_register_code，服务端会直接创建用户
        let code_request = Request::new(BuildRegisterCodeRequest {
            name: username.to_string(),
            password: password.to_string(),
            reg_type,
            target: username.to_string(),
        });

        match client.build_register_code(code_request).await {
            Ok(response) => {
                let response = response.into_inner();
                if response.uid > 0 {
                    println!("用户名注册成功: {} (uid: {})", username, response.uid);
                    true
                } else {
                    eprintln!("用户名注册失败: {} (无效的uid)", username);
                    false
                }
            }
            Err(e) => {
                eprintln!("用户名注册失败 ({}): {}", username, e);
                false
            }
        }
    } else {
        // 手机号或邮箱注册需要先获取验证码
        // 1. 获取注册验证码
        let code_request = Request::new(BuildRegisterCodeRequest {
            name: username.to_string(),
            password: password.to_string(),
            reg_type,
            target: username.to_string(), // 使用用户名作为手机号/邮箱
        });

        let code_response = match client.build_register_code(code_request).await {
            Ok(response) => response.into_inner(),
            Err(e) => {
                eprintln!("获取注册验证码失败 ({}): {}", username, e);
                return false;
            }
        };

        // 2. 使用验证码完成注册
        let verify_request = Request::new(VerifyRegisterCodeRequest {
            reg_id: code_response.reg_id,
            code: "123456".to_string(), // 假设验证码为123456
        });

        match client.verify_register_code(verify_request).await {
            Ok(response) => {
                let verify_response = response.into_inner();
                if verify_response.ok {
                    println!("用户注册成功: {}", username);
                    true
                } else {
                    eprintln!("验证码验证失败: {}", username);
                    false
                }
            }
            Err(e) => {
                eprintln!("用户注册失败 ({}): {}", username, e);
                false
            }
        }
    }
}

/// 获取API客户端连接
async fn get_api_client() -> ApiServiceClient<Channel> {
    crate::api::connect_client().await
}

/// 批量注册用户并返回结果
pub async fn register_users(
    count: usize,
    username_prefix: &str,
    password: &str,
    reg_type: i32,
    concurrency: usize,
) -> BatchRegisterResult {
    let config = BatchRegisterConfig {
        count,
        username_prefix: username_prefix.to_string(),
        password: password.to_string(),
        reg_type,
        concurrency,
        interval_ms: 50,
    };

    batch_register(config).await
}
