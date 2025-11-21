use crate::core::errors::AppError;
use crate::infra::grpc::grpc_user::online_service::AddFriendPolicy;
use crate::infra::redis::redis_pool::RedisPoolTools;
use crate::support::node::NodeType;
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
    pub redis: Option<RedisConfig>,
    pub socket: Option<SocketConfig>,
    #[serde(
        default,
        rename = "app_socket",
        deserialize_with = "deserialize_socket_configs"
    )]
    pub app_socket_nodes: Vec<SocketConfig>,
    pub hot_group: Option<HotGroupConfig>,
    pub hot_friend: Option<HotFriendConfig>,
    pub hot_online: Option<HotOnlineConfig>,
    pub user_defaults: Option<UserDefaultsConfig>,
    pub msg_friend: Option<MsgFriendConfig>,
    pub kafka: Option<KafkaConfig>,
    #[serde(default, deserialize_with = "deserialize_endpoints")]
    pub friend_service: Vec<ServiceEndpoint>,
    #[serde(default, deserialize_with = "deserialize_endpoints")]
    pub user_service: Vec<ServiceEndpoint>,
    #[serde(default, deserialize_with = "deserialize_endpoints")]
    pub group_service: Vec<ServiceEndpoint>,
    #[serde(default, deserialize_with = "deserialize_endpoints")]
    pub msg_friend_nodes: Vec<ServiceEndpoint>,
    #[serde(default, deserialize_with = "deserialize_endpoints")]
    pub msg_group_nodes: Vec<ServiceEndpoint>,
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
pub struct UserDefaultsConfig {
    #[serde(default)]
    pub allow_add_friend: Option<AllowAddFriendSetting>,
}

#[derive(Debug, Deserialize, Clone)]
#[serde(untagged)]
pub enum AllowAddFriendSetting {
    Int(i32),
    Str(String),
}

impl AllowAddFriendSetting {
    fn as_policy_value(&self) -> Option<i32> {
        match self {
            Self::Int(value) => Some(*value),
            Self::Str(raw) => {
                let trimmed = raw.trim();
                if trimmed.is_empty() {
                    return None;
                }
                if let Ok(num) = trimmed.parse::<i32>() {
                    return Some(num);
                }
                if let Some(policy) = AddFriendPolicy::from_str_name(trimmed) {
                    return Some(policy as i32);
                }
                let normalized = trimmed.to_ascii_uppercase();
                if normalized == "UNSPECIFIED" {
                    return Some(AddFriendPolicy::AddFriendUnspecified as i32);
                }
                AddFriendPolicy::from_str_name(normalized.as_str()).map(|policy| policy as i32)
            }
        }
    }
}

impl UserDefaultsConfig {
    pub fn allow_add_friend_policy(&self) -> Option<i32> {
        self.allow_add_friend
            .as_ref()
            .and_then(AllowAddFriendSetting::as_policy_value)
    }
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

#[derive(Debug, Deserialize, Clone, Default)]
pub struct ServiceEndpoint {
    #[serde(default)]
    pub index: u32,
    #[serde(default)]
    pub url: Option<String>,
    #[serde(default)]
    pub grpc_addr: Option<String>,
}

impl ServiceEndpoint {
    pub fn from_addr(addr: String) -> Self {
        Self {
            index: 0,
            url: None,
            grpc_addr: Some(addr),
        }
    }

    pub fn resolved_url(&self) -> Option<String> {
        self.url.clone().or_else(|| self.grpc_addr.clone())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn deserialize_single_endpoint_table() {
        let cfg: AppConfig = toml::from_str(
            r#"
            [user_service]
            grpc_addr = "127.0.0.1:6001"
            "#,
        )
        .unwrap();

        assert_eq!(cfg.user_service.len(), 1);
        assert_eq!(
            cfg.user_service[0].grpc_addr.as_deref(),
            Some("127.0.0.1:6001")
        );
    }

    #[test]
    fn deserialize_single_endpoint_inline_string() {
        let cfg: AppConfig = toml::from_str(
            r#"
            user_service = "127.0.0.1:6001"
            "#,
        )
        .unwrap();

        assert_eq!(cfg.user_service.len(), 1);
        assert_eq!(
            cfg.user_service[0].grpc_addr.as_deref(),
            Some("127.0.0.1:6001")
        );
    }

    #[test]
    fn deserialize_endpoint_array() {
        let cfg: AppConfig = toml::from_str(
            r#"
            [[user_service]]
            index = 2
            grpc_addr = "127.0.0.1:6001"

            [[user_service]]
            index = 1
            url = "https://example.com"
            "#,
        )
        .unwrap();

        assert_eq!(cfg.user_service.len(), 2);
        assert_eq!(cfg.user_service[0].index, 2);
        assert_eq!(cfg.user_service[1].index, 1);
    }
}

fn deserialize_endpoints<'de, D>(deserializer: D) -> Result<Vec<ServiceEndpoint>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    #[derive(Deserialize)]
    #[serde(untagged)]
    enum EndpointList {
        Addr(String),
        Single(ServiceEndpoint),
        List(Vec<ServiceEndpoint>),
    }

    let endpoints = Option::<EndpointList>::deserialize(deserializer)?;

