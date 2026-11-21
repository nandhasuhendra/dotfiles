---
description: Read-only review of code patterns, architecture, SOLID/KISS/YAGNI, duplication, coupling and maintainability. Args: [target] [output-dir]
---

# /review-patterns [target] [output-dir]

Role: read-only structural reviewer. You dispatch `pattern-reviewer` and own the report; you never edit project files.

## Arguments

- **target** (`$1`) — `diff` (default), an absolute/relative path, a glob, or an OpenSpec slug.
- **output-dir** (`$2`) — default `.omp/reviews/<YYYY-MM-DD-HHmm>-patterns/`; an absolute external path is allowed.

## Resolve the target (read-only)

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask. Scope = `git diff <base>...HEAD` plus working-tree changes. Exclude the output directory.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory. If more than 200 files or a diff beyond 2 MB, ask the user to narrow the scope.
- **slug** — read `openspec/changes/<slug>/` and review the source files its tasks name, plus `design.md` when the change has one.
- If the resolved scope has no meaningful code or design changes, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash and filtered diff stat; for paths, the sorted `sha256sum` of the selected files.

## Dispatch

Send `pattern-reviewer` one task with the exact scope, fingerprint, surrounding context (OpenSpec artifacts when available, otherwise the PR/commit context), the read-only boundary and the report path `<output-dir>/REPORT.md`. Do not split the same file or boundary across two reviewers.

The reviewer must:

- Judge structure and principles only where a concrete risk exists: real variation points for SOLID, smallest complete solution for KISS, no speculative abstraction or dead extension points for YAGNI, and DRY without merging unrelated concerns.
- Check module boundaries, dependency direction, layering, cohesion/coupling, interface width, naming and consistency with existing conventions.
- Flag duplication that hides divergent behavior, dead code, premature abstraction, leaky abstractions, hidden global state, inconsistent error handling and untestable seams.
- Assess change risk: backward compatibility, migration complexity, blast radius, missing extension seams and maintainability cost out of proportion to the benefit.
- For design documents, check over-engineered decisions, missing boundaries, contradictions and requirements with no acceptance criterion.
- Not report formatter/style nits, personal preference, or refactors without a concrete risk. Do not duplicate `security-engineer` or `performance-engineer` findings beyond naming the structural cause.
- Use `Status: PASS | FAIL | BLOCKED`, stable IDs (`PAT-001`, …), severity P0–P3, `file:line` or design section, the concrete risk, the smallest corrective refactor and how to verify it.
- Never claim a tool run, benchmark or inspection that did not occur.

## Summary

Write `<output-dir>/SUMMARY.md`: target, fingerprint, verdict (`PASS` / `FAIL` / `BLOCKED`), findings by severity grouped by theme (principles, structure, code health, change risk), reviewed scope, and the single next action.

`PASS` means no P0/P1 structural finding in the stated scope, not proof of good design. Confirmed P0/P1 blocks `/work-ship` for the same diff until addressed or explicitly accepted.

## Boundaries

- Source inspection only; static by default. Do not run target code, builds, linters or refactors.
- No writes except `<output-dir>`. Never modify the reviewed code or documents.
- Use `/review-security` for exploitability, `/review-performance` for cost models, and `/review-all` for a combined verdict.
