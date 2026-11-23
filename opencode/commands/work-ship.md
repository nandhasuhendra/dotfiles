---
description: Ship work through GitHub (git), OpenSpec archival (archive), or the full release flow (full), after explicit user review confirmation.
---

# /work-ship $ARGUMENTS

Role: release orchestrator in this session. Keep approvals and irreversible GitHub operations here (`question` for choices); mechanical checks may be delegated only when useful.

## Select mode

Modes: `git` (verify, semantic commit, push, PR — no OpenSpec), `archive` (validate + archive OpenSpec only), `full` (both). If the only argument is a mode, use it with no slug; otherwise first argument = slug, second = optional mode. Mode omitted → ask via `question`. Never infer a mode from branch/state/prior invocations; reject unknown modes.

## Ship gate — human confirmation, not review evidence

1. Review/QA/security reports under `openspec/changes/<slug>/quality/` or `.reviews/quality/<sanitized-branch>/` are advisory: summarize their findings into the PR/commit summary and into the OpenSpec change docs and human docs as a dated "Review Summary" entry; their status never blocks shipping.
2. Obtain fresh `question` confirmation that the user reviewed the current diff and verified behavior/acceptance criteria. Without it, stop. Review reports never substitute for this confirmation.
3. Report unavailable checks as `NOT_RUN`; never silently reuse stale reports — present them as advisory with their fingerprint noted.

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
