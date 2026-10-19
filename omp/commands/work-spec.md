---
description: Legacy compatibility route; use work-prepare after human planning approval.
---
## Compatibility route\n\nThis command is no longer the authoring stage for human PRDs or Tech Docs. Use `/work-product-plan`, `/work-tech-plan` and `/work-doc-review` first.\n\n## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read `openspec/changes/$1/` artifacts, repository instructions, existing specs and relevant source before editing.
- Re-enumerate inputs and recompute upstream SHA-256 manifests. Require a complete human planning bundle (`prd.md` when applicable, `design.md` when applicable, and `task-breakdown.md`), independent document review PASS and explicit human planning approval against matching current inputs. Missing, stale or changed/missing/added inputs block this transition; do not renew approvals yourself.

## Deprecated authoring flow

- Use `/work-prepare $1` as the canonical implementation-preparation stage. Do not use this legacy command to bypass human planning approval; follow the `work-prepare` instructions.
- Follow the interview route: product requires `prd.md`; engineering requires `design.md`; mixed requires both. Product also needs design when technical decisions or the installed schema require it.
- Resolve/read `PRD.md` and/or `TECH-DOC.md` through shared template rules before authoring. Pass the applicable template paths/content to the authors; preserve installed OpenSpec schema requirements.
- Inspect installed OpenSpec help, config and artifact instructions. Produce its required `proposal.md`, delta `specs/**/spec.md` and design artifacts without competing requirements. Leave implementation task planning to its later gate.
- Run shell commands through `rtk` per shared rules. Record actual OpenSpec, Ponytail, Codegraph, Context7 and RTK invocations in Evidence; keep raw failure output for gates.
- Preserve stable `REQ-` IDs and traceable acceptance criteria. Record scope, non-goals, compatibility, assumptions, unresolved questions and evidence; include technical impact, failure/security risks and rollout/rollback where applicable.
- Use Codegraph and source confirmation for impact; use Context7 for version-relevant library/API decisions, with shared-rule fallbacks and limitations. Do not implement or create implementation tests.
- Record input paths/digests and invalidate downstream records when specification inputs change; never edit historical approvals.

## Review and checkpoint

- After authoring, dispatch the independent security-engineer first for `spec`, then the independent spec reviewer with that assessment. Repair CHANGES_REQUESTED once and re-review; if it still fails, present the findings and stop for the human.
- On PASS, present the shared checkpoint with the bundle paths, scope/risks, review/security verdicts, manifest identity and the options `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`.
- `approve`: record spec approval with the shared protocol, then continue to `/work-qa $1` in the same turn. `approve stop`: record and stop.
- `reject` routes to the responsible author with the stated reason; `revisit` reopens the named interview/spec question and requires renewed review before approval; `pause` points to `/work-resume $1`.
- Do not require the human to run `/work-review` or `/work-approve` after this command.
