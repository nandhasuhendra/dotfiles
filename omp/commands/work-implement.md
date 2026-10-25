---
description: Implement an approved change.
---
## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/execution.md`; load `rules/gates.md` for authorization and freshness checks. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Enumerate the change directory and repository instructions, and recompute every gate-bound manifest including added and missing paths.
- Require fresh `human-planning` and `execution` approvals bound to the current inputs, complete `tasks.md`, independent execution-bundle review PASS, successful installed-schema validation and no blocking question. A legacy target name is not an alias for either approval.
- Read the approved requirements, design/specs, test plan, tasks and only the review/approval entries needed to establish authorization; read other artifact bodies when a decision depends on them. Do not reread unchanged artifacts merely to confirm they exist.
- Never substitute reviewer PASS or explicit invocation for human approval. A free-text request to implement, even naming this change and saying "proceed", does not bind either approval: report the missing prerequisites and the single command that obtains them, then stop without writing approvals or code. Stop for stale evidence rather than proceeding.

## Implement

- Dispatch `software-engineer` with the bundle paths, manifest identities, acceptance criteria, decisions, dependencies, relevant source context and gate evidence. Do not paste whole documents the agent can read by path. If author dispatch is unavailable, adopt its instructions and disclose it; never claim delegation.
- Read the installed Ponytail skill before implementation. Follow approved REQ/TC IDs and task dependencies; implement complete behavior with its tests, callers, fixtures, configuration, exports and affected documentation, preserving compatibility and error handling.
- Map affected callers and interfaces from source; use Codegraph/LSP for nontrivial dependency graphs and Context7 for relevant external documentation per core policy. Do not invoke a tool only to fill an evidence checklist.
- Route every shell tool invocation through RTK per core policy and keep real exit status and raw failure evidence.
- Allow targeted compiler, contract, unit or changed-path smoke checks once an owned slice and its dependencies are stable; do not run checks against files another agent is mutating. Author checks are feedback, not independent QA or review.
- Keep approved `tasks.md` wording and checkboxes unchanged; record completion, deviations, changed files and pending checks in `verification.md`, marking unrun checks NOT_RUN and unavailable checks BLOCKED.
- Material scope changes return to planning and renewed approval; changed QA expectations return to QA planning and execution review. Stop instead of silently expanding scope or altering approved tasks.

## Handoff

- Record implementation identity (HEAD plus digests of changed tracked, relevant untracked and deleted files), deviations, risks and exact runnable check/smoke commands in `verification.md`.
- When every approved task is complete, continue to `/work-verify $1` in the same turn. If verification cannot start because scope changed, tasks are incomplete, required evidence is missing or independent dispatch is unavailable, stop BLOCKED with the exact reason.
- No archive, merge, release or deployment authorization is implied.
