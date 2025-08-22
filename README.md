
# Rust Services (Actix-web, using your attached structures)

This workspace integrates your **HashShardMap + MemberListWrapper + SimpleMemberList + ShardedMemberList** into `group-service`.

## Build & Run
```bash
cargo build --release

# online (8081)
(cd hot_online_service && cargo run)

# group (8082) - now using your data structures
GROUP_SHARDS=64 (cd hot_group_service && cargo run)

# friend (8083)
ONLINE_BASE_URL=http://127.0.0.1:8081 (cd hot_friend_service && cargo run)
```
