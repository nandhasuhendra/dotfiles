# OMP engineering workflow

Custom agents and slash commands for a streamlined three-stage engineering pipeline: **spec → build → ship**, with an optional human-planning bundle between spec and build. Shared policy lives in [RULES.md](RULES.md).

## Explicit opt-in and scope

The workflow activates only for an explicit `/work-*` command, an explicit request to use this workflow, or an explicit request for a custom agent. Ordinary questions, unrelated work, repository presence, path/tool mentions and internal helper dispatch do not activate it. `/work-status` is read-only and does not start planning.

Activation belongs to the requested operation, not the entire session. Explicit invocation is not approval and cannot bypass an active change's gates. See [RULES.md](RULES.md) and the [gate rules](rules/gates.md).

## Three-stage pipeline

| Stage | Command | Output and boundary |
| --- | --- | --- |
| Spec | `/work-spec <feature-requirements>` | Socratic interview, Devil's Advocate critique, Alignment Summary, Gate 1, then `.openspec.yaml`, `proposal.md`, `design.md` and `tasks.md` under `openspec/changes/<slug>/`, schema validation and Gate 2. |
| Human planning | `/work-human <slug>` | Post-Gate-2, documentation-only bundle under `openspec/changes/<slug>/human/`: `PRD.md`, `TECH-DOC.md` and `HUMAN-TASK-BREAKDOWN.md`, generated from the installed templates. Adds no gate. |
| Build | `/work-build [slug]` | Atomic execution of the approved `tasks.md` with strict blast-radius limits, canonical package management, physical tests/LSP checks and the two-attempt Circuit Breaker. |
| Ship | `/work-ship [slug]` | Final `git status` check, semantic commit, PR summary and OpenSpec archival via `rtk proxy openspec`. |

Standalone utilities:

- `/work-status` — read-only inspection of active changes under `openspec/changes/`.
- `/work-resume` — resume an interrupted session on an in-progress change.

No application code may be written until the user explicitly selects **Approved** at Gate 2.

## Gates

All gates use OMP's built-in `ask` tool so the human-in-the-loop decision is blocking and recorded:

1. **Gate 1 — Alignment:** confirms the Alignment Summary before any specification files are written.
2. **Gate 2 — Final Approval:** confirms the complete `proposal.md`, `design.md` and `tasks.md` before `/work-build`.

Bypassing a gate, or treating an explicit command invocation as approval, is prohibited. `/work-human` is documentation-only: it re-confirms Gate 2 through `ask`, runs only after an approved `/work-spec`, and adds no new gate.

## Roles

| Agent | Responsibility |
| --- | --- |
| tech-lead | Lead the interview and critique, author `design.md` contracts and the atomic `tasks.md` checklist (`@doc_tier`). |
| software-engineer | Execute approved tasks atomically with tests and LSP feedback (`@execution_tier`). |
| security-engineer | Optional red-team/blue-team review for security-sensitive changes or credible risk. |

Routine Git, status and formatting work should be delegated to a lightweight/free tier (`sonic` / `@execution_tier`) to preserve primary-model quota.

## Context and token efficiency

- Rules load on demand. Read only the active command/agent prompt, `RULES.md`, `rules/core.md` and the stage/gate rules needed now.
- Never enumerate every agent, command, skill, template or rule as a ritual. Avoid recursive directory scans or repository-tree dumps unless requested.
- Use paths, IDs and diffs to reference artifacts; read full bodies only for the decision at hand.
- Keep handoffs compact: slug, paths, decisions, blockers and the next action.
- Use RTK for shell commands so output is compressed, and the bundled Caveman skill for terse agent communication. Neither applies to human documents.
- For `/work-spec`, `/work-build` and `/work-ship`, do not read `templates/*`; the compact schema headings in those commands are authoritative. `/work-human` is the deliberate exception and reads the installed `templates/PRD.md`, `templates/TECH-DOC.md` and `templates/HUMAN-TASK-BREAKDOWN.md`.
- Mechanical tasks (Git operations, status queries, text formatting) may run on free/lightweight tiers when quota matters; otherwise run them directly to avoid handoff overhead.

