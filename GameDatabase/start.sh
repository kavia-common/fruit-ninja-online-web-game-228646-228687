#!/usr/bin/env bash
set -euo pipefail

# Minimal startup script for the GameDatabase MongoDB container.
#
# - Ensures required directories exist
# - Starts mongod on the configured port
# - Idempotent: exits 0 if MongoDB is already running (PID file or port already in use)

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
PIDFILE="${MONGODB_PIDFILE:-${SCRIPT_DIR}/mongod.pid}"

mkdir -p "${DBPATH}"

# If a previous mongod is already running (PID file exists and PID is alive), do not fail.
if [[ -f "${PIDFILE}" ]]; then
  EXISTING_PID="$(cat "${PIDFILE}" || true)"
  if [[ -n "${EXISTING_PID}" ]] && kill -0 "${EXISTING_PID}" 2>/dev/null; then
    echo "mongod already running (pid=${EXISTING_PID}); leaving it running."
    exit 0
  fi
fi

# If the port is already in use, assume mongod is already running (common in dev/CI).
# We intentionally do not try to kill processes here.
if command -v ss >/dev/null 2>&1; then
  if ss -ltn "( sport = :${PORT} )" 2>/dev/null | tail -n +2 | grep -q ":${PORT}"; then
    echo "port ${PORT} already in use; assuming MongoDB is already running."
    exit 0
  fi
fi

# Start MongoDB. In container-like usage, running with --fork is often required by orchestrators
# expecting the startup script to return; however, we keep the prior behavior (foreground) unless
# FORK is explicitly enabled.
FORK="${MONGODB_FORK:-}"
if [[ "${FORK}" == "1" || "${FORK}" == "true" ]]; then
  exec mongod \
    --port "${PORT}" \
    --bind_ip 0.0.0.0 \
    --dbpath "${DBPATH}" \
    --logpath "${LOGPATH}" \
    --pidfilepath "${PIDFILE}" \
    --fork
fi

exec mongod \
  --port "${PORT}" \
  --bind_ip 0.0.0.0 \
  --dbpath "${DBPATH}" \
  --logpath "${LOGPATH}" \
  --pidfilepath "${PIDFILE}"
