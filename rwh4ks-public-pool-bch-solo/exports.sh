#!/usr/bin/env bash
set -euo pipefail

# Default-safe exposed ports (can be overridden by advanced users)
export APP_PUBLIC_POOL_STRATUM_PORT="${APP_PUBLIC_POOL_STRATUM_PORT:-3563}"
export APP_PUBLIC_POOL_API_PORT="${APP_PUBLIC_POOL_API_PORT:-3564}"

# BCHN prune target (MiB)
export APP_BCHN_PRUNE_MIB="${APP_BCHN_PRUNE_MIB:-5500}"

# Database credentials (deterministic per Umbrel install)
export APP_MARIADB_DATABASE="yiimp"
export APP_MARIADB_USER="yiimp"
export APP_MARIADB_PASSWORD="$(echo -n "${APP_SEED}-mariadb" | sha256sum | awk '{print $1}')"
export APP_MARIADB_ROOT_PASSWORD="$(echo -n "${APP_SEED}-mariadb-root" | sha256sum | awk '{print $1}')"

# BCHN RPC credentials (internal only)
export APP_BCHN_RPC_USER="bchnrpc"
export APP_BCHN_RPC_PASSWORD="$(echo -n "${APP_SEED}-bchn-rpc" | sha256sum | awk '{print $1}')"
