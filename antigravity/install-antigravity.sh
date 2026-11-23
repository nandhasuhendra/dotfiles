#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${ANTIGRAVITY_CONFIG_DIR:-$HOME/.gemini/config}"
DRY_RUN=0
[[ "${1:-}" != "--dry-run" ]] || DRY_RUN=1
[[ $# -le 1 ]] || { echo "Usage: $0 [--dry-run]" >&2; exit 2; }

command -v python3 >/dev/null 2>&1 || { echo "Missing required tool: python3" >&2; exit 1; }
command -v agy >/dev/null 2>&1 || { echo "Antigravity CLI (agy) not found. Install and authenticate it first." >&2; exit 1; }
for path in "$SOURCE_DIR/AGENTS.md" "$SOURCE_DIR/mcp_config.json" "$SOURCE_DIR/skills" "$SOURCE_DIR/agents" "$SOURCE_DIR/templates" "$SOURCE_DIR/skills/security-audit"; do
  [[ -e "$path" ]] || { echo "Missing source: $path" >&2; exit 1; }
done
python3 -m json.tool "$SOURCE_DIR/mcp_config.json" >/dev/null

# Fail before touching links if an existing MCP server name conflicts.
if [[ -f "$CONFIG_DIR/mcp_config.json" ]]; then
  python3 - "$SOURCE_DIR/mcp_config.json" "$CONFIG_DIR/mcp_config.json" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f: incoming=json.load(f)
with open(sys.argv[2], encoding="utf-8") as f: current=json.load(f)
for name, config in incoming.get("mcpServers", {}).items():
    if name in current.get("mcpServers", {}) and current["mcpServers"][name] != config:
        raise SystemExit(f"MCP server name conflict: {name}. Resolve it manually in {sys.argv[2]}; no changes made.")
PY
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
if (( DRY_RUN == 0 )); then mkdir -p "$CONFIG_DIR" "$CONFIG_DIR/skills" "$CONFIG_DIR/agents"; fi
backup_and_link() {
  local source="$1" destination="$2" backup
  if [[ -L "$destination" && "$(readlink "$destination")" == "$source" ]]; then
    echo "OK      $destination (already linked)"
    return
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    backup="$destination.backup.$STAMP"
    local n=1
    while [[ -e "$backup" || -L "$backup" ]]; do backup="$destination.backup.$STAMP.$n"; n=$((n+1)); done
    if (( DRY_RUN )); then echo "BACKUP  $destination -> $backup"; else mv "$destination" "$backup"; fi
  fi
  if (( DRY_RUN )); then echo "LINK    $destination -> $source"; else ln -s "$source" "$destination"; fi
}

echo "Antigravity workflow installer"
echo "Source: $SOURCE_DIR"
echo "Target: $CONFIG_DIR"
(( DRY_RUN == 0 )) || echo "DRY RUN — no files will be changed"

backup_and_link "$SOURCE_DIR/AGENTS.md" "$CONFIG_DIR/AGENTS.md"
backup_and_link "$SOURCE_DIR/templates" "$CONFIG_DIR/templates"
for skill_dir in "$SOURCE_DIR"/skills/*; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  [[ "$name" == "security-audit" ]] && continue
  [[ -f "$skill_dir/SKILL.md" ]] || { echo "Invalid skill: $skill_dir (missing SKILL.md)" >&2; exit 1; }
  backup_and_link "$skill_dir" "$CONFIG_DIR/skills/$name"
done
backup_and_link "$SOURCE_DIR/skills/security-audit" "$CONFIG_DIR/skills/security-audit"
for agent_file in "$SOURCE_DIR"/agents/*.md; do
  [[ -f "$agent_file" ]] || continue
  backup_and_link "$agent_file" "$CONFIG_DIR/agents/$(basename "$agent_file")"
done

MCP_DEST="$CONFIG_DIR/mcp_config.json"
if (( DRY_RUN )); then
  echo "MERGE   $SOURCE_DIR/mcp_config.json -> $MCP_DEST (preserve existing servers; fail on name conflicts)"
else
  python3 - "$SOURCE_DIR/mcp_config.json" "$MCP_DEST" "$STAMP" <<'PY'
import json, os, shutil, sys, tempfile
source, destination, stamp = sys.argv[1:]
with open(source, encoding="utf-8") as f: incoming=json.load(f)
existed=os.path.exists(destination)
if existed:
    with open(destination, encoding="utf-8") as f: current=json.load(f)
    merged=current.copy()
    servers=merged.setdefault("mcpServers", {}).copy()
    servers.update(incoming.get("mcpServers", {}))
    merged["mcpServers"]=servers
else:
    current=None
    merged=incoming
if existed and merged == current:
    print("OK      MCP configuration already current")
    raise SystemExit(0)
os.makedirs(os.path.dirname(destination), exist_ok=True)
fd, temporary=tempfile.mkstemp(prefix=".mcp_config.", dir=os.path.dirname(destination))
try:
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=2); f.write("\n")
    if existed:
        backup=destination+".backup."+stamp
        shutil.copy2(destination, backup); print("BACKUP ", backup)
    os.replace(temporary, destination)
except Exception:
    try: os.unlink(temporary)
    except FileNotFoundError: pass
    raise
PY
  python3 -m json.tool "$MCP_DEST" >/dev/null
  echo "MERGED  $MCP_DEST"
fi

echo
echo "Install complete. Start a NEW Antigravity CLI session, then run /skills, /agents, and /mcp."
echo "The standalone security-audit skill is bundled under antigravity/skills/security-audit."
echo "No credentials were written. MCP servers may need first-run downloads/authentication."
