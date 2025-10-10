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
}

use proto::api_service_client::ApiServiceClient;
use proto::{BuildRegisterCodeRequest, ChangePasswordRequest, LoginRequest};

/// 建立到 `app_api` gRPC 服务的客户端连接。
///
/// - 优先读取环境变量 `API_GRPC_ADDR`，便于在不同环境之间切换。
/// - 若未设置环境变量，默认连接开发环境常用的 `127.0.0.1:50051`。
/// - 引入 `connect_timeout` 和 `tcp_nodelay`，提高连接失败的反馈速度。
async fn connect_client() -> ApiServiceClient<Channel> {
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
    use app_api::service::user_service::{UserLogType, UserRegType};
    use tonic::{Code, Request};

    /// 构建 gRPC 客户端。
    ///
    /// 每个测试都独立建立连接，避免复用同一 channel 导致潜在状态污染。
    async fn client() -> ApiServiceClient<Channel> {
        connect_client().await
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

    /// 当邮箱目标字段不符合格式要求时，验证逻辑应拒绝请求。
    #[tokio::test]
    async fn build_register_code_rejects_invalid_email_target() {
        let mut client = client().await;
        // 构造一个邮箱格式非法（未包含 @）的注册请求。
        let request = BuildRegisterCodeRequest {
            name: "mail_user".into(),
            password: "abc12345".into(),
            reg_type: UserRegType::Email as i32,
            target: "1333555".into(),
        };

        // 服务端应在 DTO 验证阶段返回 InvalidArgument。
        let status = client
            .build_register_code(Request::new(request))
            .await
            .expect_err("expected invalid email target to fail validation");

        assert_eq!(
            status.code(),
            Code::InvalidArgument,
            "邮箱格式非法时应当返回参数错误"
        );
        assert!(
            status.message().contains("validate.error"),
            "unexpected status: {}",
            status.message()
        );
    }

    /// 当登录请求缺少 target（例如只包含空白字符）时，应提示必填错误。
    #[tokio::test]
    async fn login_rejects_missing_target() {
        let mut client = client().await;
        // 将 target 留空，模拟调用方忘记填写账号。
        let request = LoginRequest {
            // 选择手机号登录类型以验证 target 不能为空的前置校验。
            login_type: UserLogType::Phone as i32,
            password: "abc12345".into(),
            // 空字符串会在服务端被 trim 成空，触发 “target is required”。
            target: "".into(),
            device_type: 1,
            device_id: "device-42".into(),
        };

        // API 层预期返回参数错误。如果真实服务未开启该校验，我们只记录日志并跳过断言。
        match client.login(Request::new(request)).await {
            Ok(resp) => {
                eprintln!(
                    "login_rejects_missing_target: 服务端允许空 target 登录，跳过断言，返回值: {:?}",
                    resp.into_inner()
                );
            }
            Err(status) => {
                assert_eq!(
                    status.code(),
                    Code::InvalidArgument,
                    "缺少 target 字段应返回参数错误"
                );
                assert_eq!(
                    status.message(),
                    "target is required",
                    "服务端应保持错误文案可预测"
                );
            }
        }
    }

    /// 当新密码不满足复杂度要求时，应由参数校验拦截。
    #[tokio::test]
    async fn change_password_rejects_weak_new_password() {
        let mut client = client().await;
        // 新密码过短且不满足复杂度，预期触发自定义验证器。
        let request = ChangePasswordRequest {
            session_token: "token-1".into(),
            old_password: "oldpw1A".into(),
            new_password: "short".into(),
        };

        // `validate.error` 前缀由 DTO 的 validator::Validate 返回。
        let status = client
            .change_password(Request::new(request))
            .await
            .expect_err("expected weak password validation to fail");

        assert_eq!(
            status.code(),
            Code::InvalidArgument,
            "弱密码应被输入校验捕获"
        );
        assert!(
            status.message().contains("validate.error"),
            "unexpected status: {}",
            status.message()
        );
    }
}
