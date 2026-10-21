#!/usr/bin/env bash
# Live functional check of the omp setup in a FRESH process (what a restart loads).
# Static config assertions live in tests/token-budget.sh; this script proves behaviour.
#
#   bash tests/omp-setup-check.sh [parent-model-selector]
#
# Default parent = the provider the reviewer tier must NOT run on. Override it with
# a quota-limited provider (e.g. openai-codex/gpt-6.1-sol) to prove review traffic
# is kept off that provider's 5h window.
set -uo pipefail

OMP_BIN=${OMP_BIN:-$(command -v omp || echo "$HOME/.local/bin/omp")}
AGENT_DIR=${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}
CONFIG=${OMP_CONFIG:-$AGENT_DIR/config.yml}
STATS_DB=${STATS_DB:-$HOME/.omp/stats.db}
PARENT=${1:-openrouter/thinkingmachines/inkling:free}
WORKDIR=$(mktemp -d /tmp/omp-setup-check-XXXXXX)
trap '[ "$fail" = 0 ] && rm -rf "$WORKDIR"' EXIT

fail=0
pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; fail=1; }

command -v python3 >/dev/null || { echo "FAIL python3 is required"; exit 1; }
[ -x "$OMP_BIN" ] || { echo "FAIL omp binary not found: $OMP_BIN"; exit 1; }

review_selector=$(python3 - "$CONFIG" <<'PY'
import sys, re
txt = open(sys.argv[1]).read()
m = re.search(r"^\s{2}review_tier:\s*(\S+)", txt, re.M)
print(m.group(1) if m else "")
PY
)
[ -n "$review_selector" ] || { echo "FAIL modelRoles.review_tier not found in $CONFIG"; exit 1; }
review_provider=${review_selector%%/*}
review_model=${review_selector#*/}
parent_provider=${PARENT%%/*}
parent_model=${PARENT#*/}
printf '== setup check (parent=%s, review_tier=%s)\n' "$PARENT" "$review_selector"
if [ "$parent_provider" = "$review_provider" ]; then
  echo "note: parent and review_tier share provider $parent_provider; the provider dimension is not exercised"
fi

# --- A. fresh process: tool registry + effective session state -----------------
printf '%s\n' '{"id":"1","type":"get_state"}' \
  | timeout 180 "$OMP_BIN" --mode rpc --no-ui --model "$PARENT" > "$WORKDIR/rpc.jsonl" 2>"$WORKDIR/rpc.err"
python3 - "$WORKDIR/rpc.jsonl" > "$WORKDIR/state.txt" <<'PY'
import json, sys
for line in open(sys.argv[1]):
    line = line.strip()
    if not line:
        continue
    try:
        o = json.loads(line)
    except Exception:
        continue
    if o.get("type") == "response" and o.get("command") == "get_state":
        d = o.get("data", {})
        print("tools=" + ",".join(t.get("name", "") for t in d.get("dumpTools") or []))
        print("model=" + str((d.get("model") or {}).get("id", "")))
        print("provider=" + str((d.get("model") or {}).get("provider", "")))
        print("autoCompaction=" + str(d.get("autoCompactionEnabled")))
        break
PY
tools=$(sed -n 's/^tools=//p' "$WORKDIR/state.txt")
if [ -z "$tools" ]; then
  fail "fresh RPC process returned no get_state payload"
  head -3 "$WORKDIR/rpc.err"
else
  case ",$tools," in
    *,find,*) fail "find tool is still registered in a fresh process" ;;
    *) pass "find tool is not registered in a fresh process" ;;
  esac
  grep -q '^autoCompaction=True' "$WORKDIR/state.txt" \
    && pass "auto compaction enabled in a fresh process" \
    || fail "auto compaction not enabled in a fresh process"
  grep -q "^provider=$parent_provider$" "$WORKDIR/state.txt" \
    && pass "fresh process resolved the requested parent provider ($parent_provider)" \
    || fail "fresh process provider mismatch (expected $parent_provider)"
fi

# --- B. fresh process: reviewer subagent must land on review_tier -------------
( cd "$WORKDIR" && timeout 420 "$OMP_BIN" -p --model "$PARENT" \
    "Call the task tool exactly once with context=\"routing check\", tasks=[{agent: \"reviewer\", task: \"Reply with exactly OK.\", solutionSpace: \"one reply: OK\"}]. After it returns, wait for the spawned agent to finish with the wait tool, then reply DONE." \
    </dev/null > "$WORKDIR/run.out" 2>"$WORKDIR/run.err" )
python3 - "$STATS_DB" "$WORKDIR" "$review_provider" "$review_model" "$parent_provider" "$parent_model" <<'PY'
import sqlite3, sys, time, os
db, workdir, want_provider, want_model, parent_provider, parent_model = sys.argv[1:7]
key = os.path.basename(workdir)
con = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
deadline = time.time() + 90
rows = []
while time.time() < deadline:
    rows = list(con.execute(
        "select provider, model, input_tokens, output_tokens, stop_reason from messages "
        "where session_file like ? and agent_type='subagent' order by id desc limit 10",
        (f"%{key}%",)))
    if rows:
        break
    time.sleep(2)
if not rows:
    print("FAIL no reviewer subagent request was recorded in stats.db")
    try:
        print("parent output: " + open(os.path.join(workdir, "run.out")).read()[-400:])
    except Exception:
        pass
    sys.exit(1)
for provider, model, tin, tout, reason in rows:
    print(f"  subagent request: {provider}/{model} in={tin} out={tout} stop={reason}")
leak = [r for r in rows if (r[0], r[1]) == (parent_provider, parent_model)]
if leak:
    print(f"FAIL reviewer subagent inherited the parent model {parent_provider}/{parent_model}")
    sys.exit(1)
on_tier = [r for r in rows if r[0] == want_provider and r[1] == want_model]
if not on_tier:
    print(f"FAIL no reviewer subagent request on review_tier {want_provider}/{want_model}")
    sys.exit(1)
print(f"PASS reviewer subagent ran on {want_provider}/{want_model} (not on parent provider {parent_provider})")
PY
[ $? -eq 0 ] || fail=1

[ "$fail" = 0 ] || { echo "== setup check FAILED (workdir: $WORKDIR)"; exit 1; }
echo "== setup check PASSED (workdir: $WORKDIR)"
