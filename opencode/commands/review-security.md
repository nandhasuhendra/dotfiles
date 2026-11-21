---
description: Read-only security review of a branch diff, files or directory. Fast feedback; use /security-audit for a deep verified audit. Args: [target] [output-dir]
---

# /review-security $ARGUMENTS

Role: read-only security reviewer. You dispatch `security-engineer` and own the report; you never edit project files, tests or configs.

## Arguments

- **target** — `diff` (default), an absolute/relative path, a glob, or an OpenSpec slug.
- **output-dir** — default `.omp/reviews/<YYYY-MM-DD-HHmm>-security/`; an absolute external path is allowed.

## Resolve the target (read-only)

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask with the `question` tool. Scope = `git diff <base>...HEAD` plus working-tree changes. Exclude the output directory.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory. If more than 200 files or a diff beyond 2 MB, ask the user to narrow the scope.
- **slug** — read `openspec/changes/<slug>/tasks.md` and review the source files its tasks name. If the slug has only documents, stop and direct the user to `/review-docs <slug>`.
- If the resolved scope has no meaningful code changes, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash, untracked-file hashes, filtered status and diff stat; for paths, the sorted `sha256sum` of the selected files.

## Dispatch

Send `security-engineer` one task with the exact scope, base ref, fingerprint, intent context (OpenSpec artifacts when available, otherwise the PR/commit context), the read-only boundary and the report path `<output-dir>/REPORT.md`. If there are two clearly independent areas (for example frontend and backend) you may dispatch one reviewer per area; never split the same file or boundary across two reviewers.

The reviewer must:

- Trace each candidate: lower-trust principal, input or action, intended control, reachable path, and the concrete impact. Cite `file:line`.
- Check trust boundaries and entry points; authentication, authorization and tenant/object scoping; input validation; SQL/NoSQL, OS command, template and deserialization injection; RCE vectors (eval/dynamic code, unsafe deserialization, shell execution, template evaluation, plugin loading, user-controlled file writes); XSS and output encoding/CSP; session/CSRF/cookies/CORS/TLS; secrets and cryptography; SSRF and URL fetch; uploads, path traversal and archive extraction; rate limiting and resource exhaustion; error/log leakage; dependency risk; LLM prompt injection and tool authorization.
- Separate confirmed defects from hypotheses. A scanner-style warning or missing best practice without a reachable boundary result is not a confirmed vulnerability.
- Use `Status: PASS | FAIL | BLOCKED`, stable IDs (`SEC-001`, …), severity P0–P3 (P0 exploitable/data exposure, P1 high-risk weakness, P2 hardening, P3 informational), location, attack path, smallest fix and verification case.
- State what was reviewed, and state `BLOCKED` with the exact missing fact when a deployment or runtime fact is decisive. Never claim a scan, tool run or check that did not occur.

## Summary

Write `<output-dir>/SUMMARY.md`: target, base, fingerprint, verdict (`PASS` / `FAIL` / `BLOCKED`), confirmed findings by severity, hypotheses and their missing facts, reviewed scope, and the single next action.

`PASS` means no confirmed P0/P1 finding in the stated scope, not proof of security. Confirmed P0/P1 blocks `/work-ship` for the same diff until fixed and re-reviewed.

## Boundaries

- Source inspection only. Do not run target code, builds, tests, fuzzers or live probes unless the user explicitly asks and a sandbox exists; this command is static by default.
- No writes except `<output-dir>`. Never modify the reviewed code.
- For a deep, coverage-led, independently verified audit with `findings.json` and validators, use `/security-audit <target> quick` instead; this command is deliberately fast and partial.