## Install

From the dotfiles repository root:

```bash
bash omp/install-omp.sh
```

Requires Linux or macOS, Node.js **20.19+**, npm, OMP, Git, curl and tar already on PATH. The installer installs missing workflow dependencies, verifies them, then replaces configuration. It never invokes `sudo` or edits your shell profile.

Configuration goes into `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`. Existing `config.yml`, `mcp.json`, `agents/`, `commands/`, `RULES.md`, `rules/` and `templates/` are moved to timestamped backups and replaced with current source links. Matching links remain unchanged. The bundled `skills/caveman/` and `skills/hallmark/` are required and linked; optional `extensions/` is linked only if present.

CLI packages go into `${NPM_CONFIG_PREFIX:-$HOME/.local}`; keep its `bin/` directory first on PATH when starting OMP. The installer prints the exact shell command. Chromium uses Playwright's managed browser cache; Ponytail uses OMP's user plugin store.

Start a new OMP session after installation. Shared `RULES.md` and `rules/*.md` resolve under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`, not the working directory.

`omp/config.yml` is user-managed. This workflow does not change model roles, fallback chains or provider settings; edit it directly when your active roles or quotas change.

## Dependencies

| Tool | Delivery | Workflow role |
| --- | --- | --- |
| OpenSpec | Reuse a working CLI, otherwise install `@fission-ai/openspec@1.14.3` | Change lifecycle, schema artifacts, validation and archive. |
| Ponytail | Verify installed skill, otherwise register `DietrichGebert/ponytail` and install its OMP plugin | Smallest complete implementation; no unnecessary abstraction. |
| Codegraph | Reuse a working CLI, otherwise install `@colbymchenry/codegraph@1.6.2` | Source-confirmed impact, callers and regression scope. |
| Playwright | Install/verify `@playwright/mcp@0.0.83`, install its matching Chromium and render a smoke page | Real browser acceptance and regression checks. |
| Context7 | Configure hosted MCP and verify a real MCP initialize response; no local package needed | Current library/API/CLI documentation, matched to installed versions. |
| rtk-ai | Reuse a verified `rtk`, otherwise run the official v0.45.0 installer with release checksum verification enforced | Wrap every shell tool invocation; specialized subcommands, proxy or run. |

Only Playwright and Context7 are MCP servers; [mcp.json](mcp.json) is the single source of truth. Installed tools are verified by actual invocation, not PATH lookup alone. Working CLIs and Ponytail are not automatically upgraded on repeat runs; Playwright is kept at the configured version.

## MCP servers

`mcp.json` configures exactly two servers, both `enabled: true`:

| Server | Transport | Tools | Use |
| --- | --- | --- | --- |
| `context7` | HTTP, `https://mcp.context7.com/mcp` | `resolve-library-id`, `query-docs` | Current external library, framework, SDK, API and CLI documentation. Resolve the library ID first, then query the topic. Never send private code or secrets. |
| `playwright` | stdio, `playwright-mcp --browser chromium --headless --no-sandbox` | 25 `browser_*` tools, including `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_type`, `browser_console_messages`, `browser_network_requests` | Real browser verification of changed UI, console and network behavior. |

Call MCP tools only when the active stage needs them, and use the exact tool names the server exposes (OMP may prefix them with the server name). A browser or documentation claim without an MCP call is not evidence.

Codegraph, Ponytail, Hallmark, Caveman and Antislop are **not** MCP servers: they are a CLI, OMP plugins/skills, or bundled skills. Do not expect them in `mcp.json`.

Verify the configuration and both live handshakes:

```bash
bash omp/tests/mcp-check.sh
```

Check actual invocations before starting:

```bash
rtk proxy openspec --help
rtk proxy codegraph --help
rtk --help
```

### Shell commands

Every shell tool invocation goes through `rtk`:

| Route | Use |
| --- | --- |
| `rtk <subcommand>` | Preferred for supported tools: `rtk git status`, `rtk grep`, `rtk test`, `rtk playwright`. |
| `rtk proxy <command> [args]` | Specialized route rejects required flags, hides needed failure detail, or the command is unsupported. |
| `rtk run '<shell command>'` | Pipelines, redirection or compound shell syntax. |

