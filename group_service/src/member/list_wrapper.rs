use parking_lot::RwLock;
use roaring::RoaringTreemap as RB64;
use std::collections::HashMap;

use common::infra::grpc::grpc_group::group_service::{GroupRoleType, MemberRef};
use common::{MemberListError, UID};

#[derive(Debug, Default)]
pub struct MemberListWrapper {
    members: RwLock<RB64>,
    owners: RwLock<RB64>,
    admins: RwLock<RB64>,
    aliases: RwLock<HashMap<u64, String>>, // 别名（可按需换成分片化结构）
}

impl MemberListWrapper {
    pub fn new_simple() -> Self {
        Self {
            members: RwLock::new(RB64::new()),
            owners: RwLock::new(RB64::new()),
            admins: RwLock::new(RB64::new()),
            aliases: RwLock::new(HashMap::new()),
        }
    }

    #[inline]
    fn to_u64(id: UID) -> Result<u64, MemberListError> {
        if id <= 0 {
            return Err(MemberListError::InvalidUID);
        }
        Ok(id as u64)
    }

    #[inline]
    fn role_to_i32(role: GroupRoleType) -> i32 {
        role as i32
    }

    #[inline]
    fn role_from_i32(v: i32) -> GroupRoleType {
        // prost 生成的一般是 from_i32；兼容 try_from 的场景
        GroupRoleType::from_i32(v).unwrap_or(GroupRoleType::Member)
    }

    #[inline]
    fn role_of(owners: &RB64, admins: &RB64, uid: u64) -> GroupRoleType {
        if owners.contains(uid) {
            GroupRoleType::Owner
        } else if admins.contains(uid) {
            GroupRoleType::Admin
        } else {
            GroupRoleType::Member
        }
    }

    #[inline]
    fn owner_count_locked(owners: &RB64) -> usize {
        owners.len() as usize
    }

    /// 在拿到写锁的前提下，原子地设置 uid 的角色位（只允许单一角色）
    #[inline]
    fn set_role_bits(owners: &mut RB64, admins: &mut RB64, uid: u64, role: GroupRoleType) {
        match role {
            GroupRoleType::Owner => {
                owners.insert(uid);
                admins.remove(uid);
            }
            GroupRoleType::Admin => {
                admins.insert(uid);
                owners.remove(uid);
            }
            _ => {
                owners.remove(uid);
                admins.remove(uid);
            }
        }
    }

    /// 新增成员（含别名、角色）
    pub fn add(&self, member: MemberRef) -> Result<(), MemberListError> {
        let uid = Self::to_u64(member.id)?;

        // 统一锁顺序：members -> owners -> admins -> aliases
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();
        let mut al = self.aliases.write();

        m.insert(uid);
        Self::set_role_bits(&mut o, &mut a, uid, Self::role_from_i32(member.role));

        match member.alias {
            Some(alias) if !alias.is_empty() => {
                al.insert(uid, alias);
            }
            _ => {
                al.remove(&uid);
            } // 空或未设置则清空
        }

        Ok(())
    }

    /// 批量新增（slice），尽量减少锁竞争
    pub fn add_many_slice(&self, list: &[MemberRef]) -> Result<(), MemberListError> {
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();
        let mut al = self.aliases.write();

        for member in list {
            let uid = Self::to_u64(member.id)?;
            m.insert(uid);
            Self::set_role_bits(&mut o, &mut a, uid, Self::role_from_i32(member.role));
            match &member.alias {
                Some(alias) if !alias.is_empty() => {
                    al.insert(uid, alias.clone());
                }
                _ => {
                    al.remove(&uid);
                }
            }
        }
        Ok(())
    }

    pub fn add_many(&self, list: Vec<MemberRef>) -> Result<(), MemberListError> {
        self.add_many_slice(&list)
    }

    /// 删除成员（包含角色与别名清理）；保护“最后一个 Owner”
    pub fn remove(&self, uid: UID) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(uid)?;

        // 先读 owners 判断“最后一个群主”约束
        {
            let o = self.owners.read();
            if o.contains(uid) && Self::owner_count_locked(&o) == 1 {
                return Err(MemberListError::PreconditionFailed(
                    "cannot remove the last owner".into(),
                ));
            }
        }

