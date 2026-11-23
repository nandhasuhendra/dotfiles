---
name: work-build
description: Implement approved OpenSpec tasks atomically, run focused checks, then perform review and QA or QA-only without bypassing gates.
---

# /work-build [slug] [review-and-qa|qa-only]

Parse arguments strictly. Unknown actions or extra arguments are BLOCKED before edits. Always use the built-in `ask_question` tool whenever asking the user any question or confirmation. Normal implementation requires a slug and explicit Gate 2 Approved in this conversation for the exact current spec fingerprint. If absent (including after resuming/new session), use `ask_question` to ask for Gate 2 reconfirmation and STOP.

## Normal implementation

1. Require `openspec/changes/<slug>/proposal.md`, `design.md`, `tasks.md`; read them and current Git status/diff. Recompute spec fingerprint. If spec changed after approval, STOP and require reapproval via `ask_question`.
2. Execute one discrete unchecked task at a time. Modify only files declared by that task. Inspect callers/impact and tests before editing. Install only dependencies approved in design.md, using the repository's canonical package manager.
3. Run focused tests, linter/typecheck; for UI use Playwright MCP and record actual observations. Preserve command exit codes and failures.
4. Circuit breaker: after two failed repair attempts for the same check, stop and report blocker.
5. Mark a task complete only after verification passes. Validate OpenSpec and summarize diff when all tasks complete. Do not run full regression here; /work-ship owns it.
6. Use the built-in `ask_question` tool to ask whether to run `review-and-qa` now or leave human review pending. Do not choose automatically.

## review-and-qa

Quality-only: no source, tests, or spec edits. Resolve target as full branch diff against open PR base (or configured default branch) plus tracked/untracked working-tree changes. If base is ambiguous, use `ask_question` to clarify. No meaningful diff => BLOCKED. Dispatch at most 2 subagents (one `code-reviewer`, one `qa-engineer`, in a single parallel batch).

Security trigger: when the diff touches auth/session/identity, authorization/tenant scope, secrets/crypto, untrusted input/sinks, network/proxy/cookies/CORS, dependency/CI/container/IaC, filesystem/process/plugin boundaries, LLM tool boundaries, or user-data migrations/exports/deletions — or review/QA flags a security concern — do NOT dispatch extra subagents: write `security.md` with `status: deferred`, the trigger reasons and a pointer to the standalone security audit; otherwise `status: not_triggered`.

Review/QA results are advisory evidence for the user: summarize them into the change docs and human docs as a dated "Review Summary" entry; they never gate build completion or ship. Report FAIL findings and BLOCKED evidence to the user; quality-only actions never fix findings.