File read/search/edit tools remain preferred over shell. Preserve exit status and raw failure output; RTK compression is not verification. If RTK is unavailable, shell execution is blocked rather than run natively.

### Documentation and impact tools

Use the `context7` MCP for external documentation as described above. Read installed Ponytail before implementation for the smallest complete solution. Prefer language-server symbol intelligence and the Codegraph CLI for nontrivial impact, confirming callers and regression scope in source. Caveman applies to agent conversation, not human documents.

### Hallmark

The workflow bundles the [Hallmark skill](skills/hallmark/SKILL.md) from [Nutlope/hallmark](https://github.com/Nutlope/hallmark). Use it when designing or implementing new websites, pages or UI, or when a redesign/audit is requested.

## Change artifacts

All change artifacts live under `openspec/changes/<slug>/`:

| Artifact | Purpose |
| --- | --- |
| `.openspec.yaml` | Schema marker. The streamlined flow sets `schema: spec-driven` and `skip_specs: true` so the three-artifact change validates without capability deltas. |
| `proposal.md` | Functional PRD: `## Why`, `## What Changes`, `## Capabilities` and `## Impact`. No internal file paths or code extensions. |
| `design.md` | Technical architecture: `## Context`, `## Goals / Non-Goals`, `## Decisions` and `## Risks / Trade-offs`. |
| `tasks.md` | Sequential, atomic implementation checklist (3–6 focused tasks) with explicit target file scopes and acceptance criteria. |
| `human/PRD.md` | Optional human PRD from `templates/PRD.md`, generated by `/work-human` after Gate 2. |
| `human/TECH-DOC.md` | Optional human technical specification from `templates/TECH-DOC.md`. |
| `human/HUMAN-TASK-BREAKDOWN.md` | Optional human milestone plan from `templates/HUMAN-TASK-BREAKDOWN.md`. |

`skip_specs: true` trades OpenSpec capability deltas for a smaller three-artifact flow. If you want spec-level tracking, omit it and add `specs/<capability>/spec.md`. Templates remain installed under `templates/` for `/work-human`; the spec/build/ship commands use their compact schema headings instead.

## Read on your phone

Run the wrapper directly from your project:

```bash
omp/view-docs.sh start /path/to/project/openspec/changes 0.0.0.0 8765
```

To stop the viewer: `omp/view-docs.sh stop`.

Open the printed `http://<laptop-lan-ip>:8765/` on a phone connected to the same Wi-Fi. The index lists each change; Markdown tables, relative `.md` links and Mermaid fences render.

- Mermaid uses a pinned jsDelivr module in the browser. If the CDN is unreachable, the diagram stays as a readable code block; no diagram is claimed.
- No authentication. Use a trusted network. For access away from home, bind to the Tailscale IP (`tailscale ip -4`) or use a private tunnel; never expose the port publicly.
- For offline or anywhere reading without the laptop, sync `openspec/changes/` with Syncthing or add it to an Obsidian vault.
- `openspec view` is a terminal dashboard, not a phone-accessible page.

## Verification and limits

- Code correctness is validated through physical test runners, linters and compiler/LSP diagnostics during `/work-build`, not through speculative LLM prose reviews.
- Every new feature should include unit, integration or end-to-end tests covering the happy path and the failure/edge cases defined in `design.md`.
- Run existing regression suites before `/work-ship`; linters and typecheckers must pass cleanly.
- The Circuit Breaker stops after two failed repair attempts and reports the blocker instead of looping.
- These are prompt-level rules, not runtime access control. OMP does not ship a gate script or write-blocking hook.

Installation references: [OpenSpec](https://github.com/Fission-AI/OpenSpec), [Codegraph](https://github.com/colbymchenry/codegraph/blob/main/site/src/content/docs/getting-started/installation.md), [Ponytail](https://github.com/DietrichGebert/ponytail/blob/main/INSTALL.md), [Playwright MCP](https://github.com/microsoft/playwright-mcp), [RTK](https://github.com/rtk-ai/rtk/blob/develop/docs/guide/getting-started/installation.md).
