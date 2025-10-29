//! gRPC 端到端测试辅助模块。
//!
//! 这里直接复用 `app_api` 中通过 `tonic-build` 生成的 proto 定义，并且与真实运行的
//! gRPC 服务对接，而不是在内存内模拟服务端行为。这样能够校验服务端的输入验证逻辑、
//! 配置以及外部依赖是否按预期工作。

use std::time::Duration;

use tonic::transport::{Channel, Endpoint};

pub mod proto {
    //! 按照包名 `api` 将 `auth.proto` 生成的客户端代码引入当前模块命名空间。
    //! `tonic::include_proto!` 会在编译期将 `OUT_DIR` 下对应文件包含进来。
    tonic::include_proto!("api");

    // 将 gRPC 客户端重导出到 `proto` 根部，方便测试代码直接引用。
    pub use self::api_service_client::ApiServiceClient;
}

use proto::ApiServiceClient;

#[cfg(test)]
use proto::BuildRegisterCodeRequest;

/// 建立到 `app_api` gRPC 服务的客户端连接。
///
/// - 优先读取环境变量 `API_GRPC_ADDR`，便于在不同环境之间切换。
/// - 若未设置环境变量，默认连接开发环境常用的 `127.0.0.1:50051`。
/// - 引入 `connect_timeout` 和 `tcp_nodelay`，提高连接失败的反馈速度。
pub async fn connect_client() -> ApiServiceClient<Channel> {
    let addr = std::env::var("API_GRPC_ADDR").unwrap_or_else(|_| {
        // 默认指向本地开发环境，可通过环境变量覆盖。
        "http://127.0.0.1:50051".into()
    });
    let endpoint = Endpoint::from_shared(addr)
        .expect("invalid gRPC endpoint")
        .connect_timeout(Duration::from_secs(3))
        .tcp_nodelay(true);

    let channel = endpoint
        .connect()
        .await
        .expect("failed to connect gRPC endpoint");

    ApiServiceClient::new(channel)
}

#[cfg(test)]
mod tests {
    use super::*;
    use app_api::service::user_service::UserRegType;
    use crate::bench::register::{batch_register, BatchRegisterConfig, RegisterType};
    use std::sync::atomic::{AtomicU64, Ordering};
    use std::time::{SystemTime, UNIX_EPOCH};
    use tonic::{Code, Request};

    static UNIQUE_COUNTER: AtomicU64 = AtomicU64::new(0);
    const TEST_PASSWORD: &str = "Test123456";

    /// 构建 gRPC 客户端。
    ///
    /// 每个测试都独立建立连接，避免复用同一 channel 导致潜在状态污染。
    async fn client() -> ApiServiceClient<Channel> {
        connect_client().await
    }

    /// 为测试生成一个带时间戳的唯一用户名，避免与现有数据冲突。
    fn unique_username(prefix: &str) -> String {
        let micros = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time should be after UNIX_EPOCH")
            .as_micros();
        let seq = UNIQUE_COUNTER.fetch_add(1, Ordering::Relaxed);
        format!("{prefix}_{micros}_{seq}")
    }

    /// 快速创建一个用户名注册请求并返回服务端生成的 uid。
    async fn register_login_name(username: &str) -> Result<i64, tonic::Status> {
        let mut client = client().await;
        let request = BuildRegisterCodeRequest {
            name: username.to_string(),
            password: TEST_PASSWORD.to_string(),
            reg_type: UserRegType::LoginName as i32,
            // 登录名注册并不依赖 target 字段，但保持与 DTO 一致以减少分支。
            target: username.to_string(),
        };
        let response = client.build_register_code(Request::new(request)).await?;
        Ok(response.into_inner().uid)
    }

    /// 当传入未知的注册类型（reg_type）时，服务端应返回参数错误。
    #[tokio::test]
    async fn build_register_code_rejects_invalid_reg_type() {
        let mut client = client().await;
        // 构造一个包含非法 reg_type 的请求体。
        let request = BuildRegisterCodeRequest {
            name: "user_1234".into(),
            password: "abc12345".into(),
            // 0 并不是 proto 中定义的合法注册类型，期望服务端能阻断请求。
            reg_type: 0,
            target: "user_1234".into(),
        };

        // 调用真实接口，并断言返回 `Status::InvalidArgument`。
        let status = client
            .build_register_code(Request::new(request))
            .await
            .expect_err("expected invalid reg_type to be rejected");

        assert_eq!(
            status.code(),
            Code::InvalidArgument,
            "服务端应当拒绝未知注册类型"
        );
        assert!(
            status.message().contains("unsupported reg_type"),
            "unexpected status: {}",
            status.message()
        );
    }

    /// 登录名注册应直接返回一个合法的 uid。
    #[tokio::test]
    async fn build_register_code_login_name_returns_uid() {
        let username = unique_username("login_user");
        let uid = register_login_name(&username)
            .await
            .expect("login-name registration should succeed");

        assert!(
            uid > 0,
            "服务端应返回新用户 uid，实际为 {}",
            uid
        );
    }

    /// 批量注册多个登录名账号时，应全部成功且无失败项。
    #[tokio::test]
    async fn batch_register_login_name_accounts() {
        let count = 5;
        let prefix = unique_username("batch_user");
        let result = batch_register(BatchRegisterConfig {
            count,
            username_prefix: prefix,
            password: TEST_PASSWORD.to_string(),
            reg_type: RegisterType::Username as i32,
            concurrency: 3,
            interval_ms: 0,
        })
        .await;

        assert_eq!(result.failed_count, 0, "批量注册不应出现失败");
        assert_eq!(
            result.success_count, count,
            "成功注册数量应与期望一致"
        );
    }
}
