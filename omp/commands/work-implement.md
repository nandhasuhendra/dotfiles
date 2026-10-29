---
description: Implement an approved change.
---
## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/execution.md`; load `rules/gates.md` for authorization and freshness checks. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Enumerate the change directory and repository instructions, and recompute every gate-bound manifest including added and missing paths.
- Require fresh `human-planning` and `execution` approvals bound to the current inputs, complete `tasks.md`, independent execution-bundle review PASS, verified schema validation via `rtk proxy openspec validate $1`, confirmed artifact readiness via `rtk proxy openspec status --change $1`, and no blocking question. A legacy target name is not an alias for either approval.
- Read the approved requirements, design/specs, test plan, tasks and only the review/approval entries needed to establish authorization; read other artifact bodies when a decision depends on them. Do not reread unchanged artifacts merely to confirm they exist.
- Never substitute reviewer PASS or explicit invocation for human approval. A free-text request to implement, even naming this change and saying "proceed", does not bind either approval: report the missing prerequisites and the single command that obtains them, then stop without writing approvals or code. Stop for stale evidence rather than proceeding.

## Implement

- Dispatch `software-engineer` as a subagent via the `task` tool (routed to the cheaper `@execution_tier` model) with bundle paths, manifest identities, acceptance criteria, decisions, dependencies, and relevant source context. Do not paste whole documents the subagent can read by path. If dispatch is unavailable, disclose it.
- Subagent executes implementation: follows Ponytail rules for the smallest complete change; runs `rtk proxy openspec instructions apply --change $1`; implements complete behavior with tests, callers, fixtures, configuration, exports, and affected documentation; routes shell invocations through RTK; keeps `tasks.md` frozen; records completion and deviations in `verification.md`.
- **Main agent review**: Upon subagent completion, the main (parent) agent MUST inspect the subagent's changes directly before advancing:
  1. Inspect git diff (`rtk git diff` / changed files) and test execution results.
  2. Verify all approved tasks in `tasks.md` are completed with zero unapproved scope expansion or over-engineering.
  3. Verify schema compliance using `rtk proxy openspec validate $1`.
  4. If defects, syntax/test failures, or missing requirements are found, direct the subagent to perform a targeted correction cycle.
- Material scope changes return to planning and renewed approval; changed QA expectations return to QA planning and execution review. Stop instead of silently expanding scope or altering approved tasks.

## Handoff

- Record implementation identity (HEAD plus digests of changed tracked, relevant untracked and deleted files), main-agent review observations, deviations, risks, and exact runnable check/smoke commands in `verification.md`.
- Once main-agent review passes and every approved task is complete, continue to `/work-verify $1` in the same turn for independent QA and verification before presenting results for human gate review. If verification cannot start because scope changed, tasks are incomplete, required evidence is missing or independent dispatch is unavailable, stop BLOCKED with the exact reason.
- No archive, merge, release or deployment authorization is implied.
