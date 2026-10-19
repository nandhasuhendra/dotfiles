---
description: Produce implementation task breakdown.
---
## Rule loading

Load `RULES.md`, `rules/core.md`, `rules/planning.md`, and `rules/gates.md` for approval/freshness checks.

## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read existing `openspec/changes/$1/` artifacts and repository conventions before editing.
- Re-enumerate inputs and recompute upstream SHA-256 manifests. Require current interview/spec/test-plan human approvals and matching independent review PASS records, complete route/schema inputs and QA coverage for every `REQ-`. Changed, missing or added inputs invalidate dependent records; stop if evidence is missing or stale.

## Plan tasks

- Dispatch tech-lead with the approved bundle. If author dispatch is unavailable, adopt its instructions and disclose it.
- Inspect installed OpenSpec help/config/schema instructions; create or update its `tasks.md` format, preserving existing artifact content unless a reviewed change is needed.
- Run shell commands through `rtk` per shared rules. Record actual OpenSpec, Ponytail, Codegraph, Context7 and RTK invocations in Evidence; keep raw failure output for gates.
- Resolve/read `TASK-BREAKDOWN.md` through shared template rules and pass it to tech-lead. Use it as a handoff/content checklist within the installed OpenSpec task format, not a replacement schema.
- Produce small ordered implementation and test tasks linked to `REQ-`/`TC-` IDs, affected files/callers, dependencies, acceptance evidence and rollout/rollback. Include independent verification and real smoke coverage, with Playwright for browser changes.
- Read Ponytail and use confirmed source/Codegraph impact to choose the smallest complete implementation. Record dependency limitations, assumptions and blocking questions.
- Record the full planning-bundle input manifest. Any changed task wording or upstream scope requires renewed affected review/approval; do not alter approved artifacts to force readiness.
- No application code, production configuration, migrations or implementation tests.

## Review and checkpoint

- After planning, run installed OpenSpec validation and record the actual result. Dispatch the independent tasks reviewer; repair CHANGES_REQUESTED once and re-review, then present findings if still failing.
- On PASS, present the shared checkpoint with `tasks.md`, validation result, complete planning-bundle manifest and the options `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`.
- `approve`: record tasks approval with the shared protocol, then continue to `/work-implement $1` in the same turn. `approve stop`: record and stop.
- `reject` routes to tech-lead with the reason; `revisit` reopens the named plan/spec question and invalidates dependent records; `pause` points to `/work-resume $1`.
- Do not require the human to run `/work-review` or `/work-approve` after this command.
