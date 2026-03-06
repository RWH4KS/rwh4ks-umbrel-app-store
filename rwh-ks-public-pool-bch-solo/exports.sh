#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${APP_DIR}"

export APP_DATA_DIR="${APP_DATA_DIR:-$APP_DIR}"

mkdir -p "${APP_DATA_DIR}/data"

bash "${APP_DIR}/scripts/generate-env.sh"
