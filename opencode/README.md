# OpenCode engineering workflow

Port of the [OMP workflow](../omp/README.md) to OpenCode's builtin features: same six commands, same two-gate pipeline, same read-only review/QA agents — with fewer always-loaded tokens.

## What replaces what

| OMP mechanism | OpenCode builtin | Effect |
| --- | --- | --- |
| `RULES.md` + 6 `rules/*.md` files | One small `AGENTS.md` (always in context) + stage rules merged into each command file | one file read per command instead of 3–6 |
| `task.agentModelOverrides` + `modelRoles` + `fallbackChains` | per-agent `model:` frontmatter | no routing docs; routing is 5 lines |
| `ask` tool | builtin `question` tool | same blocking gates |
| `mcp.json` | `mcp` block in `opencode.jsonc` | same two servers |
| bundled skills dir | `skills/` — OpenCode loads only skill frontmatter until relevant | description-only token cost |
| OMP `task` tool | builtin `task` subagent tool (`mode: subagent` agents) | same delegation |

Model tiers (verify against `opencode models`; the omp `opencode-zen/...` prefixes are this harness's `opencode/...`):

| Agent | Model |
| --- | --- |
| tech-lead, security-engineer | `openai/gpt-5.6-sol:medium` |
| software-engineer, qa-engineer | `opencode/deepseek-v4.1-flash-free` |
| code-reviewer | `google/gemini-3.8-flash:low` |

OpenCode has no native model-fallback chain; rerun or switch the agent's `model:` on provider failure.

## Token-efficiency choices

- Each command is self-contained: read only the invoked command plus change artifacts. Never scan agents, skills or templates.
- `AGENTS.md` is the only always-in-context workflow file and is kept deliberately small.
- Skills (caveman, hallmark) are symlinked from `omp/skills/` and cost only their description until invoked.
- Agents are lean prompts; review/QA/security agents have `write`/`edit` tools disabled in frontmatter, so blast-radius limits are tool-level, not just prompt-level.
- OMP-only installers are dropped: no forced RTK/Codegraph installs and no installer-run npm installs. Both are used opportunistically when present — RTK for shell/CLI compression, Codegraph for source-confirmed impact (`codegraph context/impact/affected`). OpenSpec CLI is still required for the artifact lifecycle — commands use `rtk openspec` when `rtk` exists, else plain `openspec`. `rtk` installs a global hook/plugin so matching commands are rewritten automatically; filtered CLIs and `rtk recall <hash>` recover elided output.

## Commands

`/work-spec`, `/work-human`, `/work-build`, `/work-resume`, `/work-status`, `/work-ship` — semantics identical to the OMP versions (interview → Gate 1 → artifacts → validate → Gate 2 → build → quality choice → ship). Quality reports live in `openspec/changes/<slug>/quality/` (slug targets) or `.omp-quality/<branch>/` (branch targets).

## Install

From the dotfiles repository root:

```bash
bash opencode/install-opencode.sh
```

Links `AGENTS.md`, `agents/`, `commands/`, `skills/`, `templates/` and `opencode.jsonc` into `~/.config/opencode/` with timestamped backups of any existing files. Requires OpenCode ≥ 2.x and a working `openspec` CLI on PATH for the OpenSpec stages.

Start a new OpenCode session after installation. Explicit opt-in semantics match OMP: nothing activates without an explicit `/work-*` command.
