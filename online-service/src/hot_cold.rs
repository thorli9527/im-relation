//! hot_cold.rs
//! 仅做“用户实体”的热/冷门面：支持 id / email / phone / name 四键查询，含短 TTL 负缓存。
//! - 库先行，缓存后置；目录表定位 email/phone/name → id；不涉及好友关系。
//! - 依赖：moka 0.12（sync），anyhow，bytes

use std::{collections::HashMap, sync::Arc, time::Duration};

use anyhow::{anyhow, Result};
use bytes::Bytes;
use moka::sync::{Cache, CacheBuilder};

use crate::db::traits::{ClientReadRepo, DirectoryReadRepo};
use crate::grpc::client_service::ClientEntity;

// ===================== 规范化接口 =====================

pub trait Normalizer: Send + Sync + 'static {
    fn email_norm(&self, s: &str) -> Result<Bytes>;
    fn phone_norm(&self, s: &str) -> Result<Bytes>;
    fn name_norm(&self, s: &str) -> Result<String>;
}

/// 示例占位：请替换为 idna / phonenumber 等真实实现
pub struct PassthroughNormalizer;
impl Normalizer for PassthroughNormalizer {
    fn email_norm(&self, s: &str) -> Result<Bytes> {
        Ok(Bytes::copy_from_slice(s.trim().to_ascii_lowercase().as_bytes()))
    }
    fn phone_norm(&self, s: &str) -> Result<Bytes> {
        Ok(Bytes::copy_from_slice(s.trim().as_bytes()))
    }
    fn name_norm(&self, s: &str) -> Result<String> {
        Ok(s.trim().to_lowercase())
    }
}

// ===================== 配置 =====================

#[derive(Clone, Debug)]
pub struct ClientHotConfig {
    /// 分片数（建议与 DB 分区一致，如 32）
    pub shard_count: usize,
    /// by_id 缓存容量（每分片）
    pub by_id_capacity: u64,
    /// by_id TTL
    pub by_id_ttl: Duration,
    /// 路由“正命中”缓存容量（全局）
    pub route_capacity: u64,
    /// 路由“正命中”TTL
    pub route_ttl: Duration,
    /// 路由“负命中”TTL（not-found）
    pub neg_route_ttl: Duration,
    /// 路由“负命中”容量（全局）
    pub neg_route_capacity: u64,
}
impl Default for ClientHotConfig {
    fn default() -> Self {
        Self {
            shard_count: 32,
            by_id_capacity: 40_000,
            by_id_ttl: Duration::from_secs(60 * 60),
            route_capacity: 500_000,
            route_ttl: Duration::from_secs(10 * 60),
            neg_route_ttl: Duration::from_secs(45),
            neg_route_capacity: 125_000, // 缺省为正缓存的 1/4
        }
    }
}

// ===================== Store =====================

#[derive(Clone)]
pub struct ClientHotStore<C: ClientReadRepo, D: DirectoryReadRepo, N: Normalizer> {
    // 分片的主缓存：id -> ClientEntity
    shards: Arc<[Shard]>,

    // 全局路由缓存（正/负分离）
    email_to_id_pos: Cache<Bytes, i64>,
    email_to_id_neg: Cache<Bytes, ()>,
    phone_to_id_pos: Cache<Bytes, i64>,
    phone_to_id_neg: Cache<Bytes, ()>,
    name_to_id_pos: Cache<Arc<str>, i64>,
    name_to_id_neg: Cache<Arc<str>, ()>,

    // 依赖
    repo: C,
    dir: D,
    normalizer: Arc<N>,
}

#[derive(Clone)]
struct Shard {
    by_id: Cache<i64, Arc<ClientEntity>>,
}

impl<C: ClientReadRepo, D: DirectoryReadRepo, N: Normalizer> ClientHotStore<C, D, N> {
    pub fn new(cfg: ClientHotConfig, repo: C, dir: D, normalizer: N) -> Self {
        assert!(cfg.shard_count > 0);

        // 分片 by_id
        let shards: Vec<_> = (0..cfg.shard_count)
            .map(|_| Shard {
                by_id: CacheBuilder::new(cfg.by_id_capacity)
                    .time_to_live(cfg.by_id_ttl)
                    .build(),
            })
            .collect();

        // 路由缓存（正/负）
        let email_to_id_pos = CacheBuilder::new(cfg.route_capacity)
            .time_to_live(cfg.route_ttl)
            .build();
        let email_to_id_neg = CacheBuilder::new(cfg.neg_route_capacity)
            .time_to_live(cfg.neg_route_ttl)
            .build();

        let phone_to_id_pos = CacheBuilder::new(cfg.route_capacity)
            .time_to_live(cfg.route_ttl)
            .build();
        let phone_to_id_neg = CacheBuilder::new(cfg.neg_route_capacity)
            .time_to_live(cfg.neg_route_ttl)
            .build();

        let name_to_id_pos = CacheBuilder::new(cfg.route_capacity)
            .time_to_live(cfg.route_ttl)
            .build();
        let name_to_id_neg = CacheBuilder::new(cfg.neg_route_capacity)
            .time_to_live(cfg.neg_route_ttl)
            .build();

        Self {
            shards: shards.into(),
            email_to_id_pos,
            email_to_id_neg,
            phone_to_id_pos,
            phone_to_id_neg,
            name_to_id_pos,
            name_to_id_neg,
            repo,
            dir,
            normalizer: Arc::new(normalizer),
        }
    }

