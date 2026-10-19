---
description: Record explicit human approval of an artifact.
---
## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Target: $2. Accept only `interview`, `spec`, `test-plan` or `tasks`; `spec` approves the complete route/schema bundle, not a standalone PRD/design.
- Read existing artifacts and the append-only `approvals.md` and `review.md` under `openspec/changes/$1/`. Never overwrite their history.
- Re-enumerate files and recompute all upstream SHA-256 manifests. Require all earlier approvals and independent reviews to remain current, the target to be complete without blocking questions, and an independent target review PASS bound to the exact proposed input manifest. If review is missing or stale, next is `/work-review $1 $2`; stop.

## Present the decision

- Build the sorted relative-path/SHA-256 manifest using real hashing tools and the shared protocol:
  - `interview`: interview inputs.
  - `spec`: interview plus every route/schema specification input, including proposal and delta specs.
  - `test-plan`: the spec inputs plus `test-plan.md`.
  - `tasks`: the entire preceding artifact bundle plus `tasks.md`.
- Include OpenSpec config/schema inputs used by the change; exclude mutable approval, review and evidence ledgers. Detect added and missing inputs, not just hash changes in previously listed files.
- Show artifact paths, scope, acceptance criteria, risks, the manifest and matching review findings. For tasks, also require successful installed OpenSpec validation.
- Ask the human explicitly to approve this target and disclosed manifest. Invocation alone, silence, a generic "continue", reviewer PASS or an earlier approval is not confirmation. Do not self-approve.

## Record and stop

- After explicit confirmation, re-enumerate and recompute the manifest and upstream freshness. If anything changed during the decision, do not append approval; present the changed scope for renewed review/confirmation.
- Only if unchanged, append target, UTC timestamp, human decision reference/quote, complete manifest and matching review record to `approvals.md`. Record rejections as decisions without granting approval; preserve earlier entries.
- Record evidence and the next gate: interview → `/work-spec $1`; spec → `/work-qa $1`; test-plan → `/work-plan $1`; tasks → `/work-implement $1`. Do not automatically execute the next stage.
