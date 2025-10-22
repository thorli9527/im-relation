#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DART_BIN="${FLUTTER_HOME:-$HOME/tools/flutter}/bin/cache/dart-sdk/bin/dart"

if [[ ! -x "${DART_BIN}" ]]; then
  echo "Dart binary not found at ${DART_BIN}" >&2
  exit 1
fi

SNAPSHOT="${PROJECT_ROOT}/.dart_tool/pub/bin/protoc_plugin/protoc_plugin.dart-3.9.2.snapshot"

if [[ ! -f "${SNAPSHOT}" ]]; then
  echo "protoc plugin snapshot not found: ${SNAPSHOT}" >&2
  exit 1
fi

exec "${DART_BIN}" "${SNAPSHOT}" "$@"
