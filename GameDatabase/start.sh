#!/usr/bin/env bash
set -euo pipefail

# Minimal startup script for the GameDatabase MongoDB container.
# Ensures required directories exist and starts mongod on the configured port.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Allow PORT override via environment; fallback to .env if present; final fallback to 5001
PORT="${PORT:-}"
if [[ -z "${PORT}" ]] && [[ -f "${SCRIPT_DIR}/.env" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.env"
fi
PORT="${PORT:-5001}"

DBPATH="${MONGODB_DBPATH:-${SCRIPT_DIR}/data}"
LOGPATH="${MONGODB_LOGPATH:-${SCRIPT_DIR}/mongod.log}"

mkdir -p "${DBPATH}"

# Start MongoDB in the foreground (typical container behavior). If you need background, add --fork.
exec mongod \
  --port "${PORT}" \
  --bind_ip 0.0.0.0 \
  --dbpath "${DBPATH}" \
  --logpath "${LOGPATH}"
