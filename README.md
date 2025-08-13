
# Rust Services (Actix-web, using your attached structures)

This workspace integrates your **HashShardMap + MemberListWrapper + SimpleMemberList + ShardedMemberList** into `group-service`.

## Build & Run
```bash
cargo build --release

# online (8081)
(cd online-service && cargo run)

# group (8082) - now using your data structures
GROUP_SHARDS=64 (cd group-service && cargo run)

# friend (8083)
ONLINE_BASE_URL=http://127.0.0.1:8081 (cd friend-service && cargo run)
```
