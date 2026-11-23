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
Without slug: resolve current branch; comparison base = open PR's base branch, else the default branch (unambiguous base required, else ask). Target = full branch diff from merge base (`git diff <base>...HEAD`) plus working-tree changes. Attach an OpenSpec change only if exactly one clear match. Reports to `.reviews/quality/<sanitized-branch>/`.
Both forms: exclude the report directory from fingerprints; fingerprint = base ref/merge-base SHA, HEAD SHA, branch-diff hash, working-tree diff hash, untracked-file hashes, filtered status, diff stat. No meaningful code changes → report BLOCKED/NOTHING_TO_REVIEW, never PASS. Scope regression tests with `rtk codegraph affected <changed files>` when available; graph output guides selection but is not test evidence. Create the report dir before dispatch.

### review-and-qa

One batched `task` dispatch running `code-reviewer` and `qa-engineer` in parallel (single call with two subagent entries, shared context). Supply target scope, base ref, diff, fingerprint, report paths and available requirements context. Both are read-only and blocking. Hard cap: review actions dispatch at most 2 subagents total — never a third reviewer. Reports: `review.md`, `qa.md`. Aggregate: any FAIL → report findings and stop (no silent edits); any BLOCKED → report it, never downgrade to PASS. If parallel dispatch is impossible, report BLOCKED; never claim parallelism. When the security trigger below fires, no extra subagents: write `security.md` with `status: deferred` plus the trigger reasons, fingerprint and a pointer to `/security-audit`; otherwise `status: not_triggered`.

### qa-only

Dispatch only `qa-engineer` with the same target/fingerprint/report rules. `qa.md` only. A qa-only PASS never satisfies the full ship gate and never runs the risk-triggered security audit.

## Action: review-and-qa — risk-triggered security audit

Evaluate the deterministic risk trigger on the target diff — changed paths or operations touching: authentication/session/identity/tokens/MFA; authorization, roles, policy, tenant/owner scoping or data isolation; crypto/key/signing/secrets/credentials; untrusted input reaching sinks (SQL/NoSQL, shell/process, templates, deserialization, paths, uploads, URL fetch/SSRF, archive extraction); HTTP framing, proxies, headers, cookies, CORS/CSP, TLS or listeners; dependency manifests/lockfiles, CI workflows, release/signing, container, cloud or IaC config; filesystem permissions, local IPC, plugin loading or subprocess control; LLM/agent tool boundaries or prompts built from external content; migrations/exports/deletions/restores of user data. Also trigger when `review.md` or `qa.md` flags a security-relevant concern.

- Trigger fires → do NOT spawn extra subagents (hard cap: 2). Write `security.md` in the report directory with `status: deferred`, trigger reasons, fingerprint and a pointer to `/security-audit` as the standalone deep audit.
- No trigger → write `security.md` with `status: not_triggered`, the fingerprint and the evaluated trigger set.

Review/QA/security results are advisory input for the user, never a ship gate (see Completion). Neither agent edits project files, tests or OpenSpec artifacts.

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

Report implementation checks and quality state separately. Report `READY_FOR_SHIP` when all tasks are complete and focused checks pass; review/QA/security reports are advisory evidence only and never gate this status. A `qa-only` PASS remains partial evidence and does not substitute for a code-review summary.
