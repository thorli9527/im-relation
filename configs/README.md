将本目录作为各服务默认配置示例的集中存放位置。建议运行时通过环境变量指定配置路径：

- 环境变量：`APP_CONFIG=/path/to/your-config.toml`
- 若未设置，程序会回退到各自 crate 内硬编码的默认值（当前仍指向仓库根目录下的 `config-*.toml`），以保持兼容。

示例：

```bash
APP_CONFIG=configs/config-online.toml make run-online
APP_CONFIG=configs/config-group.toml make run-group
APP_CONFIG=configs/config-friend.toml make run-friend
APP_CONFIG=configs/config-api.toml make run-api
APP_CONFIG=configs/config-arb.toml make run-arb
```

