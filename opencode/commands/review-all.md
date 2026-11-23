---
description: Read-only combined review: correctness, security, patterns and performance for code; security and engineering for docs. Args: [target] [output-dir]
---

# /review-all $ARGUMENTS

Role: read-only review orchestrator. You dispatch independent reviewers, never let one see another's result, and own the consolidated report. You never edit project files.

## Arguments

- **target** — `diff` (default), a path, a glob, an OpenSpec slug, or `docs` with a path/scope argument through `/review-docs` semantics.
- **output-dir** (`$2`) — default `.reviews/<YYYY-MM-DD-HHmm>-all/`; an absolute external path is allowed.

## Resolve the target and classify it

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask with the `question` tool. Scope = `git diff <base>...HEAD` plus working-tree changes.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory.
- **slug** — `openspec/changes/<slug>/`; review the docs with the docs track and the files named by `tasks.md` with the code track.
- Classify the scope: **code** when it contains source, config or schema changes; **docs** when it contains only Markdown/design documents. A mixed scope runs both tracks: docs units per the `/review-docs` inventory rules, code through the four code reviewers.
- If nothing meaningful is in scope, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash, untracked-file hashes and filtered diff stat; for docs units, `sha256sum proposal.md design.md tasks.md` in that fixed order, or the sorted selected files.

## Review Strategy: Step-by-Step Plan (No Subagents)

Do not spawn background subagents. Instead of running all reviews in parallel at once, create a step-by-step review plan first in `<output-dir>/PLAN.md`, then execute each review step sequentially in session using the cheaper Z.ai GLM model (`zai/glm-5.3-flash#low`). After all step reports are written, review and synthesize the summary files using the higher Z.ai GLM model (`zai/glm-5.3#high`).

### Step 1: Create Review Plan (`<output-dir>/PLAN.md`)

Write `<output-dir>/PLAN.md` before inspecting code or writing reports:
- Target, base ref, scope classification, and complete fingerprints.
- Ordered review steps:
  - **Code track:**
    1. `code`: Correctness, edge cases, error handling, tests, API compatibility, data integrity, race conditions (`code.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
    2. `security`: Trust boundaries, authz/tenant scope, injection/RCE, XSS, secrets, SSRF, uploads, rate limits, dependencies (`security.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
    3. `patterns`: SOLID/KISS/YAGNI, boundaries, coupling, duplication, dead code, change risk (`patterns.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
    4. `performance`: N+1, indexes, scans, pagination, complexity, memory, I/O, caching, concurrency (`performance.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
    5. `summary`: Review summary files, deduplicate findings, verify evidence, synthesize verdict (`SUMMARY.md`). Model: higher Z.ai GLM (`zai/glm-5.3#high`).
  - **Docs track:**
    1. `inventory`: Unit catalog, completeness and document fingerprints.
    2. `security/<unit>`: Threats, named controls, unsafe defaults, missing boundaries (`security/<unit>.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
    3. `engineering/<unit>`: Durability, reliability, data access, migrations, contracts, SOLID/KISS/YAGNI (`engineering/<unit>.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
    4. `summary`: Review unit reports, cross-cutting themes, backlog and verdict (`SUMMARY.md`). Model: higher Z.ai GLM (`zai/glm-5.3#high`).

### Step 2: Sequential Step-by-Step Review (Cheaper Model)

Execute each step from `PLAN.md` sequentially in session (one at a time, not all at once). Do not dispatch subagents via the `task` tool.
- Apply the cheaper Z.ai GLM model (`zai/glm-5.3-flash#low`).
- Inspect target code/docs relevant to the current step plus minimum surrounding context.
- Adhere to the report contracts below:

**Code track** (`<output-dir>/`):

| Step | Report | IDs | Focus |
| --- | --- | --- | --- |
| Correctness | `code.md` | `CR-001` | correctness, edge cases, error handling, tests, API compatibility, data integrity, race conditions |
| Security | `security.md` | `SEC-001` | trust boundaries, authz/tenant scope, injection and RCE, XSS, secrets, SSRF, uploads, rate limits, dependency risk |
| Patterns | `patterns.md` | `PAT-001` | SOLID/KISS/YAGNI, boundaries, coupling, duplication, dead code, change risk |
| Performance | `performance.md` | `PERF-001` | N+1, indexes, scans, pagination, complexity, memory, I/O, caching, concurrency |

**Docs track** (`<output-dir>/security/<unit>.md`, `<output-dir>/engineering/<unit>.md`):

| Step | Report | IDs | Focus |
| --- | --- | --- | --- |
| Security | `security/<unit>.md` | `SEC-SPEC-nnn` | threats and controls named in the design, unsafe defaults, missing authz/validation boundaries |
| Engineering | `engineering/<unit>.md` | `ENG-SPEC-nnn` | durability, reliability, data access, migrations, contracts, SOLID/KISS/YAGNI, task completeness |

Every review step must return `Status: PASS | FAIL | BLOCKED` (docs: `PASS | CHANGES_REQUESTED | BLOCKED`), a stable ID per finding, severity P0–P3, exact location, the concrete consequence, the smallest fix and a verification case; and must state what was actually reviewed. If scope cannot be established, report `BLOCKED` with the missing fact. Never run target code, benchmarks or live probes unless the user explicitly authorizes it and a sandbox exists.
Mark each step completed in `PLAN.md` upon report generation.

### Step 3: Review Summary Files & Consolidate (Higher Model)

Review all individual report files and write `<output-dir>/SUMMARY.md` using the higher Z.ai GLM model (`zai/glm-5.3#high`):

- Target, base, fingerprints, track(s) and review date.
- A verdict row per reviewer: reviewer | status | P0 | P1 | P2+P3 | top finding.
- An overall verdict: `PASS` only when every reviewer is PASS or only P2/P3 remain; `FAIL` when any confirmed P0/P1 exists; `BLOCKED` when any reviewer is BLOCKED and the missing fact is decisive.
- A deduplicated findings table (same root cause → one row, with the reviewer IDs that reported it), sorted P0 first.
- Cross-cutting themes and the single next action.
- A statement of reviewed scope and the limits of a static, non-exhaustive review.

Confirmed P0/P1 findings are surfaced prominently to the user and summarized into the reviewed change docs; they never block `/work-ship` (shipping requires only explicit user review confirmation). This command is not a substitute for `/security-audit` when a coverage-led, independently verified audit with `findings.json` is required.

## Boundaries

- Source and document inspection only. No writes outside `<output-dir>`.
- Never modify the reviewed code, docs, tests or another reviewer's report.
- Use the single-dimension commands (`/review-security`, `/review-patterns`, `/review-performance`, `/review-docs`) for cheaper re-runs after fixes.
