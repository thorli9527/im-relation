#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
PROTO_ROOT="${ROOT_DIR}/../../common/proto"
OUT_DIR="${ROOT_DIR}/lib/proto"

if ! command -v protoc >/dev/null 2>&1; then
  echo "error: protoc not found in PATH" >&2
  exit 1
fi

if ! command -v protoc-gen-dart >/dev/null 2>&1; then
  echo "error: protoc-gen-dart not found in PATH. Install via 'dart pub global activate protoc_plugin'" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"

PROTO_FILES=$(find "${PROTO_ROOT}" -name '*.proto')

protoc \
  --plugin=protoc-gen-dart="$(command -v protoc-gen-dart)" \
  --dart_out=grpc:"${OUT_DIR}" \
  -I"${PROTO_ROOT}" \
  ${PROTO_FILES}

echo "Generated Dart protos into ${OUT_DIR}"
