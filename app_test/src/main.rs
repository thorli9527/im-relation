//! `app_test` 工程的入口文件。
//!
//! 这个 crate 的主要职责是承载对 `app_api` gRPC 接口的端到端测试。为了让
//! `cargo test` 能够发现测试模块，这里显式地声明子模块。

/// 将 gRPC 客户端及相关测试导入可见范围。
/// 与 `main` 无关，只是为了让 `cargo test` 能够发现模块内部的测试用例。
mod api;

/// 调试入口：当前没有额外逻辑，仅用于在需要时手工执行 `cargo run -p app_test`。
fn main() {
    // 此可执行程序本身没有业务逻辑，仅保留默认入口以便 `cargo run` 调试。
    println!("Hello, world!");
}
