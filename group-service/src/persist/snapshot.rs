use std::{collections::HashMap, path::Path, fs};
use serde::{Serialize, Deserialize};
use anyhow::{Result, Context};
use tempfile::NamedTempFile;
use std::io::Write;

use bincode::config::standard;
use bincode::{encode_to_vec, decode_from_slice};
use bincode::{Encode, Decode};

use common::GroupId;
// 用“核心” MemberRef（在 db 模块里），避免 prost 类型。
use crate::db::hash_shard_map::HashShardMap;
use crate::grpc::group_service::MemberRef;

/// 轻量版成员 DTO（用于快照）
/// 不依赖 prost，派生 bincode 的 Encode/Decode
#[derive(Debug, Clone, Copy, Serialize, Deserialize, Encode, Decode)]
pub struct MemberRefSnap {
    pub id: i64,
    pub role: i32,
}

impl From<MemberRef> for MemberRefSnap {
    fn from(m: MemberRef) -> Self {
        Self { id: m.id, role: m.role }
    }
}
impl From<MemberRefSnap> for MemberRef {
    fn from(m: MemberRefSnap) -> Self {
        MemberRef { id: m.id, role: m.role }
    }
}

#[derive(Serialize, Deserialize, Debug, Encode, Decode)]
pub struct SnapshotFile {
    pub version: u32,                       // 方便将来演进
    pub shard_count: usize,                 // 恢复时用于 sanity check（不一定必须硬绑定）
    pub per_group_shard: usize,
    pub groups: HashMap<GroupId, Vec<MemberRefSnap>>, // group_id -> members（使用快照 DTO）
}

impl SnapshotFile {
    pub const CURRENT_VERSION: u32 = 1;
}

pub fn build_snapshot(h: &HashShardMap) -> SnapshotFile {
    let mut groups = HashMap::new();
    for gid in h.all_keys() {
        // 这里返回的是 CoreMemberRef
        let members = h.get_member_by_key(gid);
        // 映射为快照 DTO
        let snaps: Vec<MemberRefSnap> = members.into_iter().map(MemberRefSnap::from).collect();
        groups.insert(gid, snaps);
    }
    SnapshotFile {
        version: SnapshotFile::CURRENT_VERSION,
        shard_count: h.shard_count(),
        per_group_shard: h.per_group_shard,
        groups,
    }
}

pub fn write_snapshot_bincode<P: AsRef<Path>>(snap: &SnapshotFile, path: P) -> Result<()> {
    // bincode 2.x：encode_to_vec + config
    let bin = encode_to_vec(snap, standard()).context("serialize snapshot")?;
    let parent = path.as_ref().parent().unwrap_or_else(|| Path::new("."));
    fs::create_dir_all(parent).ok();

    let mut tmp = NamedTempFile::new_in(parent).context("tmp file")?;
    tmp.write_all(&bin)?;
    tmp.flush()?;
    tmp.as_file().sync_all()?;
    tmp.persist(path).context("persist atomic rename")?;
    Ok(())
}

pub fn read_snapshot_bincode<P: AsRef<Path>>(path: P) -> Result<SnapshotFile> {
    let data = fs::read(path)?;
    // bincode 2.x：返回 (value, bytes_read)
    let (snap, _len): (SnapshotFile, usize) =
        decode_from_slice(&data, standard()).context("deserialize snapshot")?;
    Ok(snap)
}

/// 从快照恢复到 HashShardMap（重建反向索引）
pub fn restore_from_snapshot(snap: SnapshotFile) -> HashShardMap {
    let h = HashShardMap::new(snap.shard_count.max(1), snap.per_group_shard.max(1));
    for (gid, members_snap) in snap.groups {
        // 快照 DTO -> CoreMemberRef
        let members: Vec<MemberRef> = members_snap.into_iter().map(Into::into).collect();
        let _ = h.insert_many(gid, members); // 反向索引会在此建立
    }
    h
}
