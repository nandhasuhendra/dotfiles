---
name: work-build
description: Implement approved OpenSpec tasks atomically, run focused checks, then perform review and QA or QA-only without bypassing gates.
---

# /work-build [slug] [review-and-qa|qa-only]

Parse arguments strictly. Unknown actions or extra arguments are BLOCKED before edits. Normal implementation requires a slug and explicit Gate 2 Approved in this conversation for the exact current spec fingerprint. If absent (including after resuming/new session), ask for reconfirmation and STOP.

## Normal implementation

1. Require `openspec/changes/<slug>/proposal.md`, `design.md`, `tasks.md`; read them and current Git status/diff. Recompute spec fingerprint. If spec changed after approval, STOP and require reapproval.
2. Execute one discrete unchecked task at a time. Modify only files declared by that task. Inspect callers/impact and tests before editing. Install only dependencies approved in design.md, using the repository's canonical package manager.
3. Run focused tests, linter/typecheck; for UI use Playwright MCP and record actual observations. Preserve command exit codes and failures.
4. Circuit breaker: after two failed repair attempts for the same check, stop and report blocker.
5. Mark a task complete only after verification passes. Validate OpenSpec and summarize diff when all tasks complete. Do not run full regression here; /work-ship owns it.
6. Ask whether to run review + QA or leave human review pending. Do not choose automatically.

## review-and-qa

Quality-only: no source, tests, or spec edits. Resolve target as full branch diff against open PR base (or configured default branch) plus tracked/untracked working-tree changes. If base ambiguous, ask. No meaningful diff => BLOCKED. Create report dir `openspec/changes/<slug>/quality/` or `.agy/quality/<branch>/`.

Capture fingerprint: base ref + merge-base SHA, HEAD SHA, branch diff hash, working-tree diff hash, untracked file hashes, filtered status and diff stat. Give identical scope/fingerprint to independent fresh `code-reviewer` and `qa-engineer` subagents. They write only `review.md` and `qa.md` in the report directory. Do not show one agent the other's output. Wait for both; unavailable delegation or independence => BLOCKED.

Security trigger: run a scoped quick security review if diff touches auth/session/identity, authorization/tenant scope, secrets/crypto, untrusted input/sinks, network/proxy/cookies/CORS, dependency/CI/container/IaC, filesystem/process/plugin boundaries, LLM tool boundaries, or user-data migrations/exports/deletions; also trigger on security concerns in review/QA. When uncertain, trigger. Require `security-engineer` to inspect the same fingerprint and write `security.md`. This is not a deep coverage-led audit.

Aggregate PASS only if every required report PASS and fingerprint matches. FAIL on confirmed critical/high or blocking correctness/security issues. BLOCKED on missing evidence, unavailable reviewer, stale fingerprint, or unverified test execution. Quality-only actions never fix findings.
