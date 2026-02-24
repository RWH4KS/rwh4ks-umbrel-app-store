#!/usr/bin/env bash
set -euo pipefail

# App directory
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Umbrel should set these
: "${APP_SEED:?APP_SEED is required (Umbrel should set this)}"
export APP_DATA_DIR="${APP_DATA_DIR:-$APP_DIR}"

# Umbrel sets APP_SEED + APP_DATA_DIR at install/runtime.
# Derive per-install secrets from APP_SEED
: "${APP_DATA_DIR:?APP_DATA_DIR is not set (Umbrel should set this)}"

SEED_FILE="${APP_DATA_DIR}/app_seed"

# Prefer Umbrel-provided APP_SEED
if [[ -n "${APP_SEED:-}" ]]; then
  # If Umbrel provides it, optionally persist it so reinstalls behave consistently.
  mkdir -p "${APP_DATA_DIR}"
  if [[ ! -f "${SEED_FILE}" ]]; then
    printf "%s" "${APP_SEED}" > "${SEED_FILE}"
    chmod 600 "${SEED_FILE}" || true
  fi
else
  mkdir -p "${APP_DATA_DIR}"

  if [[ -f "${SEED_FILE}" ]]; then
    APP_SEED="$(cat "${SEED_FILE}")"
  else
    # Generate a strong random seed (hex)
    APP_SEED="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"
    printf "%s" "${APP_SEED}" > "${SEED_FILE}"
    chmod 600 "${SEED_FILE}" || true
  fi

  export APP_SEED
fi

export APP_BCHN_PRUNE_MIB="${APP_BCHN_PRUNE_MIB:-20480}"

export APP_BCHN_RPC_USER="bchnrpc"
export APP_BCHN_RPC_PASSWORD="$(printf "%s" "${APP_SEED}-bchn-rpc" | sha256sum | awk '{print $1}')"

export APP_MARIADB_DATABASE="publicpool"
export APP_MARIADB_USER="bchuser"
export APP_MARIADB_PASSWORD="$(printf "%s" "${APP_SEED}-mariadb-user" | sha256sum | awk '{print $1}')"
export APP_MARIADB_ROOT_PASSWORD="$(printf "%s" "${APP_SEED}-mariadb-root" | sha256sum | awk '{print $1}')"

# Base64 for nginx Authorization header (Basic user:pass)
export BCH_RPC_BASIC="$(printf "%s:%s" "$APP_BCHN_RPC_USER" "$APP_BCHN_RPC_PASSWORD" | base64 | tr -d '\n')"
