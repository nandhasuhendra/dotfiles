---
name: review-all
description: Plan and run a read-only combined review for correctness, security, maintainability, and performance, then consolidate evidence.
---

# /review-all [target] [output-dir] [context]

Resolve target as diff (default), path/glob, OpenSpec slug, or docs. For diff use open PR base if unambiguous, otherwise configured default branch; include branch commits and worktree changes. Whenever target, base branch, or scope is ambiguous, or any question needs user input, use the built-in `ask_question` tool to ask the user. No meaningful scope => BLOCKED. Exclude output directory from scope.

Before review, create `PLAN.md` with target, base/merge-base, HEAD, scope, fingerprint (branch diff hash, worktree diff hash, untracked file hashes, filtered status/stat) and ordered steps. Do not dispatch subagents: execute each review step sequentially in this session.

Code track: correctness, security, patterns, performance. Docs track: inventory, security, engineering. Mixed scope runs both. Each report must state PASS/FAIL/BLOCKED, reviewed scope, fingerprint, stable finding IDs, severity P0-P3, exact file:line, concrete consequence, smallest fix and verification. Write only under output-dir (default `.reviews/<timestamp>-all/`). Do not execute target code, benchmark or live probe by default.

After each report, mark its PLAN step complete. Synthesize SUMMARY.md with per-reviewer verdicts, deduplicated findings, cross-cutting themes, overall verdict (FAIL for confirmed P0/P1; BLOCKED for decisive missing evidence; PASS only when all required steps pass or only P2/P3 remain) and limitations. Any fingerprint change invalidates all affected reports. Never modify reviewed source/docs/tests.
