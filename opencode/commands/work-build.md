---
description: Implement approved tasks atomically, or run targeted read-only quality actions (review-and-qa / qa-only).
---

# /work-build $ARGUMENTS

Orchestrator: this session. Dispatch implementation to the `software-engineer` subagent via `task`; keep gates and user interaction here via `question`.

## Parse arguments

- No arguments → normal implementation (resolve slug by asking if several changes exist; never guess).
- `review-and-qa` or `qa-only` → quality-only action against the current branch (no slug).
- `<slug>` → normal implementation for that change.
- `<slug> review-and-qa|qa-only` → quality-only action for the slug.
- Reject unknown actions/extra arguments before any change; never reinterpret an unknown second argument as a slug.

## Quality-only target resolution (read-only for project files)

With slug: require `openspec/changes/<slug>/{proposal.md,design.md,tasks.md}` (missing → BLOCKED, no silent fallback); reports to `openspec/changes/<slug>/quality/`.
Without slug: resolve current branch; comparison base = open PR's base branch, else the default branch (unambiguous base required, else ask). Target = full branch diff from merge base (`git diff <base>...HEAD`) plus working-tree changes. Attach an OpenSpec change only if exactly one clear match. Reports to `.omp-quality/<sanitized-branch>/`.
Both forms: exclude the report directory from fingerprints; fingerprint = base ref/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash, untracked-file hashes, filtered status, diff stat. No meaningful code changes → report BLOCKED/NOTHING_TO_REVIEW, never PASS. Scope regression tests with `rtk codegraph affected <changed files>` when available; graph output guides selection but is not test evidence. Create the report dir before dispatch.

### review-and-qa

One batched `task` dispatch running `code-reviewer` and `qa-engineer` in parallel (single call with two subagent entries, shared context). Supply target scope, base ref, diff, fingerprint, report paths and available requirements context. Both are read-only and blocking. Reports: `review.md`, `qa.md`. Aggregate: any FAIL → report findings and stop (no silent edits); any BLOCKED → report it, never downgrade to PASS. If parallel dispatch is impossible, report BLOCKED; never claim parallelism.

### qa-only

Dispatch only `qa-engineer` with the same target/fingerprint/report rules. `qa.md` only. A qa-only PASS never satisfies the full ship gate.

## Normal implementation workflow

1. Read `tasks.md` + `design.md`. Gate 2 must be Approved **in this session**; if unknown, re-confirm via `question` before any edit — never infer from files/checkboxes.
2. Execute one discrete subtask per `task` dispatch. Before editing, confirm its declared target files and use Codegraph (`rtk codegraph impact <symbol>` / `affected <files...>`) when available to confirm callers and affected tests. **Blast radius:** only declared files are writable; all else READ-ONLY.
3. Dependencies only as approved in `design.md` (canonical manager + lockfile).
4. Verify each subtask with the narrow test/linter/typecheck; record exit codes and raw failures. Two failed repair attempts → stop and report the blocker.
5. On pass, mark only that checkbox `- [x]` in `tasks.md` and continue.
6. All tasks complete → `rtk openspec validate <slug>` (plain `openspec` when rtk is absent) + concise `git diff --stat`. Full regression belongs to `/work-ship`.

## Post-build quality choice

Via `question`: `Parallel AI review + QA [Recommended]` / `Human review` — never chosen automatically.
- AI: run the parallel review-and-qa procedure above.
- Human: skip both agents, report `HUMAN_REVIEW_PENDING` with diff/check summary and stop. `/work-ship` must then obtain fresh explicit confirmation.

## Completion

Report implementation checks and quality state separately. Only `READY_FOR_SHIP` when all tasks are complete AND the quality gate is approved. Quality-only actions never imply implementation completion or ship approval; a qa-only PASS does not satisfy a code-review gate.
