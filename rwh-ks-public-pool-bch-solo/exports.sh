#!/usr/bin/env bash
set -euo pipefail

# Umbrel sets APP_SEED + APP_DATA_DIR at install/runtime.
# Derive per-install secrets from APP_SEED

export APP_BCHN_PRUNE_MIB="${APP_BCHN_PRUNE_MIB:-20480}"

export APP_BCHN_RPC_USER="bchnrpc"
export APP_BCHN_RPC_PASSWORD="$(printf "%s" "${APP_SEED}-bchn-rpc" | sha256sum | awk '{print $1}')"

export APP_MARIADB_DATABASE="publicpool"
export APP_MARIADB_USER="bchuser"
export APP_MARIADB_PASSWORD="$(printf "%s" "${APP_SEED}-mariadb-user" | sha256sum | awk '{print $1}')"
export APP_MARIADB_ROOT_PASSWORD="$(printf "%s" "${APP_SEED}-mariadb-root" | sha256sum | awk '{print $1}')"

# Base64 for nginx Authorization header (Basic user:pass)
export BCH_RPC_BASIC="$(printf "%s:%s" "$APP_BCHN_RPC_USER" "$APP_BCHN_RPC_PASSWORD" | base64 | tr -d '\n')"
