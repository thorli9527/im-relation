use crate::errors::AppError;
use crate::redis::redis_pool::RedisPoolTools;
use anyhow::anyhow;
use config::Config;
use log::LevelFilter;
use once_cell::sync::OnceCell;
use serde::Deserialize;
use sqlx::mysql::MySqlPoolOptions;
use sqlx::{MySql, Pool};
use std::str::FromStr;
use std::sync::Arc;
use std::time::Duration;

pub type MySqlPool = Pool<MySql>;

#[derive(Debug, Deserialize, Clone, Default)]
pub struct AppConfig {
    pub database: Option<DatabaseConfig>,
    pub server: Option<ServerConfig>,
    pub sys: Option<SysConfig>,
    #[serde(alias = "grpc")]
    pub arb: Option<ArbConfig>,
    pub redis: Option<RedisConfig>,
    pub socket: Option<SocketConfig>,
    pub hot_group: Option<HotGroupConfig>,
    pub hot_friend: Option<HotFriendConfig>,
    pub hot_online: Option<HotOnlineConfig>,
    pub msg_friend: Option<MsgFriendConfig>,
    pub kafka: Option<KafkaConfig>,
}
#[derive(Debug, Deserialize, Clone, Default)]
pub struct ShardConfig {
    pub client_addr: Option<String>,
    pub server_addr: Option<String>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct HotOnlineConfig {
    pub shards: Option<usize>,
    pub default_cc: Option<String>,
    pub hot_by_id_cap: Option<u64>,
    pub hot_by_id_ttl: Option<u64>,
    pub hot_route_cap: Option<u64>,
    pub hot_route_ttl: Option<u64>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct HotGroupConfig {
    pub hot_bytes_per_member: Option<usize>,
    pub hot_bytes_per_group: Option<usize>,
    pub hot_avg_members: Option<usize>,
    pub hot_mem_util: Option<f64>,
    pub hot_cap_max: Option<u64>,
    pub hot_cap_min: Option<u64>,
    pub hot_tti_secs: Option<u64>,
    pub shard_count: Option<usize>,
    pub per_group_shard: Option<usize>,
    pub page_cache_cap: Option<u32>,
    pub page_cache_tti_secs: Option<u64>,
    pub persist_debounce_ms: Option<u64>,
    pub profile_l1_cap: Option<u64>,
    pub profile_l1_tti_secs: Option<u64>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct HotFriendConfig {
    pub avg_value_bytes: Option<usize>,
    pub shards: Option<usize>,
    pub reserve_ratio: Option<f64>,
    pub max_use_ratio: Option<f64>,
    pub overhead_factor: Option<f64>,
    pub hot_ratio: Option<f64>,
    pub tti_secs: Option<u64>,
    pub refresh_secs: Option<u64>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct MsgFriendConfig {
    pub shard_total: Option<u32>,
    pub shard_index: Option<u32>,
}
async fn init_db(url: &str) {
    let pool = MySqlPoolOptions::new()
        .max_connections(64)
        .min_connections(8)
        .acquire_timeout(Duration::from_secs(5))
        .connect(url)
        .await
        .expect("Failed to connect to MySQL");
    DB_INSTANCE
        .set(Arc::new(pool))
        .expect("Failed to init DB_INSTANCE"); // <— 处理重复初始化
}

static DB_INSTANCE: OnceCell<Arc<MySqlPool>> = OnceCell::new();
pub fn get_db() -> Arc<MySqlPool> {
    DB_INSTANCE.get().unwrap().clone()
}
impl AppConfig {
    pub fn new(file: &String) -> Self {
        let config = Config::builder()
            .add_source(config::File::with_name(file).required(true))
            .add_source(config::Environment::with_prefix("APP").separator("_"))
            .build()
            .expect("Failed to build configuration");
        let cfg = config
            .try_deserialize::<AppConfig>()
            .expect("Failed to deserialize configuration");
        return cfg;
    }
    /// 使用传入的默认配置文件路径初始化配置。
    pub async fn init_from_env(default_file: &str) -> Self {
        Self::init(default_file).await
    }
    pub async fn init(file: &str) -> Self {
        let instance = Self::new(&file.to_string());
        if instance.redis.is_some() {
            let redis_config = instance.clone().redis.unwrap();
            RedisPoolTools::init(&redis_config.url).expect("init redis error");
        }

        if instance.database.is_some() {
            let database_config = instance.clone().database.unwrap();
            init_db(&database_config.url.clone()).await;
        }

        if instance.sys.is_some() {
            let log_lovel = instance.clone().sys.unwrap().log_leve;
            if log_lovel.is_some() {
                init_log(&log_lovel.clone().unwrap()).expect("init log error");
            }
        }
        INSTANCE
            .set(Arc::new(instance.clone()))
            .expect("INSTANCE already initialized");
        return instance;
    }

    pub fn get_database(&self) -> DatabaseConfig {
        self.database.clone().unwrap_or_default()
    }
    pub fn get_server(&self) -> ServerConfig {
        self.server.clone().unwrap_or_default()
    }
    pub fn get_sys(&self) -> SysConfig {
        self.sys.clone().unwrap_or_default()
    }
    pub fn get_socket(&self) -> SocketConfig {
        self.socket.clone().unwrap_or_default()
    }

    pub fn hot_online_cfg(&self) -> HotOnlineConfig {
        self.hot_online.clone().unwrap_or_default()
    }

    pub fn hot_group_cfg(&self) -> HotGroupConfig {
        self.hot_group.clone().unwrap_or_default()
    }

    pub fn hot_friend_cfg(&self) -> HotFriendConfig {
        self.hot_friend.clone().unwrap_or_default()
    }

    pub fn msg_friend_cfg(&self) -> MsgFriendConfig {
        self.msg_friend.clone().unwrap_or_default()
    }

    pub fn kafka_cfg(&self) -> KafkaConfig {
        self.kafka.clone().unwrap_or_default()
    }

    pub fn get_arb(&self) -> ArbConfig {
        self.arb.clone().unwrap_or_default()
    }

    pub fn arb(&self) -> Option<&ArbConfig> {
        self.arb.as_ref()
    }

    pub fn arb_server_addr(&self) -> Option<String> {
        self.arb
            .as_ref()
            .and_then(|cfg| {
                cfg.server_addr
                    .clone()
                    .or_else(|| cfg.host.clone())
                    .or_else(|| cfg.url.as_ref().and_then(|u| u.host.clone()))
            })
            .or_else(|| self.server.as_ref()?.http_addr())
    }
    /// 获取单例
    pub fn get() -> Arc<Self> {
        INSTANCE.get().expect("INSTANCE is not initialized").clone()
    }
    //强制下线
}

pub fn init_log(log_lovel: &str) -> Result<(), AppError> {
    let mut builder = env_logger::Builder::new();
    builder.target(env_logger::Target::Stdout);
    let filter = builder.filter(None, LevelFilter::from_str(log_lovel).unwrap());
    filter.init();
    Ok(())
}

/// Fetches the optional arbitration access token configured for arbitration-aware gateways.
pub fn grpc_access_token() -> Option<String> {
    AppConfig::get()
        .arb()
        .and_then(|cfg| cfg.access_token.clone())
}
static INSTANCE: OnceCell<Arc<AppConfig>> = OnceCell::new();

#[derive(Debug, Deserialize, Clone, Default)]
pub struct DatabaseConfig {
    pub url: String,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct SysConfig {
    //全局日志级别
    pub log_leve: Option<String>,
    //默认文件路径
    pub upload_path: Option<String>,
    //md5混淆 key
    pub md5_key: Option<String>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct EndpointConfig {
    pub host: Option<String>,
    pub port: Option<u16>,
    pub addr: Option<String>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct ServerConfig {
    #[serde(default)]
    pub host: Option<String>,
    #[serde(default)]
    pub port: Option<u16>,
    #[serde(default)]
    pub grpc: Option<EndpointConfig>,
    #[serde(default)]
    pub http: Option<EndpointConfig>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct ArbConfig {
    pub server_addr: Option<String>,
    pub access_token: Option<String>,
    #[serde(default)]
    pub host: Option<String>,
    #[serde(default)]
    pub url: Option<ArbUrlConfig>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct RedisConfig {
    pub url: String,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct KafkaConfig {
    pub broker: Option<String>,
    pub group_id: Option<String>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct ArbUrlConfig {
    pub host: Option<String>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct SocketConfig {
    /// Socket TCP 监听地址（优先级最高）。
    pub addr: Option<String>,
    /// Socket TCP 监听 Host（与 `port` 一起使用）。
    pub host: Option<String>,
    /// Socket TCP 监听端口。
    pub port: Option<u16>,
    /// Socket 对外暴露的 Host。
    pub pub_host: Option<String>,
    /// Socket 对外暴露的端口（0 表示由外部代理决定）。
    pub pub_port: Option<u16>,
    /// ACK 分片数量（缺省为 CPU 核数）
    pub ack_shards: Option<usize>,
    /// ACK 重试间隔（毫秒，缺省 500ms）
    pub ack_retry_ms: Option<u64>,
    /// 分片调度器分片数（缺省为 CPU 核数）
    pub dispatch_shards: Option<usize>,
    /// 分片队列容量（缺省 10000）
    pub dispatch_cap: Option<usize>,
    /// HTTP 服务监听 Host（仲裁同步/健康检查用），缺省继承 server.host。
    pub http_host: Option<String>,
    /// HTTP 服务监听端口，缺省为 server.port + 100。
    pub http_port: Option<u16>,
}

impl SocketConfig {
    /// 解析 Socket TCP 监听地址；必须显式配置 addr 或 host+port。
    pub fn tcp_addr(&self) -> anyhow::Result<String> {
        if let Some(addr) = &self.addr {
            return Ok(addr.clone());
        }
        if let (Some(host), Some(port)) = (self.host.as_ref(), self.port) {
            return Ok(format!("{}:{}", host, port));
        }
        Err(anyhow!("socket.addr 或 socket.host/socket.port 未配置"))
    }

    /// 计算 Socket 对外暴露地址。
    pub fn pub_addr(&self) -> Option<String> {
        let host = self
            .pub_host
            .as_ref()
            .map(|h| h.trim())
            .filter(|h| !h.is_empty())?;
        let port = self.pub_port.unwrap_or(0);
        Some(format!("{}:{}", host, port))
    }
}

impl EndpointConfig {
    fn resolve_with_defaults(
        &self,
        default_host: Option<&String>,
        default_port: Option<&u16>,
    ) -> Option<String> {
        if let Some(addr) = &self.addr {
            return Some(addr.clone());
        }
        let host = self.host.as_ref().or(default_host)?;
        let port = self.port.or(default_port.copied())?;
        Some(format!("{}:{}", host, port))
    }
}

impl ServerConfig {
    fn legacy_addr(&self) -> Option<String> {
        self.host
            .as_ref()
            .zip(self.port)
            .map(|(host, port)| format!("{}:{}", host, port))
    }

    pub fn grpc_addr(&self) -> Option<String> {
        match &self.grpc {
            Some(endpoint) => {
                endpoint.resolve_with_defaults(self.host.as_ref(), self.port.as_ref())
            }
            None => self.legacy_addr(),
        }
    }

    pub fn http_addr(&self) -> Option<String> {
        match &self.http {
            Some(endpoint) => {
                endpoint.resolve_with_defaults(self.host.as_ref(), self.port.as_ref())
            }
            None => self.legacy_addr(),
        }
    }

    pub fn require_grpc_addr(&self) -> anyhow::Result<String> {
        self.grpc_addr()
            .ok_or_else(|| anyhow!("server.grpc host/port not configured"))
    }

    pub fn require_http_addr(&self) -> anyhow::Result<String> {
        self.http_addr()
            .ok_or_else(|| anyhow!("server.http host/port not configured"))
    }
}
