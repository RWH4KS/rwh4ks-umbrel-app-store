#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DATA_DIR="${APP_DATA_DIR:-$APP_DIR}"

DATA_DIR="${APP_DATA_DIR}/data"
SEED_FILE="${APP_DATA_DIR}/app_seed"

mkdir -p "${DATA_DIR}"
chown -R umbrel:umbrel "${DATA_DIR}" 2>/dev/null || true
chmod -R u+rwX,go-rwx "${DATA_DIR}" 2>/dev/null || true

if [[ -f "${SEED_FILE}" && ! -r "${SEED_FILE}" ]]; then
  echo "ERROR: ${SEED_FILE} exists but is not readable. Fix ownership/permissions." >&2
  exit 1
fi

# ---- Seed (stable per-install) ----
if [[ -n "${APP_SEED:-}" ]]; then
  SEED="${APP_SEED}"
  if [[ ! -f "${SEED_FILE}" ]]; then
    printf "%s" "${SEED}" > "${SEED_FILE}"
    chmod 600 "${SEED_FILE}" || true
  fi
else
  if [[ -f "${SEED_FILE}" ]]; then
    SEED="$(cat "${SEED_FILE}")"
  else
    SEED="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"
    printf "%s" "${SEED}" > "${SEED_FILE}"
    chmod 600 "${SEED_FILE}" || true
  fi
fi

# ---- Derived config ----
APP_UI_PORT="${APP_UI_PORT:-8080}"
APP_BCHN_PRUNE_MIB="${APP_BCHN_PRUNE_MIB:-20480}"

APP_BCHN_RPC_USER="bchnrpc"
APP_BCHN_RPC_PASSWORD="$(printf "%s" "${SEED}-bchn-rpc" | sha256sum | awk '{print $1}')"

APP_MARIADB_DATABASE="publicpool"
APP_MARIADB_USER="bchuser"
APP_MARIADB_PASSWORD="$(printf "%s" "${SEED}-mariadb-user" | sha256sum | awk '{print $1}')"
APP_MARIADB_ROOT_PASSWORD="$(printf "%s" "${SEED}-mariadb-root" | sha256sum | awk '{print $1}')"

BCH_RPC_BASIC="$(printf "%s:%s" "$APP_BCHN_RPC_USER" "$APP_BCHN_RPC_PASSWORD" | base64 | tr -d '\n')"

# ---- Pull Umbrel auth values from Umbrel's running manager/auth container, if present ----
# Allow user to override by exporting MANAGER_IP / UMBREL_AUTH_SECRET before running script.
MANAGER_IP="${MANAGER_IP:-}"
UMBREL_AUTH_SECRET="${UMBREL_AUTH_SECRET:-}"
JWT_SECRET="${JWT_SECRET:-}"

if command -v docker >/dev/null 2>&1; then
  if [[ -z "${MANAGER_IP}" || -z "${UMBREL_AUTH_SECRET}" || -z "${JWT_SECRET}" ]]; then
    MANAGER_CTN="$(
      docker ps --format '{{.Names}} {{.Ports}}' | awk '/:2000->2000\/tcp/ {print $1; exit}'
    )"

    if [[ -z "${MANAGER_CTN}" ]]; then
      if docker ps --format '{{.Names}}' | grep -qx 'auth'; then
        MANAGER_CTN='auth'
      else
        MANAGER_CTN=''
      fi
    fi

    if [[ -n "${MANAGER_CTN}" ]]; then
      if [[ -z "${MANAGER_IP}" ]]; then
        MANAGER_IP="$(
          docker inspect "${MANAGER_CTN}" --format '{{range .Config.Env}}{{println .}}{{end}}' \
          | awk -F= '/^MANAGER_IP=/{print $2; exit}' || true
        )"
      fi

      if [[ -z "${UMBREL_AUTH_SECRET}" ]]; then
        UMBREL_AUTH_SECRET="$(
          docker inspect "${MANAGER_CTN}" --format '{{range .Config.Env}}{{println .}}{{end}}' \
          | awk -F= '/^UMBREL_AUTH_SECRET=/{print $2; exit}' || true
        )"
      fi

      if [[ -z "${JWT_SECRET}" ]]; then
        JWT_SECRET="$(
          docker exec "${MANAGER_CTN}" sh -lc 'printenv | awk -F= "/^JWT_SECRET=/{print \$2; exit}"' 2>/dev/null || true
        )"
      fi
    fi
  fi
fi

# Last resort: MANAGER_IP from default gateway
if [[ -z "${MANAGER_IP}" ]]; then
  MANAGER_IP="$(ip route | awk '/default/ {print $3; exit}' || true)"
fi

# Hard fail if Umbrel auth secrets are missing
if [[ -z "${UMBREL_AUTH_SECRET}" || -z "${JWT_SECRET}" ]]; then
  echo "ERROR: Could not determine Umbrel auth secrets on this system." >&2
  exit 1
fi

cat > "${APP_DIR}/.env" <<EOF
APP_DATA_DIR=${APP_DATA_DIR}
APP_UI_PORT=${APP_UI_PORT}
APP_BCHN_PRUNE_MIB=${APP_BCHN_PRUNE_MIB}
APP_BCHN_RPC_USER=${APP_BCHN_RPC_USER}
APP_BCHN_RPC_PASSWORD=${APP_BCHN_RPC_PASSWORD}
APP_MARIADB_DATABASE=${APP_MARIADB_DATABASE}
APP_MARIADB_USER=${APP_MARIADB_USER}
APP_MARIADB_PASSWORD=${APP_MARIADB_PASSWORD}
APP_MARIADB_ROOT_PASSWORD=${APP_MARIADB_ROOT_PASSWORD}
BCH_RPC_BASIC=${BCH_RPC_BASIC}
MANAGER_IP=${MANAGER_IP}
UMBREL_AUTH_SECRET=${UMBREL_AUTH_SECRET}
JWT_SECRET=${JWT_SECRET}
EOF

chmod 600 "${APP_DIR}/.env" || true

echo "Wrote ${APP_DIR}/.env"
echo "APP_UI_PORT=${APP_UI_PORT}"
echo "MANAGER_IP=${MANAGER_IP:-<empty>}"
echo "UMBREL_AUTH_SECRET=${UMBREL_AUTH_SECRET:-<empty>}"
echo "JWT_SECRET=${JWT_SECRET:-<empty>}"