    Ok(match endpoints {
        Some(EndpointList::Addr(addr)) => vec![ServiceEndpoint::from_addr(addr)],
        Some(EndpointList::Single(endpoint)) => vec![endpoint],
        Some(EndpointList::List(list)) => list,
        None => Vec::new(),
    })
}

fn deserialize_socket_configs<'de, D>(deserializer: D) -> Result<Vec<SocketConfig>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    #[derive(Deserialize)]
    #[serde(untagged)]
    enum SocketConfigList {
        Single(SocketConfig),
        List(Vec<SocketConfig>),
    }

    let configs = Option::<SocketConfigList>::deserialize(deserializer)?;

    Ok(match configs {
        Some(SocketConfigList::Single(cfg)) => vec![cfg],
        Some(SocketConfigList::List(list)) => list,
        None => Vec::new(),
    })
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

        // 初始化日志：优先 sys.log_leve，其次环境变量 RUST_LOG，最后默认 info。
        let log_level = instance
            .sys
            .as_ref()
            .and_then(|sys| sys.log_leve.clone())
            .or_else(|| std::env::var("RUST_LOG").ok())
            .unwrap_or_else(|| "info".to_string());
        init_log(&log_level).expect("init log error");
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
        if let Some(cfg) = self.socket.clone() {
            return cfg;
        }
        self.app_socket_nodes.first().cloned().unwrap_or_default()
    }

    pub fn app_socket_configs(&self) -> &[SocketConfig] {
        &self.app_socket_nodes
    }

    pub fn hot_online_cfg(&self) -> HotOnlineConfig {
        self.hot_online.clone().unwrap_or_default()
    }

    pub fn user_defaults_cfg(&self) -> UserDefaultsConfig {
        self.user_defaults.clone().unwrap_or_default()
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

    pub fn friend_service_endpoints(&self) -> &[ServiceEndpoint] {
        &self.friend_service
    }

    pub fn user_service_endpoints(&self) -> &[ServiceEndpoint] {
        &self.user_service
    }

    pub fn msg_friend_endpoints(&self) -> &[ServiceEndpoint] {
        &self.msg_friend_nodes
    }

    pub fn msg_group_endpoints(&self) -> &[ServiceEndpoint] {
        &self.msg_group_nodes
    }

    pub fn group_service_endpoints(&self) -> &[ServiceEndpoint] {
        &self.group_service
    }

    fn sorted_urls(list: &[ServiceEndpoint]) -> Vec<String> {
        let mut entries = list.to_vec();
        entries.sort_by_key(|endpoint| endpoint.index);
        entries
            .into_iter()
            .filter_map(|endpoint| endpoint.resolved_url())
            .collect()
    }

    fn sorted_socket_urls(list: &[SocketConfig]) -> Vec<String> {
        let mut entries = list.to_vec();
        entries.sort_by_key(|cfg| cfg.index.unwrap_or(u32::MAX));
        entries
            .into_iter()
            .filter_map(|cfg| cfg.pub_addr().or_else(|| cfg.tcp_addr().ok()))
            .collect()
    }

    fn socket_node_urls(&self) -> Vec<String> {
        let mut nodes = self.app_socket_nodes.clone();
        if nodes.is_empty() {
            if let Some(cfg) = self.socket.clone() {
                nodes.push(cfg);
            }
        } else if let Some(cfg) = self.socket.clone() {
            nodes.push(cfg);
        }

        let mut urls = Self::sorted_socket_urls(&nodes);

        if urls.is_empty() {
            if let Some(cfg) = self.socket.clone() {
                if let Some(addr) = cfg.pub_addr().or_else(|| cfg.tcp_addr().ok()) {
                    urls.push(addr);
                }
            }
        }

        urls
    }

    pub fn urls_for_node_type(&self, node_type: NodeType) -> Vec<String> {
        match node_type {
            NodeType::SocketNode | NodeType::SocketGateway | NodeType::MsgGateway => {
                self.socket_node_urls()
            }
            NodeType::FriendNode => Self::sorted_urls(&self.friend_service),
            NodeType::OnlineNode => Self::sorted_urls(&self.user_service),
            NodeType::MsgFriend => Self::sorted_urls(&self.msg_friend_nodes),
            NodeType::GroupNode => Self::sorted_urls(&self.group_service),
            NodeType::MesGroup => Self::sorted_urls(&self.msg_group_nodes),
            _ => Vec::new(),
        }
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
    builder.format_timestamp_millis();
    let level = LevelFilter::from_str(log_lovel).unwrap_or(LevelFilter::Info);
    builder.filter(None, level);
    let _ = builder.try_init();
    Ok(())
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
pub struct RedisConfig {
    pub url: String,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct KafkaConfig {
    pub broker: Option<String>,
    pub group_id: Option<String>,
    #[serde(default)]
    pub replicas: Option<i32>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct SocketConfig {
    /// Socket 节点唯一索引（用于仲裁注册/哈希）。
    pub index: Option<u32>,
    /// Socket TCP 监听地址（优先级最高）。
    pub addr: Option<String>,
    /// Socket TCP 监听 Host（与 `port` 一起使用）。
    pub host: Option<String>,
    /// Socket TCP 监听端口。
    pub port: Option<u16>,
    /// Socket 对外暴露的 Host。
    #[serde(alias = "pub_socket_ip")]
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
    /// 当前 socket 节点逻辑索引，缺省为 0。
    pub fn index(&self) -> u32 {
        self.index.unwrap_or(0)
    }

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
