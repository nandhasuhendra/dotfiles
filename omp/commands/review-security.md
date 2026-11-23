---
description: Read-only security review of a branch diff, files or directory. Fast feedback; use /security-audit for a deep verified audit. Args: [target] [output-dir] [context]
---

# /review-security [target] [output-dir] [context]

Role: read-only security reviewer. You dispatch `security-engineer` and own the report; you never edit project files, tests or configs.

## Arguments

- **target** (`$1`) — `diff` (default), an absolute/relative path, a glob, or an OpenSpec slug.
- **output-dir** (`$2`) — default `.reviews/<YYYY-MM-DD-HHmm>-security/`; an absolute external path is allowed.
- **context** (`$3`+, optional) — free-form user instructions: threat model, deployment specifics, past incidents, or review emphasis. Pass verbatim to the dispatched reviewer; it may narrow or extend the review focus but never overrides the read-only boundary or the report contract.
- **Flexible parsing** — any argument that is not an existing path/glob and contains whitespace is treated as `context`, wherever it appears. `/review-security "watch tenant scoping"` targets the default `diff` with the default output dir; a slug, path or `diff` keyword still resolves as the target.

## Resolve the target (read-only)

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask. Scope = `git diff <base>...HEAD` plus working-tree changes. Exclude the output directory.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory. If more than 200 files or a diff beyond 2 MB, ask the user to narrow the scope.
- **slug** — read `openspec/changes/<slug>/tasks.md` and review the source files its tasks name. If the slug has only documents, stop and direct the user to `/review-docs <slug>`.
- If the resolved scope has no meaningful code changes, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash, untracked-file hashes, filtered status and diff stat; for paths, the sorted `sha256sum` of the selected files.

## Review Strategy: Step-by-Step Plan (No Subagents)

Do not spawn background subagents. Instead of running the review all at once, create a step-by-step review plan first in `<output-dir>/PLAN.md`, then execute each review step sequentially in session using the cheaper Z.ai GLM model (`zai/glm-5.3-flash:low`, `@review_tier`) to write `<output-dir>/REPORT.md`. After the detailed report is written, review and synthesize the summary files using the higher Z.ai GLM model (`zai/glm-5.3:high`, `@summary_tier`).

### Step 1: Create Review Plan (`<output-dir>/PLAN.md`)

Write `<output-dir>/PLAN.md` before inspecting code or writing reports:
- Target, base ref, scope, and fingerprint.
- Ordered review steps:
  1. Entry surfaces, trust boundaries, authentication, authorization and tenant/object scoping.
  2. Input validation and injection vectors (SQL/NoSQL, OS command, template, deserialization, RCE).
  3. Secrets, cryptography, session/CSRF, cookies/CORS/TLS, XSS/CSP, SSRF, uploads and path traversal.
  4. Rate limiting, resource exhaustion, log/error leakage, dependency risk, LLM prompt injection.
  5. Summary review, threat modeling synthesis and verdict determination.
- Model tiers: Steps 1-4 cheaper Z.ai GLM Flash (`zai/glm-5.3-flash:low`), Step 5 higher Z.ai GLM (`zai/glm-5.3:high`).

### Step 2: Sequential Step-by-Step Review (Cheaper Model)

Execute each step sequentially in session without dispatching subagents via the `task` tool.
- Apply the cheaper Z.ai GLM model (`zai/glm-5.3-flash:low`).
- Trace each candidate: lower-trust principal, input or action, intended control, reachable path, and the concrete impact. Cite `file:line`.
- Check trust boundaries and entry points; authentication, authorization and tenant/object scoping; input validation; SQL/NoSQL, OS command, template and deserialization injection; RCE vectors (eval/dynamic code, unsafe deserialization, shell execution, template evaluation, plugin loading, user-controlled file writes); XSS and output encoding/CSP; session/CSRF/cookies/CORS/TLS; secrets and cryptography; SSRF and URL fetch; uploads, path traversal and archive extraction; rate limiting and resource exhaustion; error/log leakage; dependency risk; LLM prompt injection and tool authorization.
- Separate confirmed defects from hypotheses. A scanner-style warning or missing best practice without a reachable boundary result is not a confirmed vulnerability.
- Use `Status: PASS | FAIL | BLOCKED`, stable IDs (`SEC-001`, …), severity P0–P3 (P0 exploitable/data exposure, P1 high-risk weakness, P2 hardening, P3 informational), location, attack path, smallest fix and verification case.
- State what was reviewed, and state `BLOCKED` with the exact missing fact when a deployment or runtime fact is decisive. Never claim a scan, tool run or check that did not occur.
- Write findings to `<output-dir>/REPORT.md`.

### Step 3: Review Summary Files & Consolidate (Higher Model)

Review `<output-dir>/REPORT.md` and write `<output-dir>/SUMMARY.md` using the higher Z.ai GLM model (`zai/glm-5.3:high`, `@summary_tier`):
- Target, base, fingerprint, verdict (`PASS` / `FAIL` / `BLOCKED`).
- Confirmed findings by severity, hypotheses and their missing facts.
- Reviewed scope and the single next action.

`PASS` means no confirmed P0/P1 finding in the stated scope, not proof of security. Confirmed P0/P1 findings are advisory: surface them prominently and summarize them into the reviewed docs; they never block `/work-ship` (use `/security-audit` for a coverage-led, verified audit).

## Boundaries

- Source inspection only. Do not run target code, builds, tests, fuzzers or live probes unless the user explicitly asks and a sandbox exists; this command is static by default.
- No writes except `<output-dir>`. Never modify the reviewed code.
- For a deep, coverage-led, independently verified audit with `findings.json` and validators, use `/security-audit <target> quick` instead; this command is deliberately fast and partial.
