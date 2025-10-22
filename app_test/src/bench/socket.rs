//! Socket压测模块
//!
//! 提供Socket连接压测功能，模拟大量客户端同时连接并发送消息

use std::sync::{
    Arc,
    atomic::{AtomicUsize, Ordering},
};
use std::time::{Duration, Instant};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;
use tokio::sync::Semaphore;
use tokio::time::sleep;

/// Socket压测配置
pub struct SocketBenchConfig {
    /// 连接数量
    pub connections: usize,
    /// 服务器地址
    pub server_addr: String,
    /// 每个连接发送的消息数
    pub messages_per_conn: usize,
    /// 消息内容
    pub message: Vec<u8>,
    /// 并发连接数
    pub concurrency: usize,
    /// 连接间隔(毫秒)
    pub conn_interval_ms: u64,
    /// 消息发送间隔(毫秒)
    pub msg_interval_ms: u64,
    /// 是否等待响应
    pub wait_response: bool,
}

impl Default for SocketBenchConfig {
    fn default() -> Self {
        Self {
            connections: 100,
            server_addr: "127.0.0.1:8080".to_string(),
            messages_per_conn: 10,
            message: b"PING".to_vec(),
            concurrency: 50,
            conn_interval_ms: 20,
            msg_interval_ms: 100,
            wait_response: true,
        }
    }
}

/// Socket压测结果
pub struct SocketBenchResult {
    /// 成功连接数
    pub connected: usize,
    /// 连接失败数
    pub conn_failed: usize,
    /// 发送成功消息数
    pub messages_sent: usize,
    /// 发送失败消息数
    pub messages_failed: usize,
    /// 收到响应数
    pub responses_received: usize,
    /// 总耗时(毫秒)
    pub total_time_ms: u64,
    /// 平均连接时间(毫秒)
    pub avg_conn_time_ms: u64,
    /// 平均消息时间(毫秒)
    pub avg_msg_time_ms: u64,
    /// 每秒连接数
    pub connections_per_sec: f64,
    /// 每秒消息数
    pub messages_per_sec: f64,
}

