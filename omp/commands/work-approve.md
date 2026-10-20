---
description: Record a human decision after review.
---

## Rule loading

Read `RULES.md`, `rules/core.md`, and `rules/gates.md`. Load a stage-specific rule file only when the pending decision requires it.
## Load and gate

- Always read installed shared `RULES.md` and `rules/core.md` from `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`, then project `.omp/RULES.md` if present as additive policy. Resolve stage-rule paths under that shared base per its entrypoint. Stop if any required shared or applicable project policy is unreadable. Apply its dependencies, artifact ownership, stricter gates, freshness protocol and human-checkpoint format.
- Change slug: $1. Target: $2. Accept only `interview`, `spec`, `test-plan` or `tasks`; `spec` means the complete route/schema bundle, not a standalone PRD/design.
- Decision: `$3` plus any following words if supplied (`approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`). Read existing artifacts, `approvals.md`, `review.md` and `verification.md`. Never overwrite their history.
- Re-enumerate files and recompute all upstream SHA-256 manifests. Require earlier approvals/reviews current, no blocking questions and an independent target review PASS bound to the exact proposed input manifest.
- Run manifest hashing and other shell checks through `rtk` per shared rules; preserve raw digest output, not a filtered summary.
- If the target review is missing or stale, dispatch the independent reviewer first; add a separate security-engineer for security-sensitive `spec` scope or a credible security risk, otherwise require the reviewer's security-N/A rationale. Present the checkpoint after required reviews. Missing required independent dispatch means BLOCKED; never self-review.

## Present the decision

- Build the sorted relative-path/SHA-256 manifest for the target: interview inputs; spec adds every route/schema specification input including proposal and delta specs; test-plan adds `test-plan.md`; tasks adds the full preceding bundle and `tasks.md`. Include OpenSpec config/schema inputs; exclude mutable ledgers. Detect added and missing paths.
- Show artifact paths, one-line scope, acceptance criteria, risks, review findings and manifest identity. For tasks, require successful installed OpenSpec validation.
- Present one checkpoint: `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`. If a decision was supplied, validate it; if not, ask once and wait. Invocation, silence, "continue" or reviewer PASS is not a decision.

## Record and hand off

- `approve`: recompute the manifest after the decision. If unchanged, append target, UTC timestamp, human decision quote, full manifest and matching review record to `approvals.md`; then continue to the next stage in the same turn unless `stop`. Changed inputs mean renewed review and confirmation.
- `approve stop`: record the same way and stop. `reject: <reason>`: append the rejection as a decision without approval, route to the responsible author and stop. `revisit: <question/stage>`: reopen the named stage; changed inputs invalidate dependent records. `pause`: write nothing and point to `/work-resume $1`.
- Next stages: interview → `/work-product-plan $1`; spec → `/work-qa $1`; test-plan → `/work-plan $1`; tasks → `/work-implement $1`. Do not archive, merge, release or skip another human gate.
