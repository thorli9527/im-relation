use std::{sync::Arc, time::Duration};
use dashmap::DashMap;
use log::{debug};
use moka::sync::Cache;
use crate::profile::model::GroupEntity;
use super::GroupProfileStorage;

/// 本地 L1 缓存（写穿）+ 单飞加载；逐出时不主动写回（避免丢写风险）
#[derive(Clone)]
pub struct GroupProfileCache<S: GroupProfileStorage> {
    cache:   Cache<i64, Arc<GroupEntity>>,
    storage: Arc<S>,
    loading: DashMap<i64, Arc<tokio::sync::Mutex<()>>>, // per-gid singleflight
}

impl<S: GroupProfileStorage> GroupProfileCache<S> {
    pub fn new(storage: Arc<S>, cap: u64, tti_secs: u64) -> Self {
        let cache = Cache::builder()
            .max_capacity(cap)
            .time_to_idle(Duration::from_secs(tti_secs))
            .build();
        Self { cache, storage, loading: DashMap::new() }
    }

    #[inline]
    fn now_ms() -> u64 {
        use std::time::{SystemTime, UNIX_EPOCH};
        SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_millis() as u64
    }

    /// 读：L1 命中→返回；miss→单飞冷读→回填→返回
    pub async fn get_or_load(&self, gid: i64) -> anyhow::Result<Option<Arc<GroupEntity>>> {
        if let Some(v) = self.cache.get(&gid) { return Ok(Some(v)); }

        // 单飞
        let g = self.loading
            .entry(gid)
            .or_insert_with(|| Arc::new(tokio::sync::Mutex::new(())))
            .clone();
        let _guard = g.lock().await;

        if let Some(v) = self.cache.get(&gid) { return Ok(Some(v)); }

        let loaded = self.storage.load_group_info(gid).await?;
        if let Some(e) = loaded {
            let arc = Arc::new(e);
            self.cache.insert(gid, arc.clone());
            Ok(Some(arc))
        } else {
            Ok(None)
        }
    }

    /// 写穿：DB 成功 → 刷新 L1
    /// expected_update_time 用于 CAS，Some(ts) 表示基于当前值的乐观锁更新
    pub async fn upsert(
        &self,
        mut entity: GroupEntity,
        expected_update_time: Option<u64>,
    ) -> anyhow::Result<()> {
        entity.update_time = Self::now_ms();
        let ok = self.storage.save_group_info(&entity, expected_update_time).await?;
        if !ok {
            anyhow::bail!("conflict on save_group_info (CAS failed)");
        }
        self.cache.insert(entity.id, Arc::new(entity));
        Ok(())
    }

    /// 删除：DB 成功后失效 L1
    pub async fn delete(&self, gid: i64) -> anyhow::Result<()> {
        self.storage.delete_group_info(gid).await?;
        self.cache.invalidate(&gid);
        Ok(())
    }

    #[inline] pub fn invalidate(&self, gid: i64) { self.cache.invalidate(&gid); }
    #[inline] pub fn touch(&self, gid: i64) { let _ = self.cache.get(&gid); } // 刷新TTI
}
