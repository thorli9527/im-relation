use parking_lot::RwLock;
use roaring::RoaringTreemap as RB64;
use std::collections::HashMap;

use common::{MemberListError, UserId};
use crate::grpc::group_service::{GroupRoleType, MemberRef};

#[derive(Debug)]
pub struct MemberListWrapper {
    members: RwLock<RB64>,
    owners:  RwLock<RB64>,
    admins:  RwLock<RB64>,
    aliases: RwLock<HashMap<u64, String>>, // 新增：别名表（按需可换成 DashMap/Sharded）
}

impl Default for MemberListWrapper {
    fn default() -> Self { Self::new_simple() }
}

impl MemberListWrapper {
    pub fn new_simple() -> Self {
        Self {
            members: RwLock::new(RB64::new()),
            owners:  RwLock::new(RB64::new()),
            admins:  RwLock::new(RB64::new()),
            aliases: RwLock::new(HashMap::new()),
        }
    }

    #[inline]
    fn to_u64(id: UserId) -> Result<u64, MemberListError> {
        Ok(id as u64)
    }

    #[inline]
    fn role_to_i32(role: GroupRoleType) -> i32 { role as i32 }

    #[inline]
    fn role_from_i32(v: i32) -> GroupRoleType {
        GroupRoleType::try_from(v).unwrap_or(GroupRoleType::Member)
    }

    #[inline]
    fn role_of(owners: &RB64, admins: &RB64, uid: u64) -> GroupRoleType {
        if owners.contains(uid) { GroupRoleType::Owner }
        else if admins.contains(uid) { GroupRoleType::Admin }
        else { GroupRoleType::Member }
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
        match Self::role_from_i32(member.role) {
            GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
            GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
            _ => { o.remove(uid); a.remove(uid); }
        }

        match member.alias {
            Some(alias) if !alias.is_empty() => { al.insert(uid, alias); }
            _ => { al.remove(&uid); } // 空或未设置则清空
        }

        Ok(())
    }

    /// 批量新增（slice），原子性由调用方保证；内部尽量减少锁竞争
    pub fn add_many_slice(&self, list: &[MemberRef]) -> Result<(), MemberListError> {
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();
        let mut al = self.aliases.write();

        for member in list {
            let uid = Self::to_u64(member.id)?;
            m.insert(uid);
            match Self::role_from_i32(member.role) {
                GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
                GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
                _ => { o.remove(uid); a.remove(uid); }
            }

            match &member.alias {
                Some(alias) if !alias.is_empty() => { al.insert(uid, alias.clone()); }
                _ => { al.remove(&uid); }
            }
        }
        Ok(())
    }

    pub fn add_many(&self, list: Vec<MemberRef>) -> Result<(), MemberListError> {
        self.add_many_slice(&list)
    }

    /// 删除成员（包含角色与别名清理）
    pub fn remove(&self, user_id: UserId) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(user_id)?;
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

    /// 修改成员角色（若成员不存在，会将其加入 members 集）
    pub fn change_role(&self, user_id: UserId, role: GroupRoleType) -> Result<(), MemberListError> {
        let uid = Self::to_u64(user_id)?;
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();

        m.insert(uid);
        match role {
            GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
            GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
            _ => { o.remove(uid); a.remove(uid); }
        }
        Ok(())
    }

    /// 修改/清空别名（None 或 空字符串 => 清空）
    pub fn change_alias<S: AsRef<str>>(&self, user_id: UserId, alias: Option<S>) -> Result<(), MemberListError> {
        let uid = Self::to_u64(user_id)?;
        let mut al = self.aliases.write();
        match alias {
            Some(s) if !s.as_ref().is_empty() => { al.insert(uid, s.as_ref().to_string()); }
            _ => { al.remove(&uid); }
        }
        Ok(())
    }

    /// 获取某成员别名
    #[inline]
    pub fn get_alias(&self, user_id: UserId) -> Result<Option<String>, MemberListError> {
        let uid = Self::to_u64(user_id)?;
        Ok(self.aliases.read().get(&uid).cloned())
    }

    #[inline]
    pub fn len(&self) -> usize { self.members.read().len() as usize }

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

    /// 分页导出（按 RB64 的有序迭代，稳定分页）
    pub fn get_page(&self, page: usize, page_size: usize) -> Vec<MemberRef> {
        if page_size == 0 { return Vec::new(); }
        let m = self.members.read();
        let total = m.len() as usize;
        let start = page.saturating_mul(page_size);
        if start >= total { return Vec::new(); }

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
    pub fn contains(&self, user_id: UserId) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(user_id)?;
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
