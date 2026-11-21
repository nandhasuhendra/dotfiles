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

One batched `task` dispatch running `code-reviewer` and `qa-engineer` in parallel (single call with two subagent entries, shared context). Supply target scope, base ref, diff, fingerprint, report paths and available requirements context. Both are read-only and blocking. Reports: `review.md`, `qa.md`. Aggregate: any FAIL → report findings and stop (no silent edits); any BLOCKED → report it, never downgrade to PASS. If parallel dispatch is impossible, report BLOCKED; never claim parallelism. When the security trigger below fires, dispatch `security-audit-recon` in the same parallel round; if the batched call accepts only the review/QA pair, start recon in a second concurrent call.

### qa-only

Dispatch only `qa-engineer` with the same target/fingerprint/report rules. `qa.md` only. A qa-only PASS never satisfies the full ship gate and never runs the risk-triggered security audit.

## Action: review-and-qa — risk-triggered security audit

Automatically run a scoped security audit when the target diff crosses a risk trigger. Do not ask the user; the trigger is deterministic. `/security-audit` remains the manual entry for a full or user-directed audit.

### Trigger

Trigger when changed paths or operations touch any of:

- authentication, session, identity, password, token, OAuth/OIDC/SAML or MFA;
- authorization, roles, policy, tenant/owner scoping or data isolation;
- cryptography, key management, signing, secrets or credential handling;
- untrusted input reaching a sink: SQL/NoSQL, shell or process execution, templates, deserialization, path handling, uploads, URL fetch/SSRF or archive extraction;
- HTTP framing, proxies, headers, cookies, CORS/CSP, TLS or network listeners;
- dependency manifests or lockfiles, CI workflows, release/signing, container, cloud or IaC configuration;
- filesystem permissions, local IPC, plugin/extension loading or subprocess control;
- LLM/agent tool boundaries, or prompts built from external content;
- migrations, exports, deletions or restores of user data.

Also trigger when `review.md` or `qa.md` flags a security-relevant concern. When the trigger is uncertain, audit rather than skip and record the reason.

### Scoped quick audit

When triggered:

1. Read `<skill-dir>/SKILL.md` first, then `RECONNAISSANCE.md`, `HUNTING.md`, `ATTACK-CLASSES.md` and `VALIDATION-AND-REPORTING.md` at the phase that needs them. Skill directory: `~/.config/opencode/skills/security-audit` (resolve the real path when it is a symlink).
2. Use a new `~/security-audit-skill/<repo-name>/run-<N>` directory outside the repository. Never write run files into the quality directory or the target.
3. Use profile `quick`, scope = the same base and target diff as the quality action, budget = 12 agent invocations, and record them in `run-metadata.json`. Dispatch the scoped reconnaissance to `security-audit-recon` in the same parallel round as `code-reviewer` and `qa-engineer`.
4. Synthesize a scoped `architecture.md`, seed a scoped `coverage-ledger.json`, and validate it with `node <skill-dir>/validate-coverage-ledger.cjs <output-dir>/coverage-ledger.json`.
5. Run exactly one `security-audit-hunter` wave with the skill's verbatim hunter prompt, then one fresh `security-audit-recon` coverage critic. In `quick`, critic-accepted discoveries become `deferred`.
6. Validate each candidate with a fresh `security-audit-verifier`; `quick` merges candidate validation and final record verification into that one verifier. Write and validate `findings.json`, then derive `REPORT.md`, `FINDINGS-DETAIL.md` and `NEEDS-VALIDATION.md`.
7. Write `security.md` in the quality report directory containing: trigger reasons, profile `quick` and the partial-coverage statement, base/merge-base and HEAD, fingerprint, source ref, run directory, agents spent versus budget, confirmed counts by severity, needs-validation and rejected counts, coverage counts, both validator results, `run_status`, and one verdict.

### Gate

- `FAIL` — any confirmed critical or high finding.
- `BLOCKED` — validator failure, `run_status: "incomplete"`, budget exhausted before verification, required agent unavailable, or a decisive fact left unresolved by missing sandbox capability.
- `PASS` — no confirmed critical or high finding. Confirmed medium/low/informational findings and needs-validation leads are reported and carried into the PR summary, never dropped.
- No trigger — write `security.md` with `status: not_triggered`, the fingerprint and the evaluated trigger set; launch no agents.

Aggregate: review + QA + security must all be `PASS` for the quality gate. A triggered audit that is missing, unrun, incomplete or `BLOCKED` blocks ship. The audit never edits project files, tests or OpenSpec artifacts.

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
