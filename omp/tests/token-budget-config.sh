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
            "modelRoles:\n"
            "  default: openrouter/thinkingmachines/inkling:free\n"
            "  doc_tier: openrouter/thinkingmachines/inkling:free\n"
            "  execution_tier: openrouter/minimax/minimax-m3.1-flash:free\n"
            "  review_tier: openrouter/minimax/minimax-m3.1-flash:free\n"
            "  qa_tier: openrouter/minimax/minimax-m3.1-flash:free\n"
            "  security_tier: openrouter/thinkingmachines/inkling:free\n"
            "task:\n  agentModelOverrides:\n"
            '    tech-lead: "@doc_tier"\n'
            '    software-engineer: "@execution_tier"\n'
            '    code-reviewer: "@review_tier"\n'
            '    qa-engineer: "@qa_tier"\n'
            '    security-engineer: "@security_tier"\n'
            "retry:\n  modelFallback: true\n  fallbackOn: any\n  fallbackChains:\n"
            "    default: [openrouter/minimax/minimax-m3.1-flash:free]\n"
            "    doc_tier: [openrouter/minimax/minimax-m3.1-flash:free]\n"
            "    execution_tier: [openrouter/thinkingmachines/inkling:free]\n"
            "    review_tier: [openrouter/thinkingmachines/inkling:free]\n"
            "    qa_tier: [openrouter/minimax/minimax-m3.1-flash:free]\n"
            "    security_tier: [openrouter/minimax/minimax-m3.1-flash:free]\n"
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
