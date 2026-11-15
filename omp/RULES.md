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

Do not create alternate entry-point commands for these stages. Keep their existing names and argument contracts.

## Non-negotiable constraints

- Gate 1 and Gate 2 use OMP's built-in `ask`; invoking a command is not approval.
- No application implementation before explicit Gate 2 approval.
- Gate and final quality approval are session-local; never infer approval from files or prior sessions.
- Quality-only review/QA is read-only for application code and tests.
- Never claim a check, browser action, MCP call, agent delegation or provider fallback that did not actually occur.
- Preserve user changes and stop on ambiguous scope, stale evidence or a failed quality gate.

## Context and tooling

- Use OMP native file, search, edit, terminal, LSP and task capabilities instead of recreating them.
- Load skills only when relevant; keep their complete references intact and follow their own instructions.
- Use configured MCP servers only when the task requires their external capability. Never duplicate MCP tool schemas in rules.
- Model assignments and retry fallback chains live only in `config.yml`; see `MODEL-ROUTING.md` when diagnosing or changing routing.
- Detailed engineering policy belongs in `rules/core.md`, `planning.md`, `gates.md`, `execution.md`, `review.md` and `verification.md`.
