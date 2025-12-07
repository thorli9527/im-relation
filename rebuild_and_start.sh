#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

echo "Compiling Rust workspace (release build)..."
cargo build --workspace --release

services=(
  user_service
  friend_service
  group_service
  # msg_friend
  msg_group
  msg_system
  app_socket
  app_api
)

mkdir -p logs

for svc in "${services[@]}"; do
  bin="$ROOT/target/release/$svc"
  if [[ ! -x "$bin" ]]; then
    echo "Binary not found: $bin" >&2
    exit 1
  fi

  if pgrep -f "$bin" >/dev/null 2>&1; then
    echo "Stopping existing $svc instance..."
    pkill -f "$bin" || true
    sleep 1
  fi

  echo "Starting $svc..."
  nohup "$bin" >"logs/${svc}.log" 2>&1 &
done

echo "All services started. Logs available under logs/."
