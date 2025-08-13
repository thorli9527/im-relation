// src/db/member_list_wrapper.rs
// 取消在线状态维护版：仅成员集合 + 角色集合（owners / admins）

use parking_lot::RwLock;
use roaring::RoaringTreemap as RB64;
use serde::de::Unexpected::Option;
use common::{ MemberListError,  UserId};
use crate::grpc::group_service::{GroupRoleType, MemberRef};
// 你的项目里 UserId = i64（Snowflake）

#[derive(Debug)]
pub struct MemberListWrapper {
    // 成员全集（升序去重，快速 len/contains/迭代）
    members: RwLock<RB64>,
    // 角色集合：拥有者、管理员（普通成员不在这两个集合里）
    owners:  RwLock<RB64>,
    admins:  RwLock<RB64>,
}

impl Default for MemberListWrapper {
    fn default() -> Self { Self::new_simple() }
}

impl MemberListWrapper {
    /// 创建空群成员容器
    pub fn new_simple() -> Self {
        Self {
            members: RwLock::new(RB64::new()),
            owners:  RwLock::new(RB64::new()),
            admins:  RwLock::new(RB64::new()),
        }
    }

    #[inline]
    fn to_u64(id: UserId) -> Result<u64, MemberListError> {
        Ok(id as u64)
    }

    #[inline]
    fn role_to_i32(role: GroupRoleType) -> i32 { role as i32 }

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

    /// 添加单个成员（若已存在则幂等更新角色）
    pub fn add(&self, member: MemberRef) -> Result<(), MemberListError> {
        let uid = Self::to_u64(member.id)?;
        // 固定加锁顺序，避免多写并发下的潜在死锁
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();

        m.insert(uid); // 成员全集

        // 更新角色集合
        match GroupRoleType::try_from(member.role).expect("map role error") {
            GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
            GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
            _ => { o.remove(uid); a.remove(uid); } // 普通成员
        }
        Ok(())
    }

    /// 批量添加（幂等）
    pub fn add_many(&self, list: Vec<MemberRef>) -> Result<(), MemberListError> {
        // 批量场景减少锁次数：一次持有写锁
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();

        for member in list {
            let uid = Self::to_u64(member.id)?;
            m.insert(uid);
            match GroupRoleType::try_from(member.role).expect("map role error") {
                GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
                GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
                _ => { o.remove(uid); a.remove(uid); }
            }
        }
        Ok(())
    }

    /// 移除成员。返回是否确实删除了
    pub fn remove(&self, user_id: UserId) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(user_id)?;
        let mut m = self.members.write();
        if m.remove(uid) {
            // 成员移除后，清理角色集合
            let mut o = self.owners.write();
            let mut a = self.admins.write();
            o.remove(uid);
            a.remove(uid);
            Ok(true)
        } else {
            Ok(false)
        }
    }

    /// 修改成员角色（若成员不存在则会先加入成员集合）
    pub fn change_role(&self, user_id: UserId, role: GroupRoleType) -> Result<(), MemberListError> {
        let uid = Self::to_u64(user_id)?;
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();

        m.insert(uid); // 确保在成员集合
        match role {
            GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
            GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
            _ => { o.remove(uid); a.remove(uid); }
        }
        Ok(())
    }

    /// 成员总数
    pub fn len(&self) -> usize { self.members.read().len() as usize }

    /// 取全量成员（带角色）
    pub fn get_all(&self) -> Vec<MemberRef> {
        let m = self.members.read();
        let o = self.owners.read();
        let a = self.admins.read();

        let mut out = Vec::with_capacity(m.len() as usize);
        for uid in m.iter() {
            let role = Self::role_of(&o, &a, uid);
            out.push(MemberRef { id: uid as i64, role: Self::role_to_i32(role) });
        }
        out
    }

    /// 分页（升序，按成员 UID）
    pub fn get_page(&self, page: usize, page_size: usize) -> Vec<MemberRef> {
        if page_size == 0 { return Vec::new(); }
        let m = self.members.read();
        let o = self.owners.read();
        let a = self.admins.read();

        let start = page.saturating_mul(page_size);
        m.iter()
            .skip(start)
            .take(page_size)
            .map(|uid| {
                let role = Self::role_of(&o, &a, uid);
                MemberRef { id: uid as i64, role: Self::role_to_i32(role) }
            })
            .collect()
    }

    /// 是否包含某成员
    pub fn contains(&self, user_id: UserId) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(user_id)?;
        Ok(self.members.read().contains(uid))
    }
}

