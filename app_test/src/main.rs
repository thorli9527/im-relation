//! `app_test` 工程的入口文件。
//!
//! 这个 crate 的主要职责是承载对 `app_api` gRPC 接口的端到端测试，以及提供批量注册和Socket压测功能。
//! 为了让 `cargo test` 能够发现测试模块，这里显式地声明子模块。

use std::env;

/// 将 gRPC 客户端及相关测试导入可见范围。
/// 与 `main` 无关，只是为了让 `cargo test` 能够发现模块内部的测试用例。
mod api;

/// 压测模块，提供批量注册和Socket压测功能
mod bench;

/// 打印帮助信息
fn print_help() {
    println!("使用方法: cargo run -p app_test -- [命令] [参数]");
    println!();
    println!("可用命令:");
    println!("  register  批量注册用户");
    println!("    参数:");
    println!("      --count=<数量>         注册用户数量 (默认: 100)");
    println!("      --prefix=<前缀>        用户名前缀 (默认: test_user)");
    println!("      --password=<密码>      用户密码 (默认: Test123456)");
    println!("      --type=<类型>          注册类型 (1: 手机, 2: 邮箱, 3: 用户名, 默认: 3)");
    println!("      --concurrency=<并发数> 并发注册数 (默认: 10)");
    println!();
    println!("  socket    Socket连接压测");
    println!("    参数:");
    println!("      --addr=<地址>          服务器地址 (默认: 127.0.0.1:8080)");
    println!("      --conn=<连接数>        连接数量 (默认: 100)");
    println!("      --msg=<消息数>         每连接消息数 (默认: 10)");
    println!("      --concurrency=<并发数> 并发连接数 (默认: 50)");
    println!();
    println!("  websocket WebSocket连接压测");
    println!("    参数: 同socket命令");
    println!();
    println!("  login_socket 登录Socket压测");
    println!("    参数:");
    println!("      --target=<目标>        用户名/手机号/邮箱 (默认: test_user)");
    println!("      --password=<密码>      用户密码 (默认: Test123456)");
    println!("      --type=<类型>          登录类型 (1: 手机, 2: 邮箱, 3: 用户名, 默认: 3)");
    println!("      --conn=<连接数>        连接数量 (默认: 100)");
    println!("      --msg=<消息数>         每连接消息数 (默认: 10)");
    println!("      --concurrency=<并发数> 并发连接数 (默认: 50)");
    println!();
    println!("示例:");
    println!("  cargo run -p app_test -- register --count=1000 --concurrency=20");
    println!("  cargo run -p app_test -- socket --addr=127.0.0.1:8080 --conn=500");
    println!("  cargo run -p app_test -- login_socket --target=test_user_0 --password=Test123456");
}

/// 解析命令行参数
fn parse_args() -> (String, Vec<(String, String)>) {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        return ("help".to_string(), vec![]);
    }

    let command = args[1].clone();
    let mut params = Vec::new();

    for arg in args.iter().skip(2) {
        if arg.starts_with("--") {
            if let Some(pos) = arg.find('=') {
                let key = arg[2..pos].to_string();
                let value = arg[pos + 1..].to_string();
                params.push((key, value));
            }
        }
    }

    (command, params)
}

/// 获取参数值，如果不存在则返回默认值
fn get_param<T: std::str::FromStr>(params: &[(String, String)], name: &str, default: T) -> T {
    for (key, value) in params {
        if key == name {
            return value.parse().unwrap_or(default);
        }
    }
    default
}

/// 调试入口：提供批量注册和Socket压测功能
#[tokio::main]
async fn main() {
    let (command, params) = parse_args();

    match command.as_str() {
        "register" => {
            let count: usize = get_param(&params, "count", 100);
            let prefix: String = get_param(&params, "prefix", "test_user".to_string());
            let password: String = get_param(&params, "password", "Test123456".to_string());
            let reg_type: i32 = get_param(&params, "type", 3); // 默认用户名注册
            let concurrency: usize = get_param(&params, "concurrency", 10);

            println!("执行批量注册:");
            println!("  数量: {}", count);
            println!("  前缀: {}", prefix);
            println!("  注册类型: {}", reg_type);
            println!("  并发数: {}", concurrency);

            let result =
                bench::register_users(count, &prefix, &password, reg_type, concurrency).await;

            println!("注册结果:");
            println!("  成功: {} 个", result.success_count);
            println!("  失败: {} 个", result.failed_count);
            println!("  总耗时: {}ms", result.total_time_ms);
            println!("  平均耗时: {}ms/用户", result.avg_time_ms);
        }
        "socket" => {
            let addr: String = get_param(&params, "addr", "127.0.0.1:8080".to_string());
            let connections: usize = get_param(&params, "conn", 100);
            let messages: usize = get_param(&params, "msg", 10);
            let concurrency: usize = get_param(&params, "concurrency", 50);

            let config = bench::SocketBenchConfig {
                connections,
                server_addr: addr,
                messages_per_conn: messages,
                message: b"PING".to_vec(),
                concurrency,
                ..Default::default()
            };

            bench::run_socket_bench(config).await;
        }
        "websocket" => {
            let addr: String = get_param(&params, "addr", "127.0.0.1:8080".to_string());
            let connections: usize = get_param(&params, "conn", 100);
            let messages: usize = get_param(&params, "msg", 10);
            let concurrency: usize = get_param(&params, "concurrency", 50);

            bench::websocket_bench(&addr, connections, messages, concurrency).await;
        }
        "login_socket" => {
            let target: String = get_param(&params, "target", " ".to_string());
            let password: String = get_param(&params, "password", "Test123456".to_string());
            let login_type_num: i32 = get_param(&params, "type", 4); // 默认使用用户名登录
            let connections: usize = get_param(&params, "conn", 100);
            let messages: usize = get_param(&params, "msg", 10);
            let concurrency: usize = get_param(&params, "concurrency", 50);

            // 转换登录类型
            let login_type = match login_type_num {
                1 => bench::LoginType::Phone,
                2 => bench::LoginType::Email,
                _ => bench::LoginType::Username,
            };

            let config = bench::LoginSocketBenchConfig {
                target,
                password,
                login_type,
                connections,
                messages_per_conn: messages,
                concurrency,
                conn_interval_ms: 20,
                msg_interval_ms: 100,
            };

            match bench::login_socket_bench(config).await {
                Ok(_) => println!("登录Socket压测完成"),
                Err(e) => eprintln!("登录Socket压测失败: {}", e),
            }
        }
        _ => {
            print_help();
        }
    }
}
