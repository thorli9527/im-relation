use crate::profile::model::GroupEntity;
use async_trait::async_trait;

/// 群资料冷存接口（方案A：L1写穿）
#[async_trait]
pub trait GroupProfileStorage: Send + Sync {
    /// 按主键读取
    async fn load_group_info(&self, gid: i64) -> anyhow::Result<Option<GroupEntity>>;

    /// 写穿保存：
    /// - expected_update_time = Some(ts) 时执行 CAS 更新（避免并发覆盖）
    /// - None 时执行 insert/upsert（用于创建或不关心并发覆盖）
    /// 返回：true=写入成功 / false=CAS失败
    async fn save_group_info(
        &self,
        entity: &GroupEntity,
        expected_update_time: Option<u64>,
    ) -> anyhow::Result<bool>;

    /// 删除
    async fn delete_group_info(&self, gid: i64) -> anyhow::Result<()>;
}
