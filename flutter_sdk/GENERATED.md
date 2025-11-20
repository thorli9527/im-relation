# 自动生成代码

- `src/generated/` 目录里的文件由 `flutter_sdk/build.rs` 通过 `prost_build` 生成，不应手动修改。
- 每次更新 `common/proto/*.proto` 后请运行 `cargo build` 或 `flutter_sdk/build.rs`，它会重新生成 `message.rs`/`socket.rs` 并触发 `cargo fmt`。
- 该目录仅用于 SDK 内部（`pub(crate) mod generated`），Flutter 端应该通过 FRB 接口和 `domain::proto_adapter` 访问业务数据。
