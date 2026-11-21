---
description: Read-only combined review: correctness, security, patterns and performance for code; security and engineering for docs. Args: [target] [output-dir]
---

# /review-all $ARGUMENTS

Role: read-only review orchestrator. You dispatch independent reviewers, never let one see another's result, and own the consolidated report. You never edit project files.

## Arguments

- **target** — `diff` (default), a path, a glob, an OpenSpec slug, or `docs` with a path/scope argument through `/review-docs` semantics.
- **output-dir** — default `.omp/reviews/<YYYY-MM-DD-HHmm>-all/`; an absolute external path is allowed.

## Resolve the target and classify it

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask with the `question` tool. Scope = `git diff <base>...HEAD` plus working-tree changes.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory.
- **slug** — `openspec/changes/<slug>/`; review the docs with the docs track and the files named by `tasks.md` with the code track.
- Classify the scope: **code** when it contains source, config or schema changes; **docs** when it contains only Markdown/design documents. A mixed scope runs both tracks: docs units per the `/review-docs` inventory rules, code through the four code reviewers.
- If nothing meaningful is in scope, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash, untracked-file hashes and filtered diff stat; for docs units, `sha256sum proposal.md design.md tasks.md` in that fixed order, or the sorted selected files.

## Dispatch

Run all reviewers for the chosen track in parallel through the `task` tool, one task each, all with the same scope, fingerprint, intent context and read-only boundary. Never give one reviewer another's report.

**Code track** (`<output-dir>/`):

| Reviewer | Report | IDs | Focus |
| --- | --- | --- | --- |
| `code-reviewer` | `code.md` | `CR-001` | correctness, edge cases, error handling, tests, API compatibility, data integrity, race conditions |
| `security-engineer` | `security.md` | `SEC-001` | trust boundaries, authz/tenant scope, injection and RCE, XSS, secrets, SSRF, uploads, rate limits, dependency risk |
| `pattern-reviewer` | `patterns.md` | `PAT-001` | SOLID/KISS/YAGNI, boundaries, coupling, duplication, dead code, change risk |
| `performance-engineer` | `performance.md` | `PERF-001` | N+1, indexes, scans, pagination, complexity, memory, I/O, caching, concurrency |

**Docs track** (`<output-dir>/security/<unit>.md`, `<output-dir>/engineering/<unit>.md`):

| Reviewer | IDs | Focus |
| --- | --- | --- |
| `security-engineer` | `SEC-SPEC-nnn` | threats and controls named in the design, unsafe defaults, missing authz/validation boundaries |
| `principal-engineer` | `ENG-SPEC-nnn` | durability, reliability, data access, migrations, contracts, SOLID/KISS/YAGNI, task completeness |

Every reviewer must return `Status: PASS | FAIL | BLOCKED` (docs: `PASS | CHANGES_REQUESTED | BLOCKED`), a stable ID per finding, severity P0–P3, exact location, the concrete consequence, the smallest fix and a verification case; and must state what was actually reviewed. A reviewer that cannot establish scope returns `BLOCKED` with the missing fact. Reviewers never run target code, benchmarks or live probes unless the user explicitly authorizes it and a sandbox exists.

## Consolidate

Write `<output-dir>/SUMMARY.md` with:

- Target, base, fingerprints, track(s) and review date.
- A verdict row per reviewer: reviewer | status | P0 | P1 | P2+P3 | top finding.
- An overall verdict: `PASS` only when every reviewer is PASS or only P2/P3 remain; `FAIL` when any confirmed P0/P1 exists; `BLOCKED` when any reviewer is BLOCKED and the missing fact is decisive.
- A deduplicated findings table (same root cause → one row, with the reviewer IDs that reported it), sorted P0 first.
- Cross-cutting themes and the single next action.
- A statement of reviewed scope and the limits of a static, non-exhaustive review.

Confirmed P0/P1 blocks `/work-ship` for the same diff until fixed and re-reviewed. This command is not a substitute for `/security-audit` when a coverage-led, independently verified audit with `findings.json` is required.

## Boundaries

- Source and document inspection only. No writes outside `<output-dir>`.
- Never modify the reviewed code, docs, tests or another reviewer's report.
- Use the single-dimension commands (`/review-security`, `/review-patterns`, `/review-performance`, `/review-docs`) for cheaper re-runs after fixes.
