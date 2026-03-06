#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${APP_DIR}"

export APP_DATA_DIR="${APP_DATA_DIR:-$APP_DIR}"
mkdir -p "${APP_DATA_DIR}/data"

SEED_FILE="${APP_DATA_DIR}/app_seed"

if [[ -n "${APP_SEED:-}" ]]; then
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

export BCH_RPC_BASIC="$(printf "%s:%s" "${APP_BCHN_RPC_USER}" "${APP_BCHN_RPC_PASSWORD}" | base64 | tr -d '\n')"

bash "${APP_DIR}/scripts/generate-env.sh"
