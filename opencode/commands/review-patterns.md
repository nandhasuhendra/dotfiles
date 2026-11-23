---
description: Read-only review of code patterns, architecture, SOLID/KISS/YAGNI, duplication, coupling and maintainability. Args: [target] [output-dir]
---

# /review-patterns $ARGUMENTS

Role: read-only structural reviewer. You dispatch `pattern-reviewer` and own the report; you never edit project files.

## Arguments

- **target** — `diff` (default), an absolute/relative path, a glob, or an OpenSpec slug.
- **output-dir** — default `.reviews/<YYYY-MM-DD-HHmm>-patterns/`; an absolute external path is allowed.

## Resolve the target (read-only)

- **diff** — resolve the comparison base like `/work-build review-and-qa`: the open PR's base branch, else the repository default branch; if ambiguous, ask with the `question` tool. Scope = `git diff <base>...HEAD` plus working-tree changes. Exclude the output directory.
- **path/glob** — the selected files, respecting `.gitignore`; exclude `.git`, `node_modules`, vendored dependencies, build output and the output directory. If more than 200 files or a diff beyond 2 MB, ask the user to narrow the scope.
- **slug** — read `openspec/changes/<slug>/` and review the source files its tasks name, plus `design.md` when the change has one.
- If the resolved scope has no meaningful code or design changes, report `BLOCKED/NOTHING_TO_REVIEW`; never PASS.

Compute and record the fingerprint: for diffs, base/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash and filtered diff stat; for paths, the sorted `sha256sum` of the selected files.

## Review Strategy: Step-by-Step Plan (No Subagents)

Do not spawn background subagents. Instead of running the review all at once, create a step-by-step review plan first in `<output-dir>/PLAN.md`, then execute each review step sequentially in session using the cheaper Z.ai GLM model (`zai/glm-5.3-flash#low`) to write `<output-dir>/REPORT.md`. After the detailed report is written, review and synthesize the summary files using the higher Z.ai GLM model (`zai/glm-5.3#high`).

### Step 1: Create Review Plan (`<output-dir>/PLAN.md`)

Write `<output-dir>/PLAN.md` before inspecting code or writing reports:
- Target, base ref, scope, and fingerprint.
- Ordered review steps:
  1. Module boundaries, layering, dependency direction, cohesion & coupling.
  2. Principles & abstractions (SOLID variation points, KISS, YAGNI, premature generalization).
  3. Code health & duplication (divergent behavior, dead code, error handling consistency).
  4. Change risk & maintainability (blast radius, backward compatibility, seams).
  5. Summary review, cross-cutting themes and verdict determination.
- Model tiers: Steps 1-4 cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`), Step 5 higher Z.ai GLM (`zai/glm-5.3#high`).

### Step 2: Sequential Step-by-Step Review (Cheaper Model)

Execute each step sequentially in session without dispatching subagents via the `task` tool.
- Apply the cheaper Z.ai GLM model (`zai/glm-5.3-flash#low`).
- Judge structure and principles only where a concrete risk exists: real variation points for SOLID, smallest complete solution for KISS, no speculative abstraction or dead extension points for YAGNI, and DRY without merging unrelated concerns.
- Check module boundaries, dependency direction, layering, cohesion/coupling, interface width, naming and consistency with existing conventions.
- Flag duplication that hides divergent behavior, dead code, premature abstraction, leaky abstractions, hidden global state, inconsistent error handling and untestable seams.
- Assess change risk: backward compatibility, migration complexity, blast radius, missing extension seams and maintainability cost out of proportion to the benefit.
- For design documents, check over-engineered decisions, missing boundaries, contradictions and requirements with no acceptance criterion.
- Not report formatter/style nits, personal preference, or refactors without a concrete risk. Do not duplicate `security-engineer` or `performance-engineer` findings beyond naming the structural cause.
- Use `Status: PASS | FAIL | BLOCKED`, stable IDs (`PAT-001`, …), severity P0–P3, `file:line` or design section, the concrete risk, the smallest corrective refactor and how to verify it.
- Never claim a tool run, benchmark or inspection that did not occur.
- Write findings to `<output-dir>/REPORT.md`.

### Step 3: Review Summary Files & Consolidate (Higher Model)

Review `<output-dir>/REPORT.md` and write `<output-dir>/SUMMARY.md` using the higher Z.ai GLM model (`zai/glm-5.3#high`):
- Target, fingerprint, verdict (`PASS` / `FAIL` / `BLOCKED`).
- Findings by severity grouped by theme (principles, structure, code health, change risk).
- Reviewed scope and the single next action.

`PASS` means no P0/P1 structural finding in the stated scope, not proof of good design. Confirmed P0/P1 findings are advisory: surface them prominently and summarize them into the reviewed docs; they never block `/work-ship`.

## Boundaries

- Source inspection only; static by default. Do not run target code, builds, linters or refactors.
- No writes except `<output-dir>`. Never modify the reviewed code or documents.
- Use `/review-security` for exploitability, `/review-performance` for cost models, and `/review-all` for a combined verdict.
