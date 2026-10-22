#!/usr/bin/env bash
set -euo pipefail

python3 - "$(dirname "${BASH_SOURCE[0]}")/token-budget.sh" <<'PY'
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys
import tempfile

omp = os.environ.get("OMP_BIN") or shutil.which("omp")
if not omp:
    sys.exit("FAIL: installed omp is required")

with tempfile.TemporaryDirectory(prefix="omp-budget-config-") as directory:
    root = Path(directory)
    agent = root / "agent"
    agent.mkdir()
    with sqlite3.connect(root / "stats.db") as db:
        db.execute("CREATE TABLE messages (timestamp INTEGER, input_tokens INTEGER, output_tokens INTEGER, cache_read_tokens INTEGER, cache_write_tokens INTEGER, agent_type TEXT, provider TEXT)")
    for threshold, expected in [(65536, 0), (200000, 0), (0, 1), (-1, 1), ("true", 1)]:
        (agent / "config.yml").write_text(
            f"compaction:\n  thresholdTokens: {threshold}\n"
            'find:\n  enabled: "off"\n'
            "modelRoles:\n  review_tier: openrouter/minimax/minimax-m3.1-flash:free\n"
            "  doc_tier: openrouter/thinkingmachines/inkling:free\n"
        )
        result = subprocess.run(
            ["bash", sys.argv[1], "1"], text=True, capture_output=True,
            env={**os.environ, "PI_CODING_AGENT_DIR": str(agent), "OMP_BIN": omp},
        )
        assert result.returncode == expected, (
            f"threshold={threshold!r}: expected exit {expected}, got {result.returncode}\n"
            + result.stdout + result.stderr
        )
        print(f"PASS: threshold={threshold!r} exit={result.returncode}")
PY
