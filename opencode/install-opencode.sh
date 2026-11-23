#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BOLD='' RESET='' CYAN='' GREEN='' YELLOW='' RED=''
if [[ -t 1 && "${TERM:-dumb}" != dumb && -z "${NO_COLOR+x}" ]]; then
  BOLD=$'\033[1m' RESET=$'\033[0m' CYAN=$'\033[36m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RED=$'\033[31m'
fi
status() { local c=''; case "$1" in RUN) c="$CYAN";; OK|LINKED) c="$GREEN";; BACKUP|NOTICE) c="$YELLOW";; ERROR) c="$RED";; esac; printf '  %s%-7s%s %s\n' "$c" "$1" "$RESET" "$2"; }

printf '\n%sOpenCode / Workflow installation%s\n' "$BOLD" "$RESET"
printf '  Destination: %s\n' "$DEST_DIR"

command -v opencode >/dev/null 2>&1 || { status ERROR 'opencode CLI not found on PATH.' >&2; exit 1; }
for item in AGENTS.md agents commands opencode.jsonc README.md; do
  [[ -e "$SRC_DIR/$item" ]] || { status ERROR "Missing $SRC_DIR/$item" >&2; exit 1; }
done
mkdir -p "$DEST_DIR"
status OK "opencode $(opencode --version 2>/dev/null || echo 'unknown')"

# Symlink shared content from the omp directory (single source of truth).
mkdir -p "$SRC_DIR/skills" "$SRC_DIR/templates"
[[ -e "$SRC_DIR/skills/caveman" ]] || ln -s "$SRC_DIR/../omp/skills/caveman" "$SRC_DIR/skills/caveman"
[[ -e "$SRC_DIR/skills/hallmark" ]] || ln -s "$SRC_DIR/../omp/skills/hallmark" "$SRC_DIR/skills/hallmark"
[[ -e "$SRC_DIR/skills/security-audit" ]] || ln -s "$SRC_DIR/../omp/skills/security-audit" "$SRC_DIR/skills/security-audit"
for t in PRD.md TECH-DOC.md HUMAN-TASK-BREAKDOWN.md TEST-PLAN.md; do
  [[ -e "$SRC_DIR/templates/$t" ]] || ln -s "$SRC_DIR/../omp/templates/$t" "$SRC_DIR/templates/$t"
done
for s in caveman hallmark security-audit; do
  [[ -d "$SRC_DIR/skills/$s" ]] || { status ERROR "Missing bundled skill $s; run next to omp/." >&2; exit 1; }
done

link() {
  local name="$1" target="$SRC_DIR/$2"
  [[ -e "$DEST_DIR/$name" && ! -L "$DEST_DIR/$name" ]] && {
    mv "$DEST_DIR/$name" "$DEST_DIR/$name.backup.$STAMP"
    status BACKUP "$name → $name.backup.$STAMP"
  }
  ln -sfn "$target" "$DEST_DIR/$name"
  status LINKED "$name → $target"
}
for item in AGENTS.md agents commands skills templates opencode.jsonc; do
  link "$item" "$item"
done

if command -v openspec >/dev/null 2>&1; then
  status READY "openspec $(openspec --version 2>/dev/null || echo 'present')"
else
  status NOTICE 'openspec CLI missing; install @fission-ai/openspec for /work-spec, /work-build and /work-ship.'
fi
command -v rtk >/dev/null 2>&1 && status READY 'rtk present; shell output will be compressed' \
  || status NOTICE 'rtk not installed; commands fall back to plain shell output.'
command -v playwright-mcp >/dev/null 2>&1 || status NOTICE 'playwright MCP launches via npx on first use.'

printf '\n%sReady%s — start a new OpenCode session, then use /work-spec, /work-build, /work-ship.\n' "$BOLD" "$RESET"
