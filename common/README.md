# Common Crate Layout

`common` 为各服务共享的基础 crate，按照“领域核心 / 基础设施 / 支撑工具”三个层次组织代码，方便快速定位与复用。

## 目录结构

- `src/core`：领域模型与跨服务通用逻辑  
  - `errors`：HTTP / 业务错误类型以及 `AppError`、`RelationError` 等映射。  
  - `messaging`：领域消息模型（`DomainMessage`、`MsgCategory`）及 Kafka/Socket 之间的转换。  
  - `result`：统一的 API 返回结构与便捷函数。

- `src/infra`：基础设施封装  
  - `grpc`：由 `build.rs` 生成的 protobuf/tonic 代码以及 `GrpcClientManager` 等客户端工具。  
  - `kafka`：Kafka 生产者、消费者模板与 Topic 定义。  
  - `redis`：连接池工具、基础数据结构操作实现。

- `src/support`：通用支撑工具  
  - `node`：节点枚举、发现与缓存逻辑。  
  - `util`：日期、校验、别名池等零散辅助工具。

- `src/config`：应用配置加载与结构体定义。
- `proto`：protobuf 源文件，仅在构建阶段使用。

## 生成代码

`build.rs` 会将 protobuf 定义生成到 `src/infra/grpc` 目录下：

```bash
cargo check -p common
```

触发上述命令即可重新生成 message / socket / gRPC 模块。生成代码不再保留旧的 `src/grpc/*` 目录；请确保不要引用已废弃的路径。

## 引用规范

- 领域与 API 结果：`use common::core::{errors::AppError, messaging::DomainMessage}`  
- 基础设施封装：`use common::infra::{grpc::grpc_user, kafka::start_consumer, redis::redis_pool::RedisPoolTools}`  
- 工具与节点：`use common::support::{node::NodeType, util::date_util}`

如仍存在 `common::grpc::*`、`common::message_bus::*` 等旧引用，请尽快更新至上述路径。

