use crate::errors::AppError;
use config::Config;
use log::LevelFilter;
use once_cell::sync::OnceCell;
use serde::Deserialize;
use sqlx::mysql::MySqlPoolOptions;
use sqlx::{MySql, Pool};
use std::str::FromStr;
use std::sync::Arc;
use std::time::Duration;
use crate::redis::redis_pool::RedisPoolTools;

pub type MySqlPool = Pool<MySql>;

#[derive(Debug, Deserialize, Clone, Default)]
pub struct AppConfig {
    pub database: Option<DatabaseConfig>,
    pub server: Option<ServerConfig>,
    pub sys: Option<SysConfig>,
    pub grpc: Option<GrpcConfig>,
    pub redis: Option<RedisConfig>,
    pub socket: Option<SocketConfig>,
}
#[derive(Debug, Deserialize, Clone, Default)]
pub struct ShardConfig {
    pub client_addr: Option<String>,
    pub server_addr: Option<String>,
}
async fn init_db(url: &str) {
    let pool = MySqlPoolOptions::new()
        .max_connections(64)
        .min_connections(8)
        .acquire_timeout(Duration::from_secs(5))
        .connect(url)
        .await.expect("Failed to connect to MySQL");
    DB_INSTANCE
        .set(Arc::new(pool)).expect("Failed to init DB_INSTANCE");  // <— 处理重复初始化
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
        let cfg = config.try_deserialize::<AppConfig>().expect("Failed to deserialize configuration");
        return cfg;
    }
    /// 从环境变量 `APP_CONFIG` 读取配置文件路径；不存在则回退到传入默认路径
    pub async fn init_from_env(default_file: &str) -> Self {
        let path = std::env::var("APP_CONFIG").unwrap_or_else(|_| default_file.to_string());
        Self::init(&path).await
    }
    pub async fn init(file: &str) ->Self{
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
        INSTANCE.set(Arc::new(instance.clone())).expect("INSTANCE already initialized");
        return instance
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
    pub fn get_socket(&self) -> SocketConfig { self.socket.clone().unwrap_or_default() }
    /// 获取单例
    pub fn get() -> Arc<Self> {
        INSTANCE.get().expect("INSTANCE is not initialized").clone()
    }
    //强制下线
}

pub fn init_log(log_lovel: &str) -> Result<(), AppError> {
    let mut builder = env_logger::Builder::new();
    let filter = builder.filter(None, LevelFilter::from_str(log_lovel).unwrap());
    filter.init();
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
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
}


#[derive(Debug, Deserialize, Clone, Default)]
pub struct GrpcConfig {
    pub server_addr: Option<String>,
    pub client_addr: Option<String>,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct RedisConfig {
    pub url: String,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct SocketConfig {
    /// ACK 分片数量（缺省为 CPU 核数）
    pub ack_shards: Option<usize>,
    /// ACK 重试间隔（毫秒，缺省 500ms）
    pub ack_retry_ms: Option<u64>,
    /// 分片调度器分片数（缺省为 CPU 核数）
    pub dispatch_shards: Option<usize>,
    /// 分片队列容量（缺省 10000）
    pub dispatch_cap: Option<usize>,
    /// Kafka broker 地址（优先使用此配置）
    pub kafka_broker: Option<String>,
    /// Kafka 消费组（优先使用此配置）
    pub kafka_group_id: Option<String>,
}
