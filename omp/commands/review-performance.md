---
description: Read-only performance and scalability review: N+1, indexes, complexity, memory, I/O, caching and concurrency. Args: [target] [output-dir] [context]
---

# /review-performance [target] [output-dir] [context]

Role: read-only performance reviewer. You dispatch `performance-engineer` and own the report; you never edit project files.

## Arguments

- **target** (`$1`) — `diff` (default), an absolute/relative path, a glob, or an OpenSpec slug.
- **output-dir** (`$2`) — default `.reviews/<YYYY-MM-DD-HHmm>-performance/`; an absolute external path is allowed.
- **context** (`$3`+, optional) — free-form user instructions: traffic assumptions, expected input sizes, hot paths, or review emphasis. Pass verbatim to the dispatched reviewer; it may narrow or extend the review focus but never overrides the read-only boundary or the report contract.
- **Flexible parsing** — any argument that is not an existing path/glob and contains whitespace is treated as `context`, wherever it appears. `/review-security "watch tenant scoping"` targets the default `diff` with the default output dir; a slug, path or `diff` keyword still resolves as the target.

## Resolve the target (read-only)

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask. Scope = `git diff <base>...HEAD` plus working-tree changes. Exclude the output directory.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory. If more than 200 files or a diff beyond 2 MB, ask the user to narrow the scope.
- **slug** — read `openspec/changes/<slug>/` and review the queries, migrations, handlers and hot paths its tasks name.
- If the resolved scope has no meaningful code or design changes, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash and filtered diff stat; for paths, the sorted `sha256sum` of the selected files.

## Review Strategy: Step-by-Step Plan (No Subagents)

Do not spawn background subagents. Instead of running the review all at once, create a step-by-step review plan first in `<output-dir>/PLAN.md`, then execute each review step sequentially in session using the cheaper Z.ai GLM model (`zai/glm-5.3-flash:low`, `@review_tier`) to write `<output-dir>/REPORT.md`. After the detailed report is written, review and synthesize the summary files using the higher Z.ai GLM model (`zai/glm-5.3:high`, `@summary_tier`).

### Step 1: Create Review Plan (`<output-dir>/PLAN.md`)

Write `<output-dir>/PLAN.md` before inspecting code or writing reports:
- Target, base ref, scope, and fingerprint.
- Ordered review steps:
  1. Data access: N+1 queries, missing or unused indexes, full scans, wide tables, pagination, lock duration.
  2. Algorithms & memory: accidental O(n²)+ complexity, loops, redundant allocations, unbounded caches.
  3. I/O & concurrency: blocking calls, timeouts, retries, pool sizing, contention.
  4. Frontend performance (when in scope): bundle weight, render storms, caching headers.
  5. Summary review, cost model synthesis and verdict determination.
- Model tiers: Steps 1-4 cheaper Z.ai GLM Flash (`zai/glm-5.3-flash:low`), Step 5 higher Z.ai GLM (`zai/glm-5.3:high`).

### Step 2: Sequential Step-by-Step Review (Cheaper Model)

Execute each step sequentially in session without dispatching subagents via the `task` tool.
- Apply the cheaper Z.ai GLM model (`zai/glm-5.3-flash:low`).
- Trace data access: N+1 queries, missing or unused indexes, full scans, `SELECT *` on wide tables, unbounded result sets, missing pagination, eager/lazy loading mistakes, repeated identical queries, chatty round trips and transaction/lock duration.
- Trace algorithms: accidental O(n²) or worse, repeated work inside loops, redundant sorting/parsing/serialization, large allocations or copies, string concatenation in loops and unbounded caches.
- Trace I/O and network: unbatched calls, blocking work on hot paths, missing timeouts, retries without backoff, payload bloat, compression and streaming versus buffering.
- Trace concurrency: contention, lock granularity, pool sizing, queue backpressure, thundering herd and retry storms.
- When frontend is in scope: render storms, unnecessary re-renders, oversized bundles, blocking scripts, unbounded lists, asset weight and caching headers.
- Give a concrete cost model per finding — why it grows and under which input — plus the smallest effective fix and a measurement plan (query plan, benchmark, load profile) with the expected signal.
- Separate **measured** from **inferred** claims and mark decisive-but-unknown facts `needs_measurement`. Never claim a benchmark, profile or query plan that was not actually run.
- Use `Status: PASS | FAIL | BLOCKED`, stable IDs (`PERF-001`, …), severity P0–P3.
- Write findings to `<output-dir>/REPORT.md`.

### Step 3: Review Summary Files & Consolidate (Higher Model)

Review `<output-dir>/REPORT.md` and write `<output-dir>/SUMMARY.md` using the higher Z.ai GLM model (`zai/glm-5.3:high`, `@summary_tier`):
- Target, fingerprint, verdict (`PASS` / `FAIL` / `BLOCKED`).
- Findings by severity with their cost models and measurements still needed.
- Reviewed scope and the single next action.

`PASS` means no credible P0/P1 performance risk was found statically in the stated scope; it is not a capacity guarantee. Confirmed P0/P1 findings are advisory: surface them prominently and summarize them into the reviewed docs; they never block `/work-ship`.

## Boundaries

- Static review by default. Do not run builds, benchmarks, profilers, load tests or target code unless the user explicitly authorizes it and a safe sandbox exists.
- No writes except `<output-dir>`. Never modify the reviewed code.
- Use `/review-patterns` for structural causes, `/security-audit` when a performance issue creates a denial-of-service or resource-exhaustion security boundary.
