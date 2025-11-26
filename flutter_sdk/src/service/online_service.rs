use std::collections::HashMap;
use std::sync::RwLock;
use std::time::{SystemTime, UNIX_EPOCH};

use once_cell::sync::OnceCell;

use crate::api::app_api_types::{
    CheckOnlineBatchQuery, CheckOnlineBatchResult, OnlineStatusEntry, OnlineStatusSnapshot,
};
use crate::api::user_api;
use crate::service::friend_service::FriendService;

const ONLINE_CACHE_TTL_MS: i64 = 60_000; // 60s，短期缓存，防止频繁请求。
const ONLINE_BATCH_SIZE: usize = 100;

static INSTANCE: OnceCell<OnlineService> = OnceCell::new();

pub struct OnlineService {
    cache: RwLock<HashMap<i64, CachedStatus>>,
}

#[derive(Clone, Debug)]
struct CachedStatus {
    online: bool,
    fetched_at: i64,
}

impl OnlineService {
    pub fn init() -> Result<(), String> {
        INSTANCE
            .set(OnlineService {
                cache: RwLock::new(HashMap::new()),
            })
            .map_err(|_| "OnlineService already initialized".to_string())
    }

    pub fn get() -> &'static OnlineService {
        INSTANCE.get().expect("OnlineService is not initialized")
    }

    /// 查询好友在线状态，带短期缓存；网络失败时回退上次数据并标记 stale。
    pub fn online_friends(
        &self,
        session_token: &str,
        force_refresh: bool,
    ) -> Result<OnlineStatusSnapshot, String> {
        let ids = FriendService::get().list_ids()?;
        self.online_status_for_ids(&ids, session_token, force_refresh)
    }

    /// 查询指定用户的在线状态。
    pub fn online_status_for_ids(
        &self,
        uids: &[i64],
        session_token: &str,
        force_refresh: bool,
    ) -> Result<OnlineStatusSnapshot, String> {
        let now = current_millis();
        let ttl = ONLINE_CACHE_TTL_MS;
        let mut missing = Vec::new();
        let mut entries = Vec::with_capacity(uids.len());

        {
            let cache = self.cache.read().map_err(|_| "online cache poisoned")?;
            for uid in uids {
                if let Some(item) = cache.get(uid) {
                    let expired = now - item.fetched_at > ttl;
                    if force_refresh || expired {
                        missing.push(*uid);
                    } else {
                        entries.push(OnlineStatusEntry {
                            uid: *uid,
                            online: item.online,
                            fetched_at: item.fetched_at,
                        });
                    }
                } else {
                    missing.push(*uid);
                }
            }
        }

        let mut stale = false;
        if !missing.is_empty() {
            match self.fetch_and_cache(session_token, &missing, now) {
                Ok(fetched) => entries.extend(fetched),
                Err(err) => {
                    // 网络失败时回退已有缓存并标记 stale。
                    let cache = self.cache.read().map_err(|_| "online cache poisoned")?;
                    for uid in &missing {
                        if let Some(item) = cache.get(uid) {
                            entries.push(OnlineStatusEntry {
                                uid: *uid,
                                online: item.online,
                                fetched_at: item.fetched_at,
                            });
                        }
                    }
                    stale = true;
                    if entries.is_empty() {
                        return Err(err);
                    }
                }
            }
        }

        // 按 uid 去重（可能部分命中缓存部分从网络获取）。
        entries.sort_by_key(|e| e.uid);
        entries.dedup_by_key(|e| e.uid);

        Ok(OnlineStatusSnapshot {
            items: entries,
            stale,
        })
    }

    fn fetch_and_cache(
        &self,
        session_token: &str,
        uids: &[i64],
        now: i64,
    ) -> Result<Vec<OnlineStatusEntry>, String> {
        let mut results = Vec::new();
        for chunk in uids.chunks(ONLINE_BATCH_SIZE) {
            let payload = CheckOnlineBatchQuery {
                session_token: session_token.to_string(),
                uids: chunk.to_vec(),
            };
            let resp: CheckOnlineBatchResult = user_api::check_online_batch(payload)?;
            let mut cache = self.cache.write().map_err(|_| "online cache poisoned")?;
            for item in resp.items {
                cache.insert(
                    item.uid,
                    CachedStatus {
                        online: item.online,
                        fetched_at: now,
                    },
                );
                results.push(OnlineStatusEntry {
                    uid: item.uid,
                    online: item.online,
                    fetched_at: now,
                });
            }
        }
        Ok(results)
    }
}

fn current_millis() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|dur| dur.as_millis() as i64)
        .unwrap_or_default()
}
