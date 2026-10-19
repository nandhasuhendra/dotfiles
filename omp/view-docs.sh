#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-start}"
ROOT="${2:-}"
HOST="${3:-0.0.0.0}"
PORT="${4:-8765}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omp/view-$PORT"
PID_FILE="$STATE_DIR/server.pid"
LOG_FILE="$STATE_DIR/server.log"

usage() {
  printf 'Usage: %s [start|stop|status] [docs-dir] [host] [port]\n' "${0##*/}" >&2
}

running() {
  [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

case "$ACTION" in
  start)
    [[ -n "$ROOT" ]] || ROOT="$PWD/openspec/changes"
    [[ -d "$ROOT" ]] || { printf 'Not a directory: %s\n' "$ROOT" >&2; exit 1; }
    if running; then
      printf 'Already running (pid %s).\n' "$(cat "$PID_FILE")"
      grep -E 'Local:|Phone:' "$LOG_FILE" || true
      exit 0
    fi
    mkdir -p "$STATE_DIR"
    : > "$LOG_FILE"
    nohup python3 "$SCRIPT_DIR/serve-docs.py" "$ROOT" --host "$HOST" --port "$PORT" \
      >"$LOG_FILE" 2>&1 &
    printf '%s\n' "$!" > "$PID_FILE"
    for _ in $(seq 1 50); do
      running || break
      if curl -fsS --max-time 1 "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
        break
      fi
      sleep 0.1
    done
    if ! running || grep -q 'Address already in use' "$LOG_FILE"; then
      printf 'Viewer failed to start. Log: %s\n' "$LOG_FILE" >&2
      cat "$LOG_FILE" >&2
      exit 1
    fi
    cat "$LOG_FILE"
    ;;
  stop)
    if running; then
      kill "$(cat "$PID_FILE")"
      rm -f "$PID_FILE"
      printf 'Viewer stopped.\n'
    else
      rm -f "$PID_FILE"
      printf 'No viewer running on port %s.\n' "$PORT"
    fi
    ;;
  status)
    if running; then
      printf 'Running (pid %s).\n' "$(cat "$PID_FILE")"
      grep -E 'Local:|Phone:' "$LOG_FILE" || true
    else
      printf 'No viewer running on port %s.\n' "$PORT"
    fi
    ;;
  *)
    usage
    exit 1
    ;;
esac
