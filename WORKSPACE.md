# 工作区规范与整理说明

本仓库为 Rust 工作区（Cargo workspace）。本次重新整理聚焦于统一版本与依赖声明、理顺配置加载路径，避免构建陷阱，并为后续演进打好基础。

## 已完成的整理

- 统一 Rust Edition：所有 crate 使用 `edition = "2021"`，确保与 `stable` 工具链兼容。
- 修复依赖声明：将误写的 `serde .workspace`、`ahash .workspace` 更正为 `serde.workspace`、`ahash.workspace`。
- 统一 Workspace 依赖：尽量改为 `*.workspace = true`，与根 `Cargo.toml [workspace.dependencies]` 保持一致（如 `serde_json`、`once_cell`、`env_logger` 等）。
- 保留特定差异：如 `hot_online_service` 对 `moka` 的特定特性选择未变更，以免影响行为。
- 新增配置加载入口：`AppConfig::init_from_env(default)` 支持通过 `APP_CONFIG` 覆盖配置路径；默认仍兼容根目录下 `config-*.toml`。
- 新增集中配置目录：新增 `configs/`，已放置各服务示例配置副本。

## 约定与建议

- 依赖优先使用 Workspace 版本：若根 `Cargo.toml` 已声明依赖，成员 crate 使用 `foo.workspace = true`，统一版本与特性，减少冲突。
- 命名与路径：crate 目录名遵循现有结构；如需重命名（例如 `arb-service` → `arb_service`）请先确认外部脚本/部署是否依赖当前名称。
- 配置文件：优先通过环境变量 `APP_CONFIG` 指定配置路径。仓库同时保留根目录 `config-*.toml` 与 `configs/` 下的示例，便于过渡。

## 开发与构建

- 格式与检查：`make fmt`、`make clippy`。
- 构建：`make build` 或 `make release`。
- 运行：见 `README.md` 与 `Makefile` 中的 `run-*` 目标。

## 后续可选优化

- 引入 `[workspace.lints]` 统一静态检查策略（需确保 Cargo 版本支持）。
- 将公共二进制/脚本放入 `scripts/`，并在 `Makefile` 中调用。
- 将各服务的默认配置与文档放入 `configs/`、`docs/` 目录并在代码中支持可配置路径。
