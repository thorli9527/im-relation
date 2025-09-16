#!/usr/bin/env bash
set -euo pipefail

# Proto codegen helper for Rust crates in this workspace.
# - Triggers build.rs in each crate to regenerate Rust code from .proto files.
# - Useful after editing any proto under */proto or common/proto.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

echo "==> Generating Rust protobuf code via cargo builds"
echo "    Workspace: $ROOT_DIR"

CRATES=(
  common
  hot_group_service
  hot_friend_service
  hot_online_service
  arb-service
  app_socket
)

for crate in "${CRATES[@]}"; do
  if [ -f "$crate/Cargo.toml" ]; then
    echo "-- building $crate (runs $crate/build.rs if present)"
    cargo build -q -p "$crate"
  else
    echo "-- skip $crate (no Cargo.toml)"
  fi
done

echo "==> Done. Generated files (if any) are written to each crate's configured out_dir."

