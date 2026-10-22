#!/usr/bin/env bash
# Checks effective routing/context configuration and reports historical usage.
# Usage: tests/token-budget.sh [hours] (default 24); not a workflow-savings benchmark.
set -euo pipefail

OMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}"
STATS_DB="$(dirname "$AGENT_DIR")/stats.db"
OMP_BIN="${OMP_BIN:-$(command -v omp || true)}"
HOURS="${1:-24}"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
status() { printf '  %s %s\n' "$1" "$2"; }

[[ -n "$OMP_BIN" ]] || fail 'omp binary not found on PATH (set OMP_BIN)'
command -v python3 >/dev/null || fail 'python3 is required'

# --- effective config assertions -------------------------------------------
# Reads the *effective* config, so a typo, a rejected key or install drift fails here.
OMP_BIN="$OMP_BIN" python3 <<'PY' || exit 1
import json, os, subprocess, sys

omp = os.environ["OMP_BIN"]

def get(key):
    r = subprocess.run([omp, "config", "get", key, "--json"], capture_output=True, text=True)
    if r.returncode != 0:
        return None
    try:
        return json.loads(r.stdout).get("value")
    except json.JSONDecodeError:
        return None

errors, checks = [], []

def check(label, ok, detail=""):
    checks.append((label, ok, detail))
    if not ok:
        errors.append(f"{label}: {detail}")

threshold = get("compaction.thresholdTokens")
check("compaction.thresholdTokens is a positive integer",
      type(threshold) is int and threshold > 0, f"got {threshold!r}")

find_enabled = get("find.enabled")
check("find (dead judge route) is disabled",
      find_enabled == "off", f"got {find_enabled!r}, expected 'off'")

roles = get("modelRoles") or {}
check("modelRoles defines review_tier and doc_tier",
      bool(roles.get("review_tier")) and bool(roles.get("doc_tier")),
      f"got {roles!r}")

overrides = get("task.agentModelOverrides") or {}
missing = []
for agent, value in overrides.items():
    if not isinstance(value, str) or not value.startswith("@"):
        missing.append(f"{agent}={value!r} is not a @role reference")
    elif value[1:] not in roles:
        missing.append(f"{agent} -> {value[1:]!r} has no modelRoles entry")
check("every agentModelOverride points at an existing role",
      not missing, "; ".join(missing))

chains = get("retry.fallbackChains") or {}
bad = [f"{role}={chain!r}" for role, chain in chains.items()
       if not isinstance(chain, list) or not chain or not all(isinstance(s, str) for s in chain)]
check("retry.fallbackChains are non-empty selector lists", not bad, "; ".join(bad))

selectors = [s for s in list(roles.values()) + [x for c in chains.values() for x in c]]
malformed = [s for s in selectors if not isinstance(s, str) or s.count("/") < 1]
check("every model selector is provider/model", not malformed, "; ".join(map(str, malformed)))

for label, ok, detail in checks:
    print(f"  {'PASS' if ok else 'FAIL'} {label}" + (f" [{detail}]" if not ok and detail else ""))
sys.exit(1 if errors else 0)
PY

# --- live usage report -----------------------------------------------------
if [[ ! -r "$STATS_DB" ]]; then
  fail "stats DB not readable: $STATS_DB"
fi
status INFO "usage window: ${HOURS}h  db: $STATS_DB"

STATS_DB="$STATS_DB" HOURS="$HOURS" python3 <<'PY'
import os, sqlite3, time

db, hours = os.environ["STATS_DB"], int(os.environ["HOURS"])
since = int(time.time() * 1000) - hours * 3600 * 1000
con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
cur = con.cursor()

row = cur.execute("""
    select count(*), sum(input_tokens), sum(output_tokens),
           sum(cache_read_tokens), sum(cache_write_tokens),
           sum(case when input_tokens + cache_read_tokens > 100000 then 1 else 0 end),
           sum(case when agent_type != 'main' then 1 else 0 end),
           max(input_tokens + cache_read_tokens)
    from messages where timestamp >= ?""", (since,)).fetchone()
req, inp, out, cread, cwrite, heavy, sub, peak = row
inp = inp or 0; out = out or 0; cread = cread or 0; cwrite = cwrite or 0
req = req or 0; heavy = heavy or 0; sub = sub or 0; peak = peak or 0
total = inp + out + cread + cwrite

def pct(part, whole):
    return f"{100.0 * part / whole:5.1f}%" if whole else "  n/a"

print(f"\n  requests          {req}")
print(f"  prompt tokens     {inp:,}  ({pct(inp, total)} of {total:,})")
print(f"  completion        {out:,}  ({pct(out, total)})")
print(f"  cache read        {cread:,}  ({pct(cread, total)})")
print(f"  subagent share    {pct(sub, req)} of requests")
print(f"  >100k prompt reqs {heavy} ({pct(heavy, req)} of requests)")
print(f"  largest prompt    {peak:,} tokens")

print("\n  per provider:")
for prov, r, i, o, c in cur.execute("""
        select provider, count(*), sum(input_tokens), sum(output_tokens), sum(cache_read_tokens)
        from messages where timestamp >= ? group by provider order by 2 desc""", (since,)):
    print(f"    {prov:<20} {r:>6} req  prompt {i or 0:>14,}  cache {c or 0:>14,}")

print("\n  peak requests in any 5h window (the rate-limit driver):")
for prov in ("openai-codex", "google-antigravity", "opencode-zen", "opencode-go", "openrouter"):
    buckets = {}
    for ts, in cur.execute(
            "select timestamp from messages where timestamp >= ? and provider = ?", (since, prov)):
        bucket = ts // (5 * 3600 * 1000)
        buckets[bucket] = buckets.get(bucket, 0) + 1
    peak_req = max(buckets.values()) if buckets else 0
    print(f"    {prov:<20} peak {peak_req:>6} req / 5h   (window total {sum(buckets.values()):>6})")
con.close()
PY
