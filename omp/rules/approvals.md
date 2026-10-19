# Approval and freshness protocol

Load when recording, checking, invalidating, or renewing approvals and reviews.

## Approval and freshness protocol

These are agent-enforced gates, not a runtime access-control mechanism. There is no `scripts/workflow_gate.py`; do not call it or claim automated enforcement.

1. Build a sorted manifest of relative artifact paths and SHA-256 file digests. Use real hashing tools, such as `sha256sum` on Linux or `shasum -a 256` on macOS. Never invent hashes.
2. Bind interview approval to `interview.md`; human planning approval to interview plus `prd.md`, `design.md` when applicable, and `task-breakdown.md`; spec approval to the human planning bundle plus all route/schema specification inputs (including proposal and every delta spec); test-plan approval to those inputs plus `test-plan.md`; tasks approval to all previous inputs plus `tasks.md`. Include OpenSpec config/schema inputs used by the change. Exclude the mutable approval/review/evidence ledgers themselves.
3. Reviewer records PASS against the same input manifest for that gate. Show the human artifact paths, review findings, short scope/risk summary and manifest before asking approval.
4. After an explicit human decision, recompute the manifest. If unchanged, append target, UTC timestamp, human decision reference/quote, manifest and matching review record to `approvals.md`. If changed during the decision, ask again. Never modify historical decisions.
5. Before proceeding or resuming, re-enumerate files and recompute every upstream manifest. Changed bytes, missing files or new specification inputs invalidate that gate and all dependent approvals/reviews/tasks/verification. Treat prior records as historical, not current authority.
6. Freeze approved `tasks.md` content. Track execution completion and evidence separately in `verification.md` so checkbox edits do not silently invalidate task approval. Reconcile OpenSpec task checkboxes only after verification and human archive authorization; record that completion-only reconciliation and rerun validation. Any task wording/scope change requires renewed task review/approval.
7. Bind final verification to current source: record HEAD plus a digest manifest of changed tracked and relevant untracked files (including deletions), or a full relevant-source manifest outside Git. HEAD alone does not identify a dirty worktree. Source/test/config changes invalidate verification; rerun affected checks and independent review.
## Human checkpoints

Every stage ends with exactly one checkpoint, not a chain of questions. Keep it scannable:

```text
Stage: <stage> | review: <PASS/CHANGES_REQUESTED/BLOCKED>
Artifacts: <paths or "none">
Reviewed: <what changed since the last decision>
Open questions: <none or blocking list>
Decision: approve | approve stop | reject: <reason> | revisit: <question/stage> | pause
```

- `approve`: record the decision with the approval protocol, then continue to the next stage in the same turn.
- `approve stop`: record the decision and stop. The next stage remains available.
- `reject: <reason>`: record the rejection without approval, route to the responsible author and stop.
- `revisit: <question/stage>`: reopen that stage; changed inputs invalidate dependent approvals/reviews/tasks/verification.
- `pause`: record nothing and point to `/work-resume <slug>`.
- One explicit reply is enough. Do not ask for the same decision twice; do not make the human re-run review after a PASS unless inputs changed.
- Show artifact paths, a one-line scope/risk summary, review findings and the manifest identity before asking. Invocation, silence, "continue" or an earlier approval is not a decision.
- `work-doc-review` reviews the human planning bundle before OpenSpec; `work-review` performs later independent gate reviews and presents this checkpoint. `work-approve` resumes a pending decision or records one supplied after a review.
