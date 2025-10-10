use parking_lot::RwLock;
use std::collections::HashMap;
use std::sync::Arc;

/// 统一规范化（按需扩展：大小写折叠、全角转半角、Emoji 归一化等）
#[inline]
fn normalize<S: AsRef<str>>(s: S) -> String {
    s.as_ref().trim().to_string()
}

/// 字符串享元池：相同文本只保留一份 Arc<str>
#[derive(Default)]
pub struct AliasPool {
    pool: RwLock<HashMap<String, Arc<str>>>, // key 为规范化后的文本
}

impl AliasPool {
    pub fn new() -> Self {
        Self {
            pool: RwLock::new(HashMap::new()),
        }
    }

    /// 放入并返回共享引用；多次传入相同文本将返回同一 Arc<str>
    pub fn intern<S: AsRef<str>>(&self, alias: S) -> Arc<str> {
        let key = normalize(alias);
        if let Some(a) = self.pool.read().get(&key) {
            return a.clone();
        }
        // 双检：避免并发下重复创建
        let arc: Arc<str> = Arc::from(key.as_str());
        let mut w = self.pool.write();
        w.entry(key).or_insert_with(|| arc.clone()).clone()
    }
}

/// 全局享元池（线程安全）
pub static ALIAS_POOL: once_cell::sync::Lazy<AliasPool> =
    once_cell::sync::Lazy::new(|| AliasPool::new());