        let mut m = self.members.write();
        if m.remove(uid) {
            let mut o = self.owners.write();
            let mut a = self.admins.write();
            let mut al = self.aliases.write();
            o.remove(uid);
            a.remove(uid);
            al.remove(&uid);
            Ok(true)
        } else {
            Ok(false)
        }
    }

    /// 修改成员角色（若成员不存在，会将其加入 members 集）；
    /// 保护“最后一个 Owner”不被降级。
    pub fn change_role(&self, uid: UID, role: GroupRoleType) -> Result<(), MemberListError> {
        let uid = Self::to_u64(uid)?;

        // 如果是从 Owner 降级，需要检查是否为最后一个 Owner
        if !matches!(role, GroupRoleType::Owner) {
            let o = self.owners.read();
            if o.contains(uid) && Self::owner_count_locked(&o) == 1 {
                return Err(MemberListError::PreconditionFailed(
                    "cannot demote the last owner".into(),
                ));
            }
        }

        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();

        m.insert(uid); // 保持与原实现一致：若不存在，先加入成员集
        Self::set_role_bits(&mut o, &mut a, uid, role);
        Ok(())
    }

    /// 修改/清空别名（None 或 空字符串 => 清空）；仅允许群内成员
    pub fn change_alias<S: AsRef<str>>(
        &self,
        uid: UID,
        alias: Option<S>,
    ) -> Result<(), MemberListError> {
        let uid = Self::to_u64(uid)?;
        if !self.members.read().contains(uid) {
            return Err(MemberListError::NotFound);
        }
        let mut al = self.aliases.write();
        match alias {
            Some(s) if !s.as_ref().is_empty() => {
                al.insert(uid, s.as_ref().to_string());
            }
            _ => {
                al.remove(&uid);
            }
        }
        Ok(())
    }

    /// 获取某成员别名
    #[inline]
    pub fn get_alias(&self, uid: UID) -> Result<Option<String>, MemberListError> {
        let uid = Self::to_u64(uid)?;
        Ok(self.aliases.read().get(&uid).cloned())
    }

    /// 获取某成员角色（无则返回 Member）
    #[inline]
    pub fn get_role(&self, uid: UID) -> Result<GroupRoleType, MemberListError> {
        let uid = Self::to_u64(uid)?;
        let o = self.owners.read();
        let a = self.admins.read();
        Ok(Self::role_of(&o, &a, uid))
    }

    #[inline]
    pub fn is_owner(&self, uid: UID) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(uid)?;
        Ok(self.owners.read().contains(uid))
    }

    #[inline]
    pub fn owner_count(&self) -> usize {
        self.owners.read().len() as usize
    }

    #[inline]
    pub fn len(&self) -> usize {
        self.members.read().len() as usize
    }

    /// 导出所有成员（包含角色与别名）
    pub fn get_all(&self) -> Vec<MemberRef> {
        let m = self.members.read();
        let o = self.owners.read();
        let a = self.admins.read();
        let al = self.aliases.read();

        let mut out = Vec::with_capacity(m.len() as usize);
        for uid in m.iter() {
            let role = Self::role_of(&o, &a, uid);
            let alias = al.get(&uid).cloned();
            out.push(MemberRef {
                id: uid as i64,
                alias, // prost: Option<String>
                role: Self::role_to_i32(role),
            });
        }
        out
    }

    /// 仅导出管理角色（群主 + 管理员）。
    pub fn get_managers(&self) -> Vec<MemberRef> {
        let o = self.owners.read();
        let a = self.admins.read();
        let al = self.aliases.read();

        let mut out = Vec::with_capacity(o.len() as usize + a.len() as usize);

        for uid in o.iter() {
            let alias = al.get(&uid).cloned();
            out.push(MemberRef {
                id: uid as i64,
                alias,
                role: GroupRoleType::Owner as i32,
            });
        }

        for uid in a.iter() {
            if o.contains(uid) {
                continue;
            }
            let alias = al.get(&uid).cloned();
            out.push(MemberRef {
                id: uid as i64,
                alias,
                role: GroupRoleType::Admin as i32,
            });
        }

        out
    }

    /// 分页导出（按 RB64 的有序迭代，稳定分页）
    pub fn get_page(&self, page: usize, page_size: usize) -> Vec<MemberRef> {
        if page_size == 0 {
            return Vec::new();
        }
        let m = self.members.read();
        let total = m.len() as usize;
        let start = page.saturating_mul(page_size);
        if start >= total {
            return Vec::new();
        }

        let o = self.owners.read();
        let a = self.admins.read();
        let al = self.aliases.read();

        m.iter()
            .skip(start)
            .take(page_size)
            .map(|uid| {
                let role = Self::role_of(&o, &a, uid);
                let alias = al.get(&uid).cloned();
                MemberRef {
                    id: uid as i64,
                    alias,
                    role: Self::role_to_i32(role),
                }
            })
            .collect()
    }

    #[inline]
    pub fn contains(&self, uid: UID) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(uid)?;
        Ok(self.members.read().contains(uid))
    }

    /// 清空当前列表（用于群解散或重建快照）
    pub fn clear(&self) {
        self.members.write().clear();
        self.owners.write().clear();
        self.admins.write().clear();
        self.aliases.write().clear();
    }
}
