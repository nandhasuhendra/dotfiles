---
description: Record a human decision after review.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/gates.md`; load a stage rule only when the pending decision needs it. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Target: $2. Accept only `human-planning`, `execution` or `archive`; reject any other target name, including legacy `interview`/`spec`/`test-plan`/`tasks` names. `archive` requires a separate explicit request.
- Decision: `$3` plus following words when supplied (`approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`). Read existing artifacts, `approvals.md`, `review.md` and `verification.md` without rewriting their history.
- Recompute the target manifest and its full path set per `rules/gates.md`; never reuse an unverified digest or filtered summary.

## Verify prerequisites

- `human-planning`: `interview.md`, applicable `prd.md`/`design.md` and `task-breakdown.md` present; independent review PASS bound to the same manifest; no blocking question.
- `execution`: that complete human bundle with fresh `human-planning` approval, plus proposal, every delta spec, `test-plan.md`, `tasks.md`, OpenSpec config/schema inputs, successful installed-schema validation evidence, REQ/TC/task coverage, and independent review PASS. Add a security-engineer PASS when scope is security-sensitive or a credible risk exists; otherwise require the reviewer's specific N/A rationale.
- `archive`: review-ready evidence (required scenarios PASS, independent QA and reviewer PASS for current inputs, validation PASS, no blocking defect) plus a separately requested archive authorization.
- Missing or stale review: dispatch the independent reviewer (and security engineer when required) first. Missing required independent dispatch or evidence means BLOCKED; never self-review or infer PASS.

## Present the decision

- Show artifact paths, one-line scope/risk, findings, review identities, validation evidence and manifest identity using the checkpoint format from `rules/gates.md`.
- Present one checkpoint via built-in `ask`: `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`, each with its consequence. If a decision was supplied, validate it against current inputs; otherwise ask once and wait. Invocation, silence, "continue" or a reviewer PASS is not a decision.

## Record and hand off

- `approve`: recompute the manifest after the decision. If unchanged, append target, UTC timestamp, decision reference/quote, full manifest and matching review reference to `approvals.md`; if changed, disclose the delta and ask again.
- `approve stop`: record and stop. `reject: <reason>`: append the rejection as a decision without approval, route to the responsible author and stop. `revisit: <question/stage>`: reopen that stage and invalidate dependent records. `pause`: write nothing and point to `/work-resume $1`.
- Next stage: `human-planning` → `/work-prepare $1`; `execution` → `/work-implement $1`; `archive` → `/work-archive $1` proceeds under its recorded authorization.
- Never record approval on the operator's behalf. Approval of one target never authorizes another, and no approval implies merge, release or deployment.
