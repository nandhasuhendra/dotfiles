# Antigravity CLI — OMP workflow port

This is a parallel, opt-in port of the repository's OMP engineering workflow to Google's Antigravity CLI. It does not replace or modify `omp/`.

## What maps to what

| OMP concept | Antigravity implementation |
| --- | --- |
| `/work-*`, `/review-*`, `/security-audit` | Agent Skills, automatically exposed as slash commands |
| OMP custom agents | `.agents/agents/*.md` in this source tree; installed globally |
| OMP RULES/rules | A compact global `AGENTS.md` activation contract |
| OMP MCP config | Antigravity `mcp_config.json` (Context7 + Playwright) |
| OMP installer | `install-antigravity.sh` |
| OMP native `ask` | Explicit conversational stop-and-wait; Antigravity has no identical OMP gate primitive |
| OMP native `task` | Antigravity custom subagents via `invoke_subagent`; independence must be checked |
| OMP model roles/fallback | Not ported as provider routing; choose Antigravity model/effort per session or agent |

## Install

From this repository:

```bash
bash antigravity/install-antigravity.sh
```

The installer targets `~/.gemini/config`, the CLI's shared customization directory. It creates individual symlinks and merges MCP servers without deleting existing entries. Conflicting MCP server names cause a safe failure. Existing destination files are backed up before replacement. Use `--dry-run` to preview.

Requirements: Antigravity CLI (`agy`) already installed and authenticated; Bash, Python 3, Git, and Node.js/npm for the Playwright MCP server. The installer does not install Antigravity, change your shell profile, or store credentials.

## Commands

Each skill is exposed as a slash command in the Antigravity CLI:

- `/work-spec <requirements>`
- `/work-human <slug>`
- `/work-build [slug] [review-and-qa|qa-only]`
- `/work-resume`, `/work-status`, `/work-ship [slug] [git|archive|full]`
- `/review-docs`, `/review-security`, `/review-patterns`, `/review-performance`, `/review-all`
- `/security-audit [target] [quick|standard|deep]`

A skill is the native Antigravity CLI equivalent of a reusable command: it is automatically available as `/<skill-name>`. Run `/skills reload` or start a new session after installing.

## MCP

- **Context7**: hosted HTTP MCP for current library/framework documentation.
- **Playwright**: local stdio MCP using `npx -y @playwright/mcp@latest --headless`.

The Playwright browser is a testing tool, not a security sandbox. Do not use real credentials or production endpoints during security audits.

## Important parity gaps

1. OMP's `ask` is a native blocking gate. Antigravity skills instead instruct the primary agent to ask in chat and stop. Approval is not machine-enforced or cryptographically session-bound.
2. Antigravity's subagent tool names, scheduling and parallel behavior depend on the installed CLI version. Verify each delegation in the transcript; never claim delegation that did not happen.
3. OMP's `compaction.thresholdTokens: 60000` has no confirmed equivalent CLI setting. Antigravity handles context compaction internally; preserve durable state in files and compact at milestones.
4. OMP provider modelRoles and retry fallback chains do not map to Antigravity. This port uses the active Antigravity model selected by the user.
5. Deep security audit execution requires an OS-enforced sandbox. If one is unavailable, source inspection may continue but target-controlled code must not be executed and findings remain `needs_validation`.

## Validation

After install:
```bash
agy agents
agy skills
agy mcp list
```
Then open a fresh CLI session and try `/work-status` in a repository with an OpenSpec change. Review the generated plan before using `/work-build`.

See [WORKFLOW-PARITY.md](WORKFLOW-PARITY.md) for the migration matrix and acceptance checklist.
