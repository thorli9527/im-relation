use parking_lot::RwLock;
use roaring::RoaringTreemap as RB64;
use common::{MemberListError, UserId};
use crate::grpc::group_service::{GroupRoleType, MemberRef};

#[derive(Debug)]
pub struct MemberListWrapper {
    members: RwLock<RB64>,
    owners:  RwLock<RB64>,
    admins:  RwLock<RB64>,
}

impl Default for MemberListWrapper {
    fn default() -> Self { Self::new_simple() }
}

impl MemberListWrapper {
    pub fn new_simple() -> Self {
        Self { members: RwLock::new(RB64::new()),
               owners:  RwLock::new(RB64::new()),
               admins:  RwLock::new(RB64::new()) }
    }

    #[inline]
    fn to_u64(id: UserId) -> Result<u64, MemberListError> { Ok(id as u64) }

    #[inline]
    fn role_to_i32(role: GroupRoleType) -> i32 { role as i32 }

    #[inline]
    fn role_from_i32(v: i32) -> GroupRoleType { GroupRoleType::from_i32(v).unwrap_or(GroupRoleType::Member) }

    #[inline]
    fn role_of(owners: &RB64, admins: &RB64, uid: u64) -> GroupRoleType {
        if owners.contains(uid) { GroupRoleType::Owner }
        else if admins.contains(uid) { GroupRoleType::Admin }
        else { GroupRoleType::Member }
    }

    pub fn add(&self, member: MemberRef) -> Result<(), MemberListError> {
        let uid = Self::to_u64(member.id)?;
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();

        m.insert(uid);
        match Self::role_from_i32(member.role) {
            GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
            GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
            _ => { o.remove(uid); a.remove(uid); }
        }
        Ok(())
    }

    pub fn add_many_slice(&self, list: &[MemberRef]) -> Result<(), MemberListError> {
        let mut m = self.members.write();
        let mut o = self.owners.write();
        let mut a = self.admins.write();

        for member in list {
            let uid = Self::to_u64(member.id)?;
            m.insert(uid);
            match Self::role_from_i32(member.role) {
                GroupRoleType::Owner => { o.insert(uid); a.remove(uid); }
                GroupRoleType::Admin => { a.insert(uid); o.remove(uid); }
                _ => { o.remove(uid); a.remove(uid); }
            }
        }
        Ok(())
    }

    pub fn add_many(&self, list: Vec<MemberRef>) -> Result<(), MemberListError> {
        self.add_many_slice(&list)
    }

    pub fn remove(&self, user_id: UserId) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(user_id)?;
        let mut m = self.members.write();
        if m.remove(uid) {
            let mut o = self.owners.write();
            let mut a = self.admins.write();
            o.remove(uid); a.remove(uid);
            Ok(true)
        } else {
            Ok(false)
        }
    }

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

    #[inline]
    pub fn len(&self) -> usize { self.members.read().len() as usize }

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

    pub fn get_page(&self, page: usize, page_size: usize) -> Vec<MemberRef> {
        if page_size == 0 { return Vec::new(); }
        let m = self.members.read();
        let total = m.len() as usize;
        let start = page.saturating_mul(page_size);
        if start >= total { return Vec::new(); }

        let o = self.owners.read();
        let a = self.admins.read();
        m.iter()
            .skip(start)
            .take(page_size)
            .map(|uid| {
                let role = Self::role_of(&o, &a, uid);
                MemberRef { id: uid as i64, role: Self::role_to_i32(role) }
            })
            .collect()
    }

    #[inline]
    pub fn contains(&self, user_id: UserId) -> Result<bool, MemberListError> {
        let uid = Self::to_u64(user_id)?;
        Ok(self.members.read().contains(uid))
    }
}
