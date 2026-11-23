#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fixture="$TMP/repo"
mkdir -p "$fixture/antigravity/skills/work-spec" "$fixture/antigravity/skills/security-audit" "$fixture/antigravity/agents" "$fixture/antigravity/templates" "$TMP/bin" "$TMP/config"
cp "$ROOT/antigravity/install-antigravity.sh" "$fixture/antigravity/"
cp "$ROOT/antigravity/AGENTS.md" "$fixture/antigravity/"
cp "$ROOT/antigravity/mcp_config.json" "$fixture/antigravity/"
cp "$ROOT/antigravity/skills/work-spec/SKILL.md" "$fixture/antigravity/skills/work-spec/"
cp -R "$ROOT/antigravity/skills/security-audit/." "$fixture/antigravity/skills/security-audit/"
cp "$ROOT/antigravity/agents/tech-lead.md" "$fixture/antigravity/agents/"
cp "$ROOT/antigravity/templates/TEST-PLAN.md" "$fixture/antigravity/templates/"
printf '#!/usr/bin/env sh\nexit 0\n' > "$TMP/bin/agy"
chmod +x "$TMP/bin/agy"

cat > "$TMP/config/mcp_config.json" <<'JSON'
{"mcpServers":{"existing":{"command":"my-server","args":[]}}}
JSON
PATH="$TMP/bin:$PATH" ANTIGRAVITY_CONFIG_DIR="$TMP/config" bash "$fixture/antigravity/install-antigravity.sh" >/dev/null

[[ -L "$TMP/config/AGENTS.md" ]]
[[ -L "$TMP/config/templates" ]]
[[ -f "$TMP/config/templates/TEST-PLAN.md" ]]
[[ -L "$TMP/config/skills/work-spec" ]]
[[ -L "$TMP/config/skills/security-audit" ]]
[[ "$(readlink -f "$TMP/config/skills/security-audit")" == "$fixture/antigravity/skills/security-audit" ]]
[[ -f "$TMP/config/skills/security-audit/validate-findings.cjs" ]]
[[ ! -e "$fixture/omp" ]]
[[ -L "$TMP/config/agents/tech-lead.md" ]]
python3 - "$TMP/config/mcp_config.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1]))
assert set(data["mcpServers"]) == {"existing","context7","playwright"}
PY

before="$(find "$TMP/config" -name '*.backup.*' | wc -l)"
PATH="$TMP/bin:$PATH" ANTIGRAVITY_CONFIG_DIR="$TMP/config" bash "$fixture/antigravity/install-antigravity.sh" >/dev/null
after="$(find "$TMP/config" -name '*.backup.*' | wc -l)"
[[ "$before" == "$after" ]]

# Conflicting server names must fail before any customization link is changed.
conflict="$TMP/conflict"
mkdir -p "$conflict"
printf '{"mcpServers":{"context7":{"command":"different"}}}\n' > "$conflict/mcp_config.json"
if PATH="$TMP/bin:$PATH" ANTIGRAVITY_CONFIG_DIR="$conflict" bash "$fixture/antigravity/install-antigravity.sh" >/dev/null 2>&1; then
  echo "Expected MCP conflict to fail" >&2; exit 1
fi
[[ ! -e "$conflict/AGENTS.md" && ! -L "$conflict/AGENTS.md" ]]

echo "PASS: standalone install without OMP/OpenCode, bundled audit assets, MCP merge, idempotency, and conflict preflight"
