/// 多端登录策略：决定注册新会话时如何处理已有会话
#[derive(Clone, Copy, Debug)]
pub enum MultiLoginPolicy {
    /// 同一账号所有设备可以同时在线
    AllowAll,
    /// 每种设备类型只允许一个在线会话
    SinglePerDeviceType,
    /// 全局只允许一个会话，新会话会踢掉旧会话
    SingleGlobal,
}

/// 会话管理策略：多端登录与容量限制
#[derive(Clone)]
pub struct SessionPolicy {
    /// 多端登录策略
    pub multi_login: MultiLoginPolicy,
    /// 单个账号允许同时在线的最大会话数
    pub max_sessions_per_user: usize,
}

impl Default for SessionPolicy {
    /// 默认策略：同设备类型互斥，同时允许最多 5 个会话。
    fn default() -> Self {
        Self {
            multi_login: MultiLoginPolicy::SinglePerDeviceType,
            max_sessions_per_user: 5,
        }
    }
}
