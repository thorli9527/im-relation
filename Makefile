.PHONY: help build release clean fmt clippy \
        run-online run-group run-friend run-api run-arb run-socket run-main

GROUP_SHARDS ?= 64
ONLINE_BASE_URL ?= http://127.0.0.1:8081

help:
	@echo "Available targets:"
	@echo "  build           - cargo build (workspace)"
	@echo "  release         - cargo build --release (workspace)"
	@echo "  clean           - cargo clean"
	@echo "  fmt             - cargo fmt --all"
	@echo "  clippy          - cargo clippy --all-targets --all-features -D warnings"
	@echo "  run-online      - run hot_online_service"
	@echo "  run-group       - run hot_group_service (GROUP_SHARDS=$(GROUP_SHARDS))"
	@echo "  run-friend      - run hot_friend_service (ONLINE_BASE_URL=$(ONLINE_BASE_URL))"
	@echo "  run-api         - run app_api"
	@echo "  run-arb         - run arb-service"
	@echo "  run-socket      - run app_socket"
	@echo "  run-main        - run app_main"

build:
	cargo build --workspace

release:
	cargo build --workspace --release

clean:
	cargo clean

fmt:
	cargo fmt --all

clippy:
	cargo clippy --all-targets --all-features -D warnings

run-online:
	APP_CONFIG=$(APP_CONFIG) cargo run -p hot_online_service

run-group:
	APP_CONFIG=$(APP_CONFIG) GROUP_SHARDS=$(GROUP_SHARDS) cargo run -p hot_group_service

run-friend:
	APP_CONFIG=$(APP_CONFIG) ONLINE_BASE_URL=$(ONLINE_BASE_URL) cargo run -p hot_friend_service

run-api:
	APP_CONFIG=$(APP_CONFIG) cargo run -p app_api

run-arb:
	APP_CONFIG=$(APP_CONFIG) cargo run -p arb-service

run-socket:
	cargo run -p app_socket

run-main:
	cargo run -p app_main