/// 执行Socket压测
pub async fn run_socket_bench(config: SocketBenchConfig) -> SocketBenchResult {
    let start_time = Instant::now();
    let semaphore = Arc::new(Semaphore::new(config.concurrency));

    let connected = Arc::new(AtomicUsize::new(0));
    let conn_failed = Arc::new(AtomicUsize::new(0));
    let messages_sent = Arc::new(AtomicUsize::new(0));
    let messages_failed = Arc::new(AtomicUsize::new(0));
    let responses_received = Arc::new(AtomicUsize::new(0));

    let mut handles = Vec::with_capacity(config.connections);

    println!("开始Socket压测:");
    println!("  目标服务器: {}", config.server_addr);
    println!("  连接数: {}", config.connections);
    println!("  每连接消息数: {}", config.messages_per_conn);
    println!("  并发数: {}", config.concurrency);

    for i in 0..config.connections {
        let permit = semaphore.clone().acquire_owned().await.unwrap();

        let server_addr = config.server_addr.clone();
        let message = config.message.clone();
        let messages_per_conn = config.messages_per_conn;
        let msg_interval_ms = config.msg_interval_ms;
        let wait_response = config.wait_response;

        let connected = connected.clone();
        let conn_failed = conn_failed.clone();
        let messages_sent = messages_sent.clone();
        let messages_failed = messages_failed.clone();
        let responses_received = responses_received.clone();

        let handle = tokio::spawn(async move {
            match TcpStream::connect(&server_addr).await {
                Ok(mut stream) => {
                    connected.fetch_add(1, Ordering::SeqCst);

                    for _ in 0..messages_per_conn {
                        match stream.write_all(&message).await {
                            Ok(_) => {
                                messages_sent.fetch_add(1, Ordering::SeqCst);

                                if wait_response {
                                    let mut buf = [0u8; 1024];
                                    match stream.read(&mut buf).await {
                                        Ok(n) if n > 0 => {
                                            responses_received.fetch_add(1, Ordering::SeqCst);
                                        }
                                        _ => {}
                                    }
                                }
                            }
                            Err(_) => {
                                messages_failed.fetch_add(1, Ordering::SeqCst);
                            }
                        }

                        if msg_interval_ms > 0 {
                            sleep(Duration::from_millis(msg_interval_ms)).await;
                        }
                    }
                }
                Err(_) => {
                    conn_failed.fetch_add(1, Ordering::SeqCst);
                }
            }

            drop(permit);
        });

        handles.push(handle);

        if config.conn_interval_ms > 0 && i < config.connections - 1 {
            sleep(Duration::from_millis(config.conn_interval_ms)).await;
        }
    }

    for handle in handles {
        let _ = handle.await;
    }

    let total_time_ms = start_time.elapsed().as_millis() as u64;

    let connected_count = connected.load(Ordering::SeqCst);
    let messages_sent_count = messages_sent.load(Ordering::SeqCst);

    let avg_conn_time_ms = if connected_count > 0 {
        total_time_ms / connected_count as u64
    } else {
        0
    };

    let avg_msg_time_ms = if messages_sent_count > 0 {
        total_time_ms / messages_sent_count as u64
    } else {
        0
    };

    let connections_per_sec = if total_time_ms > 0 {
        (connected_count as f64 * 1000.0) / total_time_ms as f64
    } else {
        0.0
    };

    let messages_per_sec = if total_time_ms > 0 {
        (messages_sent_count as f64 * 1000.0) / total_time_ms as f64
    } else {
        0.0
    };

    let result = SocketBenchResult {
        connected: connected_count,
        conn_failed: conn_failed.load(Ordering::SeqCst),
        messages_sent: messages_sent_count,
        messages_failed: messages_failed.load(Ordering::SeqCst),
        responses_received: responses_received.load(Ordering::SeqCst),
        total_time_ms,
        avg_conn_time_ms,
        avg_msg_time_ms,
        connections_per_sec,
        messages_per_sec,
    };

    println!("Socket压测完成:");
    println!("  成功连接: {} 个", result.connected);
    println!("  连接失败: {} 个", result.conn_failed);
    println!("  发送消息: {} 条", result.messages_sent);
    println!("  发送失败: {} 条", result.messages_failed);
    println!("  接收响应: {} 条", result.responses_received);
    println!("  总耗时: {}ms", result.total_time_ms);
    println!("  平均连接耗时: {}ms", result.avg_conn_time_ms);
    println!("  平均消息耗时: {}ms", result.avg_msg_time_ms);
    println!("  每秒连接数: {:.2} conn/s", result.connections_per_sec);
    println!("  每秒消息数: {:.2} msg/s", result.messages_per_sec);

    result
}

/// 使用WebSocket协议进行压测
pub async fn websocket_bench(
    server_addr: &str,
    connections: usize,
    messages_per_conn: usize,
    concurrency: usize,
) -> SocketBenchResult {
    // 构造一个简单的WebSocket握手消息
    let _handshake_msg = concat!(
        "GET / HTTP/1.1\r\n",
        "Host: localhost\r\n",
        "Upgrade: websocket\r\n",
        "Connection: Upgrade\r\n",
        "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n",
        "Sec-WebSocket-Version: 13\r\n\r\n"
    )
    .as_bytes()
    .to_vec();

    // 构造一个简单的WebSocket文本帧
    let mut text_frame = vec![0x81, 0x04]; // 文本帧头部
    text_frame.extend_from_slice(b"PING");

    let config = SocketBenchConfig {
        connections,
        server_addr: server_addr.to_string(),
        messages_per_conn,
        message: text_frame,
        concurrency,
        conn_interval_ms: 20,
        msg_interval_ms: 100,
        wait_response: true,
    };

    run_socket_bench(config).await
}
