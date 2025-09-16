/// 多端登录策略：决定注册新会话时如何处理已有会话
#[derive(Clone, Copy, Debug)]
pub enum MultiLoginPolicy {
    AllowAll,
    SinglePerDeviceType,
    SingleGlobal,
}

/// 会话管理策略：多端登录与容量限制
#[derive(Clone)]
pub struct SessionPolicy {
    pub multi_login: MultiLoginPolicy,
    pub max_sessions_per_user: usize,
}

impl Default for SessionPolicy {
    fn default() -> Self {
        Self {
            multi_login: MultiLoginPolicy::SinglePerDeviceType,
            max_sessions_per_user: 5,
        }
    }
}
