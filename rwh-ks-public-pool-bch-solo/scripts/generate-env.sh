#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# APP_SEED for Umbrel; Local dev can export
: "${APP_SEED:?APP_SEED is required}"

RPC_USER="bchnrpc"
RPC_PASS="$(echo -n "${APP_SEED}-bchn-rpc" | sha256sum | awk '{print $1}')"
RPC_BASIC="$(printf '%s:%s' "$RPC_USER" "$RPC_PASS" | base64 -w0)"

# Prune/db
cat > "${APP_DIR}/.env" <<ENVEOF
# Paths
APP_DATA_DIR=/data

# BCHN
APP_BCHN_PRUNE_MIB=20480
APP_BCHN_RPC_USER=${RPC_USER}
APP_BCHN_RPC_PASSWORD=${RPC_PASS}
APP_BCHN_RPC_BASIC=${RPC_BASIC}

# MariaDB
APP_MARIADB_DATABASE=publicpool
APP_MARIADB_USER=bchuser
APP_MARIADB_PASSWORD=$(echo -n "${APP_SEED}-mariadb-user" | sha256sum | awk '{print $1}')
APP_MARIADB_ROOT_PASSWORD=$(echo -n "${APP_SEED}-mariadb-root" | sha256sum | awk '{print $1}')
ENVEOF

chmod 640 "${APP_DIR}/.env" || true
