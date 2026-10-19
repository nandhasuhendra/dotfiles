---
description: Resume a change at its current gate.
---

## Rule loading

Read `RULES.md` and `rules/core.md`. Load `rules/gates.md` and the relevant stage rule only when checking or reopening a gate.
## Load and reconstruct

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read existing `openspec/changes/$1/` artifacts, repository instructions, append-only review/approval history, implementation evidence and current repository state. Do not overwrite existing work or initialize a missing change.
- Re-enumerate inputs and recompute all upstream sorted path/SHA-256 manifests. Compare bytes and full path sets, including OpenSpec config/schema inputs. Changed, missing or added inputs invalidate dependent approvals/reviews/tasks/verification, even when old records say PASS.
- Run manifest hashing and other shell checks through `rtk` per shared rules; preserve raw output and exit status.
- Check route-required artifacts, blocking questions, independent target reviews, explicit human decisions, validation and task completion evidence. Keep approved `tasks.md` frozen and read execution completion from `verification.md`.
- Compare verification against current source identity including dirty tracked files, relevant untracked files and deletions; HEAD alone is insufficient. Mark absent, stale, failed or unrun evidence honestly.

## Resume only permitted work

- Present `Gate | Evidence/freshness | Blocker | Next command`, citing the actual artifacts/digest comparisons and dependency limitations. Determine the earliest incomplete or invalidated gate; never infer an unrecorded approval.
- If a human decision is pending, present the shared checkpoint with the disclosed scope, review result, manifest identity and the options `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`. Record the reply using the same protocol; on `approve`, continue to the permitted next stage. Do not interpret "resume" as approval.
- Otherwise continue only the permitted stage using its existing command instructions: interview, spec, QA, task planning, implementation, independent review or independent verification. Recheck that stage's upstream gates immediately before acting. Stage commands run their own review and end at the next checkpoint; do not send the human away to run `/work-review` or `/work-approve`.
- Dispatch the applicable author role or disclose author-role adoption when unavailable. Independent reviewer/verification roles require separate agent runs; unavailable dispatch means BLOCKED, never self-review.
- Material scope changes return to interview/spec; changed QA expectations return to QA review/approval. Do not skip stale gates, alter approved tasks or chain past a human boundary.

## Handoff

- Record evidence, assumptions, risks and the next gate in the stage's existing artifact; keep approval/review history append-only.
- Report only work actually performed, observed outcomes and the next allowed command. No fabricated completion, checks, delegation or automatic archive/merge/release.
