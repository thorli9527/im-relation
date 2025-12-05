# im-relation

基于 Rust 的即时通讯后端（多服务工作区）与 Flutter 桌面端。包含用户/好友/群组/消息等服务、Socket 网关，以及桌面客户端与 FFI SDK。

## 仓库结构
- Rust 工作区（`Cargo.toml`）：`common`(配置/工具/Kafka/Redis)、`user_service`、`friend_service`、`group_service`、`msg_friend`、`msg_group`、`msg_system`、`app_api`(HTTP/gRPC 网关)、`app_socket`(TCP+Kafka 分发)。
- 客户端：`client/app_desktop`(Flutter 桌面应用)，`flutter_sdk`(供 Flutter FFI 的 Rust 库)。
- 配置样例：`config-*.toml`（API、Socket、User/Friend/Group、Msg-Friend/Group/System）。
- 其他：`docker/`(支撑脚本)、`logs/`(默认日志输出)。

## 环境要求
- Rust 工具链：`rust-toolchain.toml` 固定为 1.90.0（含 `clippy`/`rustfmt`）。
- 运行依赖：MySQL、Redis、Kafka；路径在各 `config-*.toml` 中可调。
- Flutter（桌面端）：建议使用与本机一致的 Flutter SDK，并确保 Dart/Flutter 具备 macOS 桌面支持。

## 快速构建
```bash
# 后端（检查/调试构建）
cargo check
cargo build

# 发布构建
cargo build --release
```

## 运行主要服务
各服务默认从当前目录加载对应配置，可通过环境变量 `APP_CONFIG` 覆盖。
```bash
# API 网关（HTTP+gRPC）
RUST_LOG=info APP_CONFIG=./config-api.toml cargo run -p app_api

# Socket 网关（TCP + Kafka 拉取并分发）
RUST_LOG=info APP_CONFIG=./config-socket.toml cargo run -p app_socket

# 领域服务
RUST_LOG=info APP_CONFIG=./config-user.toml cargo run -p user_service
RUST_LOG=info APP_CONFIG=./config-friend.toml cargo run -p friend_service
RUST_LOG=info APP_CONFIG=./config-group.toml cargo run -p group_service

# 消息服务
RUST_LOG=info APP_CONFIG=./config-msg-friend.toml cargo run -p msg_friend
RUST_LOG=info APP_CONFIG=./config-msg-group.toml  cargo run -p msg_group
RUST_LOG=info APP_CONFIG=./config-msg-system.toml cargo run -p msg_system
```
> 首次启动前请确认 MySQL 已建库、Redis/Kafka 可连通，必要时按配置文件修改地址/账号。

## Flutter 桌面端
```bash
cd client/app_desktop
flutter pub get
# 如需先编译 FFI 库：cargo build -p flutter_sdk --release
flutter run -d macos
```
日志默认写入仓库根目录的 `logs/`。

## 代码规范与开发提示
- 格式化：`cargo fmt`；静态检查：`cargo clippy --workspace --all-targets`.
- gRPC/Proto 生成代码已存在于 `common/src/infra/grpc`，修改 proto 后需重新生成。
- Socket 侧实现“收件即 ACK”并接 Kafka，消息去重与游标增量拉取由各消息服务负责；客户端上线/前台后通过会话游标增量拉取。

## 问题排查
- 编译失败多因 Flutter 缓存或权限：在具备写权限的环境下执行 `flutter clean && flutter pub get`。
- 若 Kafka/MySQL/Redis 未就绪，相关服务会在启动时报错；可检查 `config-*.toml` 的地址与凭证。
