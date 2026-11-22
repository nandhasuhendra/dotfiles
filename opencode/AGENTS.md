# OpenCode Workflow Activation

Small always-loaded contract. Detailed procedures live inside each command file; never read files beyond the active command and the change artifacts it names.

## Activation

Apply this workflow only when the user explicitly invokes `/work-spec`, `/work-human`, `/work-build`, `/work-resume`, `/work-status` or `/work-ship`, or explicitly requests one of the workflow subagents. Ordinary questions, unrelated coding, or incidental mentions do not activate it. `/work-status` is read-only and never starts planning.

## Command ownership

| Command | Owns |
| --- | --- |
| `/work-spec` | Interview, alignment, Gate 1, OpenSpec artifacts, Gate 2. |
| `/work-human` | Documentation-only human planning bundle after Gate 2. |
| `/work-build` | Approved implementation, quality-only `review-and-qa` / `qa-only`. |
| `/work-resume` | Recover the earliest incomplete step without assuming approval. |
| `/work-status` | Read-only change/task/gate/evidence inspection. |
| `/work-ship` | Quality gate, semantic commit, PR and/or OpenSpec archive. |
| `/security-audit` | Standalone multi-phase security audit; no gates, shared artifacts written only to the audit output directory outside the target. |
| `/review-docs` | Read-only security + principal-engineer review of OpenSpec changes, baseline specs and any Markdown design docs (ADRs, RFCs, runbooks). |
| `/review-security` | Fast, read-only static security review of a diff, path, glob or OpenSpec slug; `/security-audit` for a verified deep audit. |
| `/review-patterns` | Read-only structural review: SOLID/KISS/YAGNI, boundaries, coupling, duplication, maintainability. |
| `/review-performance` | Read-only performance/scalability review: N+1, indexes, scans, pagination, complexity, memory, I/O, caching, concurrency. |
| `/review-all` | Combined read-only review that runs the code or docs reviewers and writes one consolidated summary. |

## Non-negotiable constraints

- Gates use the built-in `question` tool; a command invocation is not approval.
- No application implementation before an explicit Gate 2 "Approved" answer in the current session.
- Approval is session-local: never infer it from files, checked tasks, reports, silence or prior sessions.
- Quality-only actions and review/QA agents are read-only for project files.
- `review-and-qa` runs a scoped `quick` security audit when the diff crosses a risk trigger and writes `security.md`; `/work-ship` requires current security evidence when triggered and never treats a quick audit as a complete review.
- `/work-spec` requires independent `security-engineer` and `principal-engineer` design reviews before Gate 2; P0/P1 findings block approval until fixed or explicitly accepted and recorded in `design.md`.
- `/review-*` commands create a plan first (`PLAN.md`) and execute step by step sequentially without subagents; review steps use cheaper Z.ai GLM Flash, and summary file review/consolidation uses higher Z.ai GLM. They are read-only for project files and write only under their output directory; they supplement, never replace, the `/work-ship` evidence gate.
- Never claim a check, browser action, MCP call or agent delegation that did not occur.
- Preserve user changes; stop on ambiguous scope, stale evidence or a failed quality gate.

## Context & tooling

- Each command file is self-contained: read only the invoked command plus change artifacts. Do not scan agents, skills or templates.
- Prefer native read/grep/glob/edit tools over shell. If `rtk` is available, route shell through it: `rtk grep/rg`, `rtk git status`, `rtk diff`, `rtk test`, `rtk err` (failures), `rtk json --keys-only`, `rtk summary`, `rtk ls/find`; run CLIs as `rtk openspec ...` / `rtk codegraph ...` so custom filters apply, `rtk proxy <command>` only if a flag is rejected, `rtk run` for pipelines. Preserve exit codes and raw failures; on `[+N hidden]` / `[full output: ...]` hints use `rtk recall <hash>` instead of rerunning. Compressed output is not proof a check passed.
- OpenSpec CLI owns the change lifecycle (`list`, `status`, `validate`, `archive`) via `rtk openspec ...` when rtk exists (fallback: `rtk proxy openspec`), else plain `openspec`.
- Codegraph (when installed) supplies source-confirmed impact, callers and affected tests: `rtk codegraph context`, `impact`, `affected`. Confirm graph findings in source; LSP feedback stays authoritative for edited files.
- Playwright MCP supplies real browser evidence (`browser_navigate`, `browser_snapshot`, `browser_click`, `browser_type`, `browser_console_messages`, `browser_network_requests`). Never claim a browser PASS from static reasoning.
- Caveman is an opt-in chat skill (`/caveman`); it never changes artifact prose, gates or reports. Skills load their own frontmatter when relevant; do not pre-read skill bodies.
- Model routing lives in each agent's frontmatter; subagent dispatch goes through the `task` tool.
- Keep handoffs compact: slug, paths, decisions, blockers, next action.
