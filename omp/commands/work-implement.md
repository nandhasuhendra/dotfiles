---
description: Implement an approved change.
---
## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Enumerate the change directory and repository instructions. Recompute manifests across every gate-bound input, but do not read every artifact body by default; read the complete approved requirements, design/specs, test plan, tasks and only the review/approval entries needed to establish current authorization. Retrieve other artifact bodies when a decision depends on them.
- Require current human interview/spec/test-plan approvals, complete tasks, matching independent review PASS records and explicit human tasks approval binding the full planning bundle. No unresolved blocking questions may remain.
- Inspect installed OpenSpec help/config and run its supported validation. Record the actual command/result; any failure, missing evidence or changed/missing/added input blocks implementation. Never substitute reviewer PASS for human approval.

## Implement

- Dispatch software-engineer with the approved bundle's paths, manifest identities, acceptance criteria, design decisions, task dependencies, relevant source context and gate evidence. Do not paste duplicate full documents into the handoff when the agent can read them directly. If author dispatch is unavailable, read and adopt its instructions and disclose that substitution. Never claim delegation or self-approve.
- Read Ponytail; map affected callers, tests, fixtures, config and exports. Use Codegraph with source confirmation and Context7 for version-relevant dependency/API decisions, recording shared-rule fallbacks.
- Run shell commands through `rtk` per shared rules. Record actual Ponytail, Codegraph, Context7 and RTK invocations in Evidence; keep raw failure output for gates.
- Follow approved REQ/TC IDs, design and task dependencies. Implement the complete behavior and its tests, preserve compatibility and error handling, and update affected documentation without unrelated changes.
- Keep approved `tasks.md` frozen, including checkboxes. Track each task's completion, changed files and implementation evidence separately in `verification.md`; mark unrun checks NOT_RUN, not PASS.
- Recheck manifests before each transition. Material scope changes return to interview/spec and renewed approval; changed QA expectations return to QA approval. Stop rather than silently expanding scope or changing approved tasks.
- Do not run build/lint/tests/formatters midflight. Hand completed work to independent verification rather than claiming author testing as independent QA.

## Handoff

- Record completed task evidence, deviations, remaining risks, runnable raw check/smoke commands and next gate in `verification.md`.
- When every implementation task is complete, continue to independent verification (`/work-verify $1`) in the same turn. Do not ask the human to run it.
- If verification cannot start because approved scope changed, tasks are incomplete, required checks are missing or independent dispatch is unavailable, stop BLOCKED with the exact reason.
- No archive, merge or release authorization is implied by implementation or verification.
