---
description: Ship work through GitHub (git), OpenSpec archival (archive), or the full release flow (full), behind a mandatory quality gate.
---

# /work-ship $ARGUMENTS

Role: release orchestrator in this session. Keep approvals and irreversible GitHub operations here (`question` for choices); mechanical checks may be delegated only when useful.

## Select mode

Modes: `git` (verify, semantic commit, push, PR — no OpenSpec), `archive` (validate + archive OpenSpec only), `full` (both). If the only argument is a mode, use it with no slug; otherwise first argument = slug, second = optional mode. Mode omitted → ask via `question`. Never infer a mode from branch/state/prior invocations; reject unknown modes.

## Quality gate — mandatory for every mode

1. Require quality-gate approval from the current session.
2. Evidence path: `openspec/changes/<slug>/quality/` with a slug; else `.omp-quality/<sanitized-branch>/`. No matching evidence → stop and direct the user to `/work-build review-and-qa`.
3. Automated review + QA requires both `review.md` and `qa.md` PASS; `qa-only` alone is never sufficient for the full ship gate. Compare the recorded fingerprint (base/merge-base, HEAD SHA, diff hashes, untracked hashes, filtered status, diff stat) to the current workspace — any mismatch = stale evidence, stop and rerun the quality action. For UI changes, require the QA report to cite real Playwright MCP evidence (navigate, snapshot, console and network); static reasoning is not evidence.
4. Read `security.md` from the same evidence path and apply the risk-trigger result:
   - `status: PASS` with a fingerprint matching the current workspace satisfies the security gate. Summarize confirmed medium/low/informational findings and every needs-validation lead in the PR/commit summary.
   - `status: not_triggered` is valid only when the current diff really crosses no trigger; if it does, treat the evidence as stale.
   - `FAIL`, `BLOCKED`, missing, mismatched fingerprint or an unevaluated diff stops the ship and directs the user to `/work-build [slug] review-and-qa` (or the branch form). Never describe a `quick` audit as a complete security review.
5. If human review was chosen during build, obtain fresh `question` confirmation that the user reviewed the current diff and verified behavior/acceptance criteria.
6. Unknown quality state (resumed/new session) → ask via `question`; incomplete manual review → stop and direct to `/work-build review-and-qa`.
7. Any changed application diff invalidates prior review/QA/security evidence; never silently reuse stale reports.

## Shared preflight

1. `git status` + `git diff --stat` (through `rtk` when available). 2. Identify the exact files in scope; stop if unrelated changes, scratch files, debug logs or build artifacts would be included — never silently discard or stage unrelated work. 3. Confirm current branch and intended base branch before any GitHub operation.

## Resolve spec effect before archive

A bare `openspec archive <slug> -y` merges delta specs into `openspec/specs/`. Resolve this explicitly before every archive (use `rtk openspec` when rtk exists):

- `.openspec.yaml` has `skip_specs: true` → `openspec archive <slug> -y`.
- Otherwise inspect `openspec/changes/<slug>/specs/`: no deltas → add `--skip-specs` so the baseline stays untouched; deltas present → use `question` to choose merge vs `--skip-specs`. Recommend `--skip-specs` while no active specs are intended; merge only on explicit request.
- Never run bare `archive -y` on a delta-bearing change; never move directories manually.

## Mode: git

Do not validate/archive OpenSpec. Run relevant required checks for the shipped changes; report unavailable checks as `NOT_RUN` — never claim they passed. Stage only explicitly intended files, inspect `git diff --cached`, one semantic commit, push (set upstream when needed), open a PR against the confirmed base with a concise summary and actual evidence. Report commit hash, branch, PR URL, checks not run.

## Mode: archive

Every task in `tasks.md` checked; `openspec validate <slug>` fixed; apply "Resolve spec effect before archive" and use the chosen archive command (never move directories manually); re-inspect `git status`/`diff --stat` and `openspec list --specs`; stop without commit/push/PR. Report archive path, active spec count and remaining changes.

## Mode: full

All tasks checked → run required regression suites, linters and typecheckers (`git diff --stat` is not a test) → validate → apply "Resolve spec effect before archive" → archive → confirm only intended changes remain via diff and `openspec list --specs` → stage, inspect `git diff --cached`, one semantic commit → verify clean tree → push + PR. Report commit hash, archive path, active spec count, branch, PR URL, checks not run.

Do not merge, deploy or release without a separate explicit request.
