# 项目总览

本仓库是一个 Rust 工作区（Cargo workspace），包含多项服务（online、group、friend 等），并在 `group` 相关模块中集成了 `HashShardMap / MemberListWrapper / SimpleMemberList / ShardedMemberList` 等结构。

主要技术栈：Actix-Web、Tokio、SQLx、Tonic(gRPC)、Kafka、Redis 等。

## 工作区成员

以下为 `Cargo.toml` 中声明的成员（部分为二进制服务，部分为公共库）：

- `common`：公共工具与抽象（配置、Kafka、Redis、工具函数等）
- `hot_online_service`：在线状态服务（gRPC/REST）
- `hot_group_service`：群组服务（使用分片与成员列表封装）
- `hot_friend_service`：好友服务
- `arb-service`：仲裁/桥接服务
- `app_api`：对外 API 服务
- `app_socket`：Socket 客户端/服务相关
- `msg_gateway`：消息网关（如有）
- `msg_friend`：好友消息模块
- `app_main`：聚合/入口应用

## 快速开始

已添加 `Makefile` 与 `rust-toolchain.toml`，推荐通过 `make` 快速操作：

```bash
# 构建（debug 模式）
make build

# 构建（release 模式）
make release

# 代码格式化 & 静态检查
make fmt
make clippy
```

## 运行各服务

可直接使用 `make`，也可 `cargo run -p <crate>`：

```bash
# Online（默认端口 8081，若代码中有配置请以实际为准）
APP_CONFIG=configs/config-online.toml make run-online

# Group（默认分片数，可通过环境变量覆盖）
APP_CONFIG=configs/config-group.toml GROUP_SHARDS=64 make run-group

# Friend（依赖 Online 服务地址）
APP_CONFIG=configs/config-friend.toml ONLINE_BASE_URL=http://127.0.0.1:8081 make run-friend

# 其他服务
APP_CONFIG=configs/config-api.toml make run-api
APP_CONFIG=configs/config-arb.toml make run-arb
make run-socket
make run-main
```

## 配置文件

根目录下提供了多份示例配置：

- `config-api.toml`
- `config-group.toml`
- `config-online.toml`
- `config-friend.toml`
- `config-arb.toml`

如需要，请在运行前根据实际环境拷贝/调整对应配置。

## 代码规范

- 格式化：`make fmt`（使用 `rustfmt`）
- 静态检查：`make clippy`（开启 `-D warnings`）

## 忽略文件

已完善 `.gitignore`：

- 忽略 `target/`、系统/编辑器文件（`.DS_Store`、`.idea/`、`.vscode/`）、本地 `.env`、`*.log` 等

如果仓库中曾经提交过上述文件，请自行执行 `git rm --cached` 清理历史追踪。