    #[inline] fn shard_count(&self) -> usize { self.shards.len() }
    #[inline] fn idx(&self, id: i64) -> usize { (id as u64 % self.shard_count() as u64) as usize }
    #[inline] fn shard_of(&self, id: i64) -> &Shard { &self.shards[self.idx(id)] }

    // -------------- 基础：按 id 读取 --------------

    pub async fn get_by_id(&self, id: i64) -> Result<Arc<ClientEntity>> {
        if let Some(v) = self.shard_of(id).by_id.get(&id) {
            return Ok(v);
        }
        let ent = self
            .repo
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow!("not found: id={id}"))?;
        let arc = Arc::new(ent);
        self.shard_of(id).by_id.insert(id, arc.clone());
        Ok(arc)
    }

    /// 批量读取：先从缓存命中，缺失的统一回库一次；返回**按输入顺序**排列；任一缺失则返回 Err。
    pub async fn get_by_ids(&self, ids: &[i64]) -> Result<Vec<Arc<ClientEntity>>> {
        if ids.is_empty() {
            return Ok(vec![]);
        }

        let mut result: Vec<Option<Arc<ClientEntity>>> = Vec::with_capacity(ids.len());
        let mut misses: Vec<i64> = Vec::new();

        // 先看缓存
        for &id in ids {
            if let Some(v) = self.shard_of(id).by_id.get(&id) {
                result.push(Some(v));
            } else {
                result.push(None);
                misses.push(id);
            }
        }

        if !misses.is_empty() {
            // 回库一次
            let loaded = self.repo.get_by_ids(&misses).await?;
            let mut map: HashMap<i64, ClientEntity> = HashMap::with_capacity(loaded.len());
            for e in loaded {
                map.insert(e.id, e);
            }

            // 回填并写缓存
            for (pos, id) in ids.iter().copied().enumerate() {
                if result[pos].is_some() {
                    continue;
                }
                if let Some(ent) = map.remove(&id) {
                    let arc = Arc::new(ent);
                    self.shard_of(id).by_id.insert(id, arc.clone());
                    result[pos] = Some(arc);
                } else {
                    return Err(anyhow!("not found: id={}", id));
                }
            }
        }

        Ok(result.into_iter().map(|o| o.unwrap()).collect())
    }

    pub async fn exists(&self, id: i64) -> Result<bool> {
        // 不刷新 TTL 的快速检查
        if self.shard_of(id).by_id.contains_key(&id) {
            return Ok(true);
        }
        self.repo.exists(id).await
    }

    pub async fn get_version(&self, id: i64) -> Result<Option<i32>> {
        self.repo.get_version(id).await
    }

    pub async fn refresh_by_id(&self, id: i64) -> Result<Option<Arc<ClientEntity>>> {
        let opt = self.repo.get_by_id(id).await?;
        if let Some(ent) = opt {
            let arc = Arc::new(ent);
            self.shard_of(id).by_id.insert(id, arc.clone());
            Ok(Some(arc))
        } else {
            self.shard_of(id).by_id.invalidate(&id);
            Ok(None)
        }
    }

    // -------------- 路由键查询：email / phone / name --------------

    pub async fn get_by_email(&self, email_raw: &str) -> Result<Arc<ClientEntity>> {
        let norm = self.normalizer.email_norm(email_raw)?;

        if let Some(id) = self.email_to_id_pos.get(&norm) {
            return self.get_by_id(id).await;
        }
        if self.email_to_id_neg.contains_key(&norm) {
            return Err(anyhow!("not found"));
        }

        if let Some(id) = self.dir.get_id_by_email(&norm).await? {
            self.email_to_id_pos.insert(norm, id);
            return self.get_by_id(id).await;
        }

        self.email_to_id_neg.insert(norm, ());
        Err(anyhow!("not found"))
    }

    pub async fn get_by_phone(&self, phone_raw: &str) -> Result<Arc<ClientEntity>> {
        let norm = self.normalizer.phone_norm(phone_raw)?;

        if let Some(id) = self.phone_to_id_pos.get(&norm) {
            return self.get_by_id(id).await;
        }
        if self.phone_to_id_neg.contains_key(&norm) {
            return Err(anyhow!("not found"));
        }

        if let Some(id) = self.dir.get_id_by_phone(&norm).await? {
            self.phone_to_id_pos.insert(norm, id);
            return self.get_by_id(id).await;
        }

        self.phone_to_id_neg.insert(norm, ());
        Err(anyhow!("not found"))
    }

    pub async fn get_by_username(&self, username_raw: &str) -> Result<Arc<ClientEntity>> {
        let norm: Arc<str> = Arc::from(self.normalizer.name_norm(username_raw)?);

        if let Some(id) = self.name_to_id_pos.get(&norm) {
            return self.get_by_id(id).await;
        }
        if self.name_to_id_neg.contains_key(&norm) {
            return Err(anyhow!("not found"));
        }

        if let Some(id) = self.dir.get_id_by_name(&norm).await? {
            self.name_to_id_pos.insert(norm, id);
            return self.get_by_id(id).await;
        }

        self.name_to_id_neg.insert(norm, ());
        Err(anyhow!("not found"))
    }

    // -------------- 变更后的缓存维护（供 gRPC 成功后调用） --------------

    /// 注册成功：回填 by_id；如有 email/phone 则填充正路由缓存
    pub fn on_registered(&self, entity: ClientEntity) {
        let id = entity.id;
        let arc = Arc::new(entity);
        self.shard_of(id).by_id.insert(id, arc.clone());

        if let Some(ref e) = arc.email {
            if let Ok(b) = self.normalizer.email_norm(e) {
                self.email_to_id_pos.insert(b.clone(), id);
                self.email_to_id_neg.invalidate(&b);
            }
        }
        if let Some(ref p) = arc.phone {
            if let Ok(b) = self.normalizer.phone_norm(p) {
                self.phone_to_id_pos.insert(b.clone(), id);
                self.phone_to_id_neg.invalidate(&b);
            }
        }
        if let Ok(n) = self.normalizer.name_norm(&arc.name) {
            let k: Arc<str> = Arc::from(n);
            self.name_to_id_pos.invalidate(&k);
            self.name_to_id_neg.invalidate(&k);
        }
    }

    /// 改绑邮箱成功
    pub async fn on_change_email(&self, id: i64, old_email: Option<&str>, new_email: Option<&str>) {
        if let Some(o) = old_email {
            if let Ok(b) = self.normalizer.email_norm(o) {
                self.email_to_id_pos.invalidate(&b);
                self.email_to_id_neg.invalidate(&b);
            }
        }
        if let Some(n) = new_email {
            if let Ok(b) = self.normalizer.email_norm(n) {
                self.email_to_id_pos.insert(b, id);
            }
        }
        let _ = self.refresh_by_id(id).await;
    }

    /// 改绑手机成功
    pub async fn on_change_phone(&self, id: i64, old_phone: Option<&str>, new_phone: Option<&str>) {
        if let Some(o) = old_phone {
            if let Ok(b) = self.normalizer.phone_norm(o) {
                self.phone_to_id_pos.invalidate(&b);
                self.phone_to_id_neg.invalidate(&b);
            }
        }
        if let Some(n) = new_phone {
            if let Ok(b) = self.normalizer.phone_norm(n) {
                self.phone_to_id_pos.insert(b, id);
            }
        }
        let _ = self.refresh_by_id(id).await;
    }

    /// 资料更新（非路由字段）：若 name 变更，失效 name 路由；同时刷新 id 视图
    pub async fn on_update_profile(&self, id: i64, old_name: Option<&str>, new_name: Option<&str>) {
        if let (Some(o), Some(n)) = (old_name, new_name) {
            if o != n {
                if let Ok(o_norm) = self.normalizer.name_norm(o) {
                    let k: Arc<str> = Arc::from(o_norm);
                    self.name_to_id_pos.invalidate(&k);
                    self.name_to_id_neg.invalidate(&k);
                }
            }
        }
        let _ = self.refresh_by_id(id).await;
    }

    /// 显式失效某个 id 的 by_id 缓存（例如删除用户）
    pub fn invalidate_id(&self, id: i64) {
        self.shard_of(id).by_id.invalidate(&id);
    }
}
