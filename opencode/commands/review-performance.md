---
description: Read-only performance and scalability review: N+1, indexes, complexity, memory, I/O, caching and concurrency. Args: [target] [output-dir]
---

# /review-performance $ARGUMENTS

Role: read-only performance reviewer. You dispatch `performance-engineer` and own the report; you never edit project files.

## Arguments

- **target** — `diff` (default), an absolute/relative path, a glob, or an OpenSpec slug.
- **output-dir** — default `.omp/reviews/<YYYY-MM-DD-HHmm>-performance/`; an absolute external path is allowed.

## Resolve the target (read-only)

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask with the `question` tool. Scope = `git diff <base>...HEAD` plus working-tree changes. Exclude the output directory.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory. If more than 200 files or a diff beyond 2 MB, ask the user to narrow the scope.
- **slug** — read `openspec/changes/<slug>/` and review the queries, migrations, handlers and hot paths its tasks name.
- If the resolved scope has no meaningful code or design changes, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash and filtered diff stat; for paths, the sorted `sha256sum` of the selected files.

## Dispatch

Send `performance-engineer` one task with the exact scope, fingerprint, known traffic assumptions or expected input sizes (state "unknown" when they are not in the repository), the read-only boundary and the report path `<output-dir>/REPORT.md`.

The reviewer must:

- Trace data access: N+1 queries, missing or unused indexes, full scans, `SELECT *` on wide tables, unbounded result sets, missing pagination, eager/lazy loading mistakes, repeated identical queries, chatty round trips and transaction/lock duration.
- Trace algorithms: accidental O(n²) or worse, repeated work inside loops, redundant sorting/parsing/serialization, large allocations or copies, string concatenation in loops and unbounded caches.
- Trace I/O and network: unbatched calls, blocking work on hot paths, missing timeouts, retries without backoff, payload bloat, compression and streaming versus buffering.
- Trace concurrency: contention, lock granularity, pool sizing, queue backpressure, thundering herd and retry storms.
- When frontend is in scope: render storms, unnecessary re-renders, oversized bundles, blocking scripts, unbounded lists, asset weight and caching headers.
- Give a concrete cost model per finding — why it grows and under which input — plus the smallest effective fix and a measurement plan (query plan, benchmark, load profile) with the expected signal.
- Separate **measured** from **inferred** claims and mark decisive-but-unknown facts `needs_measurement`. Never claim a benchmark, profile or query plan that was not actually run.
- Use `Status: PASS | FAIL | BLOCKED`, stable IDs (`PERF-001`, …), severity P0–P3.

## Summary

Write `<output-dir>/SUMMARY.md`: target, fingerprint, verdict (`PASS` / `FAIL` / `BLOCKED`), findings by severity with their cost models, the measurements still needed, reviewed scope, and the single next action.

`PASS` means no credible P0/P1 performance risk was found statically in the stated scope; it is not a capacity guarantee. Confirmed P0/P1 blocks `/work-ship` for the same diff until fixed or explicitly accepted.

## Boundaries

- Static review by default. Do not run builds, benchmarks, profilers, load tests or target code unless the user explicitly authorizes it and a safe sandbox exists.
- No writes except `<output-dir>`. Never modify the reviewed code.
- Use `/review-patterns` for structural causes, `/security-audit` when a performance issue creates a denial-of-service or resource-exhaustion security boundary.
