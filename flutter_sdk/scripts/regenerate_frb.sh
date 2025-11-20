#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

# If the workspace provides a stub flutter executable (e.g. tmp_flutter/bin), prepend it
if [[ -d "./tmp_flutter/bin" ]]; then
  export PATH="./tmp_flutter/bin:$PATH"
fi

CONFIG="../client/app_desktop/flutter_rust_bridge.yaml"
if [[ ! -f "$CONFIG" ]]; then
  echo "cannot find FRB config at $CONFIG" >&2
  exit 1
fi

echo "regenerating frb bindings using $CONFIG"
flutter_rust_bridge_codegen generate --config-file "$CONFIG" --no-deps-check

echo "frb_generated.rs regenerated; remember to run cargo fmt and rebuild if needed."
