# OMP Workflow Activation

This file is intentionally small: OMP keeps top-level `RULES.md` in the system context. Detailed procedures live in the command and stage-specific rule files.

## Activation

Apply this workflow only when the user explicitly invokes one of the six commands below or explicitly requests a custom agent. Do not activate it for ordinary questions, unrelated coding, or incidental mentions of OMP tools.

For an activated command, read that command first, then only the shared/stage rules it names. Resolve installed shared rules under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/rules/`. Do not scan every command, agent, skill, template or rule.

## Command ownership

| Command | Owns |
| --- | --- |
| `/work-spec` | Discovery, interview, alignment, OpenSpec artifacts and specification approval gates. |
| `/work-human` | Optional human-readable PRD, Tech Doc and task breakdown; documentation only. |
| `/work-build` | Approved implementation, focused checks, and `review-and-qa` / `qa-only` actions. |
| `/work-resume` | Recover the earliest incomplete workflow step without assuming prior approval. |
| `/work-status` | Read-only workflow, task, gate and quality-evidence status. |
| `/work-ship` | Final verification, Git/PR operations and/or OpenSpec archival according to the selected mode. |
| `/security-audit` | Standalone multi-phase security audit: reconnaissance, coverage-led hunting, independent verification and schema-validated findings. No gates; shared files are written only to the audit output directory outside the target. |
| `/review-docs` | Read-only security + principal-engineer review of OpenSpec changes, baseline specs and any Markdown design docs (ADRs, RFCs, runbooks). Reports only under the chosen output directory. |
| `/review-security` | Fast, read-only static security review of a diff, path, glob or OpenSpec slug. Use `/security-audit` for a verified deep audit. |
| `/review-patterns` | Read-only structural review of code or design: SOLID/KISS/YAGNI, boundaries, coupling, duplication, maintainability. |
| `/review-performance` | Read-only performance and scalability review: N+1, indexes, scans, pagination, complexity, memory, I/O, caching, concurrency. |
| `/review-all` | Combined read-only review that runs the correctness, security, pattern and performance reviewers (or the docs reviewers) and writes one consolidated summary. |

Do not create alternate entry-point commands for these stages. Keep their existing names and argument contracts.

## Non-negotiable constraints

- Gate 1 and Gate 2 use OMP's built-in `ask`; invoking a command is not approval.
- No application implementation before explicit Gate 2 approval.
- Gate and final quality approval are session-local; never infer approval from files or prior sessions.
- Quality-only review/QA is read-only for application code and tests.
- `review-and-qa` runs a scoped `quick` security audit when the diff crosses a risk trigger and writes `security.md`; `/work-ship` requires current security evidence when triggered and never treats a quick audit as a complete review.
- `/work-spec` requires independent `security-engineer` and `principal-engineer` design reviews before Gate 2; P0/P1 findings block approval until fixed or explicitly accepted and recorded in `design.md`.
- `/review-*` commands create a plan first (`PLAN.md`) and execute step by step sequentially without subagents (using cheaper Z.ai GLM Flash for review steps and higher Z.ai GLM for summary file synthesis). They are read-only for project files and write only under their output directory; they supplement, never replace, the `/work-ship` evidence gate.
- Never claim a check, browser action, MCP call, agent delegation or provider fallback that did not actually occur.
- Preserve user changes and stop on ambiguous scope, stale evidence or a failed quality gate.

## Context and tooling

- Use OMP native file, search, edit, terminal, LSP and task capabilities instead of recreating them.
- Load skills only when relevant; keep their complete references intact and follow their own instructions.
- Use configured MCP servers only when the task requires their external capability. Never duplicate MCP tool schemas in rules.
- Model assignments and retry fallback chains live only in `config.yml`; see `MODEL-ROUTING.md` when diagnosing or changing routing.
- Detailed engineering policy belongs in `rules/core.md`, `planning.md`, `gates.md`, `execution.md`, `review.md` and `verification.md`.
