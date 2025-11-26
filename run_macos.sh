#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# Script now lives at repo root
REPO_ROOT="$SCRIPT_DIR"

echo "==> Building flutter_sdk (Rust) ..."
pushd "$REPO_ROOT/flutter_sdk" >/dev/null
cargo build --release
popd >/dev/null

echo "==> Running Flutter app (macOS) ..."
pushd "$REPO_ROOT/client/app_desktop" >/dev/null
flutter run -d macos "$@"
popd >/dev/null
