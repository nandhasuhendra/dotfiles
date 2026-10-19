---
description: Resume a change at its current gate.
---
## Load and reconstruct

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read existing `openspec/changes/$1/` artifacts, repository instructions, append-only review/approval history, implementation evidence and current repository state. Do not overwrite existing work or initialize a missing change.
- Re-enumerate inputs and recompute all upstream sorted path/SHA-256 manifests. Compare bytes and full path sets, including OpenSpec config/schema inputs. Changed, missing or added inputs invalidate dependent approvals/reviews/tasks/verification, even when old records say PASS.
- Check route-required artifacts, blocking questions, independent target reviews, explicit human decisions, validation and task completion evidence. Keep approved `tasks.md` frozen and read execution completion from `verification.md`.
- Compare verification against current source identity including dirty tracked files, relevant untracked files and deletions; HEAD alone is insufficient. Mark absent, stale, failed or unrun evidence honestly.

## Resume only permitted work

- Present `Gate | Evidence/freshness | Blocker | Next command`, citing the actual artifacts/digest comparisons and dependency limitations. Determine the earliest incomplete or invalidated gate; never infer an unrecorded approval.
- If a human decision is pending, show the scope and correct `/work-approve $1 <target>` or archive-authorization step, then stop. Do not interpret "resume" as approval.
- Otherwise continue only the permitted stage using its existing command instructions: interview, spec, QA, task planning, implementation, independent review or independent verification. Recheck that stage's upstream gates immediately before acting.
- Dispatch the applicable author role or disclose author-role adoption when unavailable. Independent reviewer/verification roles require separate agent runs; unavailable dispatch means BLOCKED, never self-review.
- Material scope changes return to interview/spec; changed QA expectations return to QA review/approval. Do not skip stale gates, alter approved tasks or chain past a human boundary.

## Handoff

- Record evidence, assumptions, risks and the next gate in the stage's existing artifact; keep approval/review history append-only.
- Report only work actually performed, observed outcomes and the next allowed command. No fabricated completion, checks, delegation or automatic archive/merge/release.
