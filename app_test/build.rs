/// 构建脚本：负责在 `cargo build` / `cargo test` 时生成 gRPC 客户端代码。
///
/// 这里单独保留一个测试工程（`app_test`），所以无法直接复用 `app_api` 的 build.rs。
/// 因此在每次编译前，我们都需要手动触发 tonic-build，把最新的 proto 生成结果放到
/// `$OUT_DIR` 下供测试模块引用。
// 由于测试需要访问真实的 `app_api`，这里直接复用主工程的 proto 定义。
fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 当 proto 文件或目录发生变化时，触发重新生成。
    println!("cargo:rerun-if-changed=../app_api/proto/auth.proto");
    println!("cargo:rerun-if-changed=../app_api/proto");

    tonic_build::configure()
        .build_client(true)
        .build_server(false)
        .compile_protos(&["../app_api/proto/auth.proto"], &["../app_api/proto"])?;

    Ok(())
}
