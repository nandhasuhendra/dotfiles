---
name: work-ship
description: Run final verification, summarize advisory review evidence, commit and open a PR, or archive an OpenSpec change with explicit user authorization.
---

# /work-ship [slug] [git|archive|full]

This is the release orchestrator. No merge, deploy, or release. Always use the built-in `ask_question` tool when asking any question or requesting explicit user confirmation in the current conversation before irreversible GitHub or archive operations. Parse mode strictly; default git.

## Ship gate — explicit user confirmation

Before any ship mode that commits/pushes, resolve the exact target diff. Review/QA/security reports are advisory: summarize their findings into the PR/commit summary and into the change docs and human docs as a dated "Review Summary" entry; their status never blocks shipping. Shipping requires only the user's explicit confirmation via `ask_question`, in this conversation, that they reviewed the current diff and acceptance criteria. P0/P1 findings are surfaced prominently for that decision.

## git mode

Run relevant regression tests, linters and typechecks; report unavailable checks NOT_RUN. Stage only intended files, inspect staged diff, create one semantic commit, verify clean/expected state, push current branch with upstream as needed, and open PR against confirmed base branch. Do not fabricate verification. Report commit, branch, PR URL, and NOT_RUN checks.

## archive mode

Require all tasks checked, validate OpenSpec, and use `ask_question` to ask the user whether to merge spec deltas or archive with skip-specs. Archive only through OpenSpec CLI; do not commit/push/open PR. Reinspect active specs and working tree.

## full mode

Require all tasks checked; run full regression, lint/typecheck, OpenSpec validation, explicit spec-effect choice via `ask_question` and archive. Inspect staged diff, commit, verify clean, push and open PR. Report archive path, active spec count, commit, branch, PR, and NOT_RUN checks.

Never merge, deploy, or release without a separate explicit request.
