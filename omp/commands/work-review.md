---
description: Review current artifacts for gate readiness.
---
## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Optional target: $2 (`interview`, `spec`, `test-plan`, `tasks`). Infer the current target only when existing artifacts and fresh approvals identify it unambiguously; otherwise ask which target, without inventing readiness.
- Read existing change artifacts, reviews and approvals under `openspec/changes/$1/`. Re-enumerate inputs and recompute upstream SHA-256 manifests. Require the preceding target approvals/reviews to be current before reviewing a dependent gate; the target itself does not require approval yet.
- Check completeness, unresolved blocking questions and route/schema requirements. Changed/missing/added inputs invalidate dependent records, regardless of prior PASS or file timestamps.

## Independent review

- Build the target's complete sorted relative-path/SHA-256 manifest exactly as shared rules require for its approval, including upstream and OpenSpec config/schema inputs; exclude mutable ledgers.
- For `spec`, first dispatch an independent security-engineer with the same manifest and full context for red-team attack paths and blue-team controls/mitigations. Require its fresh PASS in `review.md` before reviewer PASS; missing dispatch or unresolved findings blocks approval. For `test-plan` and `tasks`, require coverage of the recorded security scenarios and mitigation work.
- Dispatch a separate reviewer agent with the target, full artifact/source context, manifest, author identities, security assessment, previous findings and gate criteria. It must be independent of the reviewed authors and security run. No self-review or role-adoption fallback: if dispatch or independence is unavailable, append BLOCKED with the reason.
- Require completeness/consistency, REQ traceability, compatibility/security risks and evidence-based findings. For specs check route-required PRD/design plus proposal/delta specs; for QA check every REQ's scenarios/regressions; for tasks check executable dependencies, TC coverage, approved scope and OpenSpec validation evidence.
- Re-enumerate and recompute inputs when review returns. If they changed, retain the result only as historical evidence and request a fresh review; do not label it a current PASS.
- Append a record to `review.md`: target, reviewer identity/run, UTC timestamp, full input manifest, PASS/CHANGES_REQUESTED/BLOCKED, concrete file/line findings, unresolved risks and next gate. Preserve prior records.

## Handoff

- PASS permits `/work-approve $1 <target>` to ask the human; it is not approval itself.
- CHANGES_REQUESTED returns to the responsible author; BLOCKED names missing evidence or dispatch. Record the next command and never chain past the human decision.
