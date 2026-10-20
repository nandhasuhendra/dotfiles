---
description: Review artifacts and present the human decision.
---

## Rule loading

Read `RULES.md` and `rules/core.md`; load `rules/gates.md` and only the stage rule(s) relevant to the review target.
## Load and gate

- Always read installed shared `RULES.md` and `rules/core.md` from `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`, then project `.omp/RULES.md` if present as additive policy. Resolve stage-rule paths under that shared base per its entrypoint. Stop if any required shared or applicable project policy is unreadable. Apply its dependencies, artifact ownership, stricter gates and freshness protocol.
- Change slug: $1. Optional target: $2 (`interview`, `spec`, `test-plan`, `tasks`). Infer the current target only when existing artifacts and fresh approvals identify it unambiguously; otherwise ask which target, without inventing readiness.
- Read existing change artifacts, reviews and approvals under `openspec/changes/$1/`. Re-enumerate inputs and recompute upstream SHA-256 manifests. Require the preceding target approvals/reviews to be current before reviewing a dependent gate; the target itself does not require approval yet.
- Check completeness, unresolved blocking questions and route/schema requirements. Changed/missing/added inputs invalidate dependent records, regardless of prior PASS or file timestamps.
- If a current matching review PASS already exists for this target and manifest, skip the dispatch and present the checkpoint. Re-run only when inputs changed, the target changed, or the human asks for a re-review.

## Independent review

- Build the target's complete sorted relative-path/SHA-256 manifest exactly as shared rules require for its approval, including upstream and OpenSpec config/schema inputs; exclude mutable ledgers.
- For security-sensitive `spec` reviews or a credible security risk, first dispatch an independent security-engineer with the same manifest for red-team attack paths and blue-team controls. Require its fresh PASS before reviewer PASS; missing required dispatch or unresolved findings blocks approval. Otherwise the reviewer records a security-N/A rationale. For `test-plan` and `tasks`, require recorded security-scenario and mitigation coverage when applicable.
- Dispatch a separate reviewer agent with the target, full artifact/source context, manifest, author identities, security assessment, previous findings and gate criteria. It must be independent of the reviewed authors and security run. No self-review or role-adoption fallback: if dispatch or independence is unavailable, append BLOCKED with the reason.
- Require completeness/consistency, REQ traceability, compatibility/security risks and evidence-based findings. For specs check route-required PRD/design plus proposal/delta specs; for QA check every REQ's scenarios/regressions; for tasks check executable dependencies, TC coverage, approved scope and OpenSpec validation evidence.
- Run agent shell commands through `rtk` per shared rules. Check the handoff Evidence line for actual OpenSpec, Ponytail, Codegraph, Context7, Playwright and RTK invocations; missing required evidence or N/A reasons prevents PASS.
- Re-enumerate and recompute inputs when review returns. If they changed, retain the result only as historical evidence and request a fresh review; do not label it a current PASS.
- Append a record to `review.md`: target, reviewer identity/run, UTC timestamp, full input manifest, PASS/CHANGES_REQUESTED/BLOCKED, concrete file/line findings, unresolved risks and next gate. Preserve prior records.

## Present and record

- On PASS, present the shared human checkpoint: target, artifacts, what changed, findings/risks, manifest identity and the options `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`.
- `approve`: record the decision with the approval protocol, then continue to the next stage in the same turn. Interview → `/work-product-plan $1`; spec → `/work-qa $1`; test-plan → `/work-plan $1`; tasks → `/work-implement $1`.
- `approve stop`: record and stop. `reject`: record without approval and route to the responsible author. `revisit`: reopen the named stage and invalidate dependent records. `pause`: record nothing and point to `/work-resume $1`.
- On CHANGES_REQUESTED, route findings to the author, allow one repair and re-review, then present the findings with the same decision menu if it still fails. Never treat the review command's invocation as approval.
- `work-approve` remains available for resuming a pending decision, but this command must not send the human away to run it after a PASS.
