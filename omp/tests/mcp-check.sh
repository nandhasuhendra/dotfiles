#!/usr/bin/env bash
# Verify the configured MCP servers in omp/mcp.json.
# Usage: tests/mcp-check.sh [path/to/mcp.json]
# Checks configuration, then performs a real MCP handshake and tools/list for each enabled server.
set -uo pipefail

MCP_JSON=${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/mcp.json}
CONTEXT7_URL=${CONTEXT7_URL:-https://mcp.context7.com/mcp}
PLAYWRIGHT_BIN=${PLAYWRIGHT_BIN:-$(command -v playwright-mcp || echo "$HOME/.local/bin/playwright-mcp")}

fail=0
pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; fail=1; }

command -v python3 >/dev/null || { echo "FAIL python3 is required"; exit 1; }
[ -f "$MCP_JSON" ] || { echo "FAIL mcp.json not found: $MCP_JSON"; exit 1; }

# --- Configuration -----------------------------------------------------------
python3 - "$MCP_JSON" <<'PY'
import json, sys
try:
    cfg = json.load(open(sys.argv[1]))
except Exception as exc:
    print(f"FAIL mcp.json is not valid JSON: {exc}")
    sys.exit(1)
servers = cfg.get("mcpServers", {})
ok = True
for name, kind in (("context7", "http"), ("playwright", "stdio")):
    s = servers.get(name)
    if not s:
        print(f"FAIL mcp.json is missing the {name} server")
        ok = False
        continue
    if not s.get("enabled"):
        print(f"FAIL mcp.json disables the {name} server")
        ok = False
        continue
    if s.get("type") != kind:
        print(f"FAIL {name} should use type {kind}, found {s.get('type')!r}")
        ok = False
        continue
    print(f"PASS {name} is enabled as {kind}")
sys.exit(0 if ok else 1)
PY
[ $? -eq 0 ] || fail=1

# --- Context7 tools/list -----------------------------------------------------
python3 - "$CONTEXT7_URL" <<'PY'
import json, sys, urllib.request
url = sys.argv[1]
required = {"resolve-library-id", "query-docs"}
def rpc(payload):
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        body = resp.read().decode()
    for line in body.splitlines():
        line = line.strip()
        if line.startswith("data: "):
            line = line[6:]
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if obj.get("id") == payload["id"]:
            return obj
    raise SystemExit("no matching JSON-RPC response")
try:
    init = rpc({"jsonrpc": "2.0", "id": 1, "method": "initialize",
                "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                           "clientInfo": {"name": "omp-mcp-check", "version": "1.0.0"}}})
    if (init.get("result") or {}).get("serverInfo", {}).get("name") != "Context7":
        raise SystemExit("unexpected Context7 initialize response")
    tools = {t.get("name") for t in (rpc({"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
                                     .get("result") or {}).get("tools", [])}
    missing = required - tools
    if missing:
        raise SystemExit(f"missing Context7 tools: {', '.join(sorted(missing))}")
    print(f"PASS Context7 tools/list exposes {', '.join(sorted(required))}")
except Exception as exc:
    print(f"FAIL Context7 handshake failed: {exc}")
    sys.exit(1)
PY
[ $? -eq 0 ] || fail=1

# --- Playwright tools/list ---------------------------------------------------
[ -x "$PLAYWRIGHT_BIN" ] || { fail "playwright-mcp not found: $PLAYWRIGHT_BIN"; }
if [ -x "$PLAYWRIGHT_BIN" ]; then
python3 - "$PLAYWRIGHT_BIN" <<'PY'
import json, subprocess, sys
required = {"browser_navigate", "browser_snapshot", "browser_click", "browser_type",
            "browser_console_messages", "browser_network_requests"}
proc = subprocess.Popen(
    [sys.argv[1], "--browser", "chromium", "--headless", "--no-sandbox"],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1,
)
def send(obj):
    proc.stdin.write(json.dumps(obj) + "\n")
    proc.stdin.flush()
def read_until(req_id):
    while True:
        line = proc.stdout.readline()
        if not line:
            return None
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if obj.get("id") == req_id:
            return obj
try:
    send({"jsonrpc": "2.0", "id": 1, "method": "initialize",
          "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                     "clientInfo": {"name": "omp-mcp-check", "version": "1.0.0"}}})
    init = read_until(1)
    if not init or (init.get("result") or {}).get("serverInfo", {}).get("name") != "Playwright":
        raise SystemExit("unexpected Playwright initialize response")
    send({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})
    send({"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
    response = read_until(2)
    tools = {t.get("name") for t in (response or {}).get("result", {}).get("tools", [])}
    missing = required - tools
    if missing:
        raise SystemExit(f"missing Playwright tools: {', '.join(sorted(missing))}")
    print(f"PASS Playwright tools/list exposes {len(required)} required browser_* tools")
except Exception as exc:
    print(f"FAIL Playwright handshake failed: {exc}")
    sys.exit(1)
finally:
    proc.terminate()
    try:
        proc.wait(timeout=5)
    except Exception:
        proc.kill()
PY
[ $? -eq 0 ] || fail=1
fi

[ "$fail" = 0 ] || { echo "== MCP check FAILED"; exit 1; }
echo "== MCP check PASSED"
