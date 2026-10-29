---
description: Resume a change at its current gate.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`; load `rules/gates.md` and only the stage rule for the permitted work. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and reconstruct

- Change slug: $1. Read the change artifacts, repository instructions, append-only review/approval history, implementation evidence and repository state. Do not overwrite existing work or initialize a missing change.
- Recompute every bundle's sorted path/SHA-256 manifest, including added and missing paths and OpenSpec config/schema inputs. Run `rtk proxy openspec status --change $1` and `rtk proxy openspec validate $1` to verify current schema and artifact status. Changed inputs invalidate dependent approvals, reviews, tasks and verification even when old records say PASS.
- Check route-required artifacts, blocking questions, independent verdicts, explicit human decisions, validation evidence and task completion. Keep `tasks.md` frozen and read completion from `verification.md`.
- Compare verification against current implementation identity including dirty tracked, relevant untracked and deleted files; HEAD alone is insufficient. Mark absent, stale, failed and unrun evidence honestly.
- For a legacy-target change, require an independently reviewed mapping and an explicit current-manifest human decision before using revised authority; never auto-implement or treat an old target as an alias.

## Resume only permitted work

- Present `Gate | Evidence/freshness | Blocker | Next command` from actual digest comparisons and dependency limits, and identify the earliest incomplete or invalidated step.
- If a human decision is pending, present the checkpoint for its target (`human-planning` or `execution`) via built-in `ask` and record the reply with the canonical protocol. "Resume", silence or a prior decision is not approval.
- Otherwise continue only the permitted stage using its existing command instructions: interview, human planning, `/work-review $1 human-planning`, `/work-prepare`, `/work-qa`, `/work-plan`, execution review, implementation, verification or an explicitly requested archive. Recheck that stage's prerequisites immediately before acting.
- Dispatch the applicable author role or disclose author-role adoption. Independent reviewer, QA and security runs require separate agent runs; unavailable dispatch means BLOCKED, never self-review.
- Material intent or scope changes return to human planning; changed QA expectations return to QA planning and execution review. Do not skip stale gates, alter approved tasks or chain past a human boundary.

## Handoff

- Record evidence, assumptions, risks and the next gate in the stage's existing artifact; keep approval and review history append-only.
- Report only work actually performed, observed outcomes and the next permitted command. No fabricated completion, checks, delegation or automatic archive/merge/release.
