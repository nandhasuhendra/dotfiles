# OpenCode

Snapshot of the global OpenCode setup in `~/.config/opencode/`:

- `opencode.jsonc` — existing settings and MCP server definitions
- `cli.json` — terminal appearance and behavior
- `skills/` — personal skills and their supporting files
- `agents/` — seven role-based agents plus a PRD/technical-document orchestrator
- `templates/` — canonical PRD and technical-document Markdown templates
- `plugins/`, `herdr-opencode/`, and `herdr-tui-session.js` — local integrations
- `tui.jsonc` — existing legacy TUI configuration
- `package.json` — dependency declaration (install dependencies locally)

To install OpenCode V2 (if missing) and link this setup on Linux or macOS, run
from the dotfiles repository:

```sh
./install-opencode.sh
```

The installer backs up existing files or directories at each link path and is
safe to re-run. It keeps `node_modules/`, service settings, and local state
untouched, and copies `package.json` only if absent. Install its dependencies
locally if your OpenCode version needs them. Adjust the hard-coded home path in
`opencode.jsonc` for another username; MCP commands require `uvx` and `npx`.
MCP OAuth credentials and provider sign-ins are intentionally **not** stored
here and must be authorized separately.

`opencode.jsonc` is a copy of the existing configuration, including older
OpenCode settings. It has not been migrated to the current V2 format.

The Markdown agents in `agents/` are linked globally to
`~/.config/opencode/agents/`. Each supports both direct selection and use as a
subagent. Select `team-leader` (or ask your current agent to use it) for a
technical document and dependency-aware task breakdown. The other IDs are
`product-manager`, `senior-architect-engineer`, `senior-backend-engineer`,
`senior-frontend-engineer`, `senior-qa-engineer`, and `senior-devops-engineer`.
They inherit the session model unless you configure one explicitly.

Select `document-orchestrator` as the primary agent and ask it to create or
update a PRD and technical document. It invokes Product Manager → Team Leader
→ Architect → Team Leader (final revision) sequentially, checks both templates,
and saves the documents only when requested. It is linked globally with the
other agents by `./install-opencode.sh`.

The Product Manager uses `templates/PRD.md` for new and existing PRDs. The Team
Leader uses `templates/TECH-DOC.md` for technical documents and task breakdowns
and checks the PRD before writing the design. The technical document requires
high-level, flowchart, sequence, and ERD diagram sections, plus data, API, and
event contracts. Every task title must start with an action verb. The installer
links these templates to `~/.config/opencode/templates/`; agents must read the current template for
each document creation or edit, preserve existing content and IDs, and record
unresolved decisions instead of inventing facts.
